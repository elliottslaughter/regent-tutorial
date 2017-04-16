import "regent"

local png = {}
do
  local root_dir = arg[0]:match(".*/") or "./"
  local png_util_cc = root_dir .. "png_util.c"
  png_util_so = os.tmpname() .. ".so"
  local cc = os.getenv('CC') or 'cc'
  local cc_flags = "-O2 -Wall -Werror -std=c99"
  local is_darwin = os.execute('test "$(uname)" = Darwin') == 0
  if is_darwin then
    cc_flags =
      (cc_flags ..
         " -dynamiclib -single_module -undefined dynamic_lookup -fPIC")
  else
    cc_flags = cc_flags .. " -shared -fPIC"
  end

  local cmd = (cc .. " " .. cc_flags .. " " .. png_util_cc .. " -o " .. png_util_so)
  if os.execute(cmd) ~= 0 then
    print("Error: failed to compile " .. png_util_cc)
    assert(false)
  end
  terralib.linklibrary(png_util_so)
  if is_darwin then
    terralib.linklibrary("libpng.dylib")
  else
    terralib.linklibrary("libpng.so")
  end
  png.c = terralib.includec("png_util.h", {"-I", root_dir })
end

local c = regentlib.c

local terra get_rect_size(rect : c.legion_rect_2d_t)
  var size_image : png.c.image_size_t
  size_image.width  = rect.hi.x[0] - rect.lo.x[0] + 1
  size_image.height = rect.hi.x[1] - rect.lo.x[1] + 1
  return size_image
end

local terra get_base_pointer(pr   : c.legion_physical_region_t[1],
                             fid  : c.legion_field_id_t[1],
                             rect : c.legion_rect_2d_t)
  var subrect : c.legion_rect_2d_t
  var offsets : c.legion_byte_offset_t[2]
  var accessor = c.legion_physical_region_get_field_accessor_generic(pr[0], fid[0])
  var base_pointer =
    [&uint8](c.legion_accessor_generic_raw_rect_ptr_2d(
      accessor, rect, &subrect, &(offsets[0])))
  c.legion_accessor_generic_destroy(accessor)
  return base_pointer
end

__demand(__inline)
task png.get_image_size(filename : int8[256]) : int2d
  var image_size = png.c.get_image_size(filename)
  return int2d { image_size.width, image_size.height }
end

terra png.read_png_file(filename : int8[256],
                        pr       : c.legion_physical_region_t[1],
                        fid      : c.legion_field_id_t[1],
                        rect     : c.legion_rect_2d_t)
  var size_image = get_rect_size(rect)
  var base_pointer = get_base_pointer(pr, fid, rect)
  png.c.read_png_file(filename, base_pointer, size_image)
end

terra png.write_png_file(filename : int8[256],
                         pr       : c.legion_physical_region_t[1],
                         fid      : c.legion_field_id_t[1],
                         rect     : c.legion_rect_2d_t)
  var size_image = get_rect_size(rect)
  var base_pointer = get_base_pointer(pr, fid, rect)
  png.c.write_png_file(filename, base_pointer, size_image)
end

return png
