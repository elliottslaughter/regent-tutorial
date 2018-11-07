import "regent"
import "bishop"

local c = regentlib.c

local util = {}

struct PageRankConfig
{
  input          : int8[512],
  output         : int8[512],
  dump_output    : bool,
  damp           : double,
  error_bound    : double,
  max_iterations : uint32,
  num_pages      : uint64;
  num_links      : uint64;
  parallelism    : uint32;
}

local cstring = terralib.includec("string.h")

terra print_usage_and_abort()
  c.printf("Usage: regent.py pagerank.rg [OPTIONS]\n")
  c.printf("OPTIONS\n")
  c.printf("  -h            : Print the usage and exit.\n")
  c.printf("  -i {file}     : Use {file} as input.\n")
  c.printf("  -o {file}     : Save the ranks of pages to {file}.\n")
  c.printf("  -d {value}    : Set the damping factor to {value}.\n")
  c.printf("  -e {value}    : Set the error bound to {value}.\n")
  c.printf("  -c {value}    : Set the maximum number of iterations to {value}.\n")
  c.printf("  -p {value}    : Set the number of parallel tasks to {value}.\n")
  c.abort()
end

terra file_exists(filename : rawstring)
  var file = c.fopen(filename, "rb")
  if file == nil then return false end
  c.fclose(file)
  return true
end

terra PageRankConfig:initialize_from_command()
  var input_given = false

  self.dump_output = false
  self.damp = 0.85
  self.error_bound = 1e-3
  self.max_iterations = 2147483647
  self.parallelism = 1

  var args = c.legion_runtime_get_input_args()
  var i = 1
  while i < args.argc do
    if cstring.strcmp(args.argv[i], "-h") == 0 then
      print_usage_and_abort()
    elseif cstring.strcmp(args.argv[i], "-i") == 0 then
      i = i + 1

      var file = c.fopen(args.argv[i], "rb")
      if file == nil then
        c.printf("File '%s' doesn't exist!\n", args.argv[i])
        c.abort()
      end
      cstring.strcpy(self.input, args.argv[i])
      c.fscanf(file, "%llu\n%llu\n", &self.num_pages, &self.num_links)
      input_given = true
      c.fclose(file)
    elseif cstring.strcmp(args.argv[i], "-o") == 0 then
      i = i + 1
      if file_exists(args.argv[i]) then
        c.printf("File '%s' already exists!\n", args.argv[i])
        c.abort()
      end
      cstring.strcpy(self.output, args.argv[i])
      self.dump_output = true
    elseif cstring.strcmp(args.argv[i], "-d") == 0 then
      i = i + 1
      self.damp = c.atof(args.argv[i])
    elseif cstring.strcmp(args.argv[i], "-e") == 0 then
      i = i + 1
      self.error_bound = c.atof(args.argv[i])
    elseif cstring.strcmp(args.argv[i], "-c") == 0 then
      i = i + 1
      self.max_iterations = c.atoi(args.argv[i])
    elseif cstring.strcmp(args.argv[i], "-p") == 0 then
      i = i + 1
      self.parallelism = c.atoi(args.argv[i])
    end
    i = i + 1
  end
  if not input_given then
    c.printf("Input file must be given!\n\n")
    print_usage_and_abort()
  end
end

mapper

$CPUs = processors[isa=x86]

task {
  target : $CPUs[0];
}

task#rank_page[index=$p],
task#calculate_squared_error[index=$p] {
  target : $CPUs[$p[0] % $CPUs.size];
}

end

return PageRankConfig
