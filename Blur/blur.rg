import "regent"

local format = require("std/format")

-- Helper modules to handle PNG files and command line arguments
local png        = require("png_util")
local BlurConfig = require("blur_config")

-- Some C APIs
local c     = regentlib.c
local sqrt  = regentlib.sqrt(double)
local DBL_MAX = 0x1.fffffffffffffp+1023

-- Field space for pixels
fspace Pixel
{
  original : uint8,    -- Original pixel in 8-bit gray scale
  blur     : uint8,    -- Blurred pixel
}

task factorize(parallelism : int) : int2d
  var limit = [int](sqrt([double](parallelism)))
  var size_x = 1
  var size_y = parallelism
  for i = 1, limit + 1 do
    if parallelism % i == 0 then
      size_x, size_y = i, parallelism / i
      if size_x > size_y then
        size_x, size_y = size_y, size_x
      end
    end
  end
  return int2d { size_x, size_y }
end

--
-- The 'initialize' task reads the image data from the file and initializes
-- the fields for later tasks. The upper left and lower right corners of the image
-- correspond to point {0, 0} and {width - 1, height - 1}, respectively.
--
task initialize(r_image : region(ispace(int2d), Pixel),
                filename : int8[256])
where
  reads writes(r_image)
do
  png.read_png_file(filename,
                    __physical(r_image.original),
                    __fields(r_image.original),
                    r_image.bounds)
  for e in r_image do
    r_image[e].blur = r_image[e].original
  end
end

--
-- TODO: implement the 'blur' task.
--
-- The 'blur' task implements a Gaussian blur using the following 3x3 filter:
--
--  1    | 1 2 1 |
--  -- * | 2 4 2 |
--  16   | 1 2 1 |
--
-- Note that the upper left corner of the filter is applied to the
-- pixel that is off from the center by (-1, -1).
--
__demand(__cuda)
task blur(r_image    : region(ispace(int2d), Pixel),
          r_interior : region(ispace(int2d), Pixel))
where
  reads(r_image.original), writes(r_interior.blur)
do
  var ts_start = c.legion_get_current_time_in_micros()

  -- TODO: write a loop that does the convolution between the interior image
  --       and the 3x3 Gaussian filter

  return ts_start
end

__demand(__cuda)
task block_task(r_image : region(ispace(int2d), Pixel))
where
  reads writes(r_image)
do
  return c.legion_get_current_time_in_micros()
end

terra wait_for(x : int) return 1 end

task saveBlur(r_image  : region(ispace(int2d), Pixel),
              filename : int8[256])
where
  reads(r_image.blur)
do
  png.write_png_file(filename,
                     __physical(r_image.blur),
                     __fields(r_image.blur),
                     r_image.bounds)
end

task calculate_interior_size(bounds : rect2d) : rect2d
  return rect2d { bounds.lo + {1, 1}, bounds.hi - {1, 1} }
end

task create_interior_partition(r_image : region(ispace(int2d), Pixel))
  var identity_partition = partition(equal, r_image, ispace(int2d, {1, 1}))
  var interior_image_partition =
    image(r_image, identity_partition, calculate_interior_size)
  return interior_image_partition
end

task calculate_halo_size(private_bounds : rect2d) : rect2d
  -- TODO: change the following code so that halo_bounds contains
  -- both private and ghost points
  var halo_bounds = private_bounds
  return halo_bounds
end

task toplevel()
  var config : BlurConfig
  config:initialize_from_command()

  -- Create a logical region for original image and intermediate results
  var size_image = png.get_image_size(config.filename_image)
  var r_image = region(ispace(int2d, size_image), Pixel)

  -- Create a sub-region for the interior part of image
  var p_interior = create_interior_partition(r_image)
  var r_interior = p_interior[{0, 0}]

  -- Create an equal partition of the interior image
  var p_private_colors = ispace(int2d, factorize(config.parallelism))
  var p_private = partition(equal, r_interior, p_private_colors)

  -- Create a halo partition for ghost access
  var p_halo = image(r_image, p_private, calculate_halo_size)

  initialize(r_image, config.filename_image)
  __fence(__execution, __block)

  var ts_start = DBL_MAX
  for color in p_private_colors do
    ts_start min= blur(p_halo[color], p_private[color])
  end

  var ts_end : uint64 = 0
  for color in p_private_colors do
    ts_end max= block_task(p_private[color])
  end
  format.println("Total time: {.3} ms.", [double](ts_end - ts_start) * 1e-3)

  saveBlur(r_image, config.filename_blur)
end

regentlib.start(toplevel)
