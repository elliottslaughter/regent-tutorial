import "regent"

local format = require("std/format")

local PageRankConfig = require("pagerank_config")

local c = regentlib.c

fspace Page {
  num_outlinks : uint32,
  rank         : double,
  next_rank    : double,
}

fspace Link(r_src_pages : region(Page),
            r_dst_pages : region(Page)) {
  src_page : ptr(Page, r_src_pages),
  dst_page : ptr(Page, r_dst_pages),
}

terra skip_header(f : &c.FILE)
  var x : uint64, y : uint64
  c.fscanf(f, "%llu\n%llu\n", &x, &y)
end

terra read_ids(f : &c.FILE, page_ids : &uint32)
  return c.fscanf(f, "%d %d\n", &page_ids[0], &page_ids[1]) == 2
end

task initialize_graph(r_pages   : region(Page),
                      r_links   : region(Link(r_pages, r_pages)),
                      damp      : double,
                      num_pages : uint64,
                      filename  : int8[512])
where
  reads writes(r_pages, r_links)
do
  var ts_start = c.legion_get_current_time_in_micros()
  for page in r_pages do
    page.rank = 1.0 / num_pages
    page.next_rank = (1.0 - damp) / num_pages
    page.num_outlinks = 0
  end

  var f = c.fopen(filename, "rb")
  skip_header(f)
  var page_ids : uint32[2]
  for link in r_links do
    regentlib.assert(read_ids(f, page_ids), "Less data that it should be")
    var src_page = unsafe_cast(ptr(Page, r_pages), page_ids[0])
    var dst_page = unsafe_cast(ptr(Page, r_pages), page_ids[1])
    link.src_page = src_page
    link.dst_page = dst_page
    src_page.num_outlinks += 1
  end
  c.fclose(f)
  var ts_stop = c.legion_get_current_time_in_micros()
  format.println("Graph initialization took {.4} sec", (ts_stop - ts_start) * 1e-6)
end

task rank_page(r_src_pages : region(Page),
               r_dst_pages : region(Page),
               r_links     : region(Link(r_src_pages, r_dst_pages)),
               damp        : double)
where
  reads(r_links.{src_page, dst_page}),
  reads(r_src_pages.{rank, num_outlinks}),
  reduces+(r_dst_pages.next_rank)
do
  for link in r_links do
    link.dst_page.next_rank +=
      damp * link.src_page.rank / link.src_page.num_outlinks
  end
end

task calculate_squared_error(r_pages     : region(Page),
                             damp        : double,
                             num_pages   : uint64)
where
  reads writes(r_pages.{rank, next_rank})
do
  var sum_error : double = 0.0
  for page in r_pages do
    var diff = page.rank - page.next_rank
    sum_error += diff * diff
    page.rank = page.next_rank
    page.next_rank = (1.0 - damp) / num_pages
  end
  return sum_error
end

task dump_ranks(r_pages  : region(Page),
                filename : int8[512])
where
  reads(r_pages.rank)
do
  var f = c.fopen(filename, "w")
  for page in r_pages do format.fprintln(f, "{e}", page.rank) end
  c.fclose(f)
end

task toplevel()
  var config : PageRankConfig
  config:initialize_from_command()
  format.println("**********************************")
  format.println("* PageRank                       *")
  format.println("*                                *")
  format.println("* Number of Pages  : {11} *",  config.num_pages)
  format.println("* Number of Links  : {11} *",  config.num_links)
  format.println("* Damping Factor   : {11.4} *", config.damp)
  format.println("* Error Bound      : {11e} *",   config.error_bound)
  format.println("* Max # Iterations : {11} *",   config.max_iterations)
  format.println("* # Parallel Tasks : {11} *",   config.parallelism)
  format.println("**********************************")

  var r_pages = region(ispace(ptr, config.num_pages), Page)
  var r_links = region(ispace(ptr, config.num_links), Link(wild, wild))
  initialize_graph(r_pages, r_links, config.damp, config.num_pages, config.input)

  regentlib.assert(config.parallelism < config.num_links,
                   "The number of parallel tasks cannot exceed the number of links")
  var colors = ispace(int1d, config.parallelism)
  var p_links = partition(equal, r_links, colors)
  var p_pages = partition(equal, r_pages, colors)
  var p_src_pages = image(r_pages, p_links, r_links.src_page)
  var p_dst_pages = image(r_pages, p_links, r_links.dst_page)

  var num_iterations = -1
  var converged = false
  var ts_start = c.legion_get_current_time_in_micros()
  while not converged do
    if num_iterations == 0 then ts_start = c.legion_get_current_time_in_micros() end
    num_iterations += 1
    __demand(__index_launch)
    for color in colors do
      rank_page(p_src_pages[color], p_dst_pages[color], p_links[color], config.damp)
    end
    var sum_error = 0.0
    __demand(__index_launch)
    for color in colors do
      sum_error +=
        calculate_squared_error(p_pages[color], config.damp, config.num_pages)
    end
    converged = sum_error <= config.error_bound * config.error_bound or
                num_iterations >= config.max_iterations
  end
  var ts_stop = c.legion_get_current_time_in_micros()
  format.println("PageRank converged after {} iterations in {.4} sec",
    num_iterations, (ts_stop - ts_start) * 1e-6)

  if config.dump_output then dump_ranks(r_pages, config.output) end
end

regentlib.start(toplevel, bishoplib.make_entry())
