-- Copyright 2024 Stanford University
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

import "regent"

local c = regentlib.c

fspace BitField
{
  bit1 : bool,
  bit2 : bool,
}

task printer(bit_region : region(ispace(int1d), BitField))
where
  reads(bit_region.bit1), reads(bit_region.bit2)
do
  c.printf("The bits are: \nbit1: ")
  var limits = bit_region.bounds
  for i = [int](limits.lo), [int](limits.hi) + 1 do
    if bit_region[i].bit1 then
      c.printf("1 ")
    else
      c.printf("0 ")
    end
  end
  c.printf("\nbit2: ")
  for i = [int](limits.lo), [int](limits.hi) + 1 do
    if bit_region[i].bit2 then
      c.printf("1 ")
    else
      c.printf("0 ")
    end
  end
  c.printf("\n")
end

task clear(bit_region : region(ispace(int1d), BitField))
where
  reads writes(bit_region)
do
  for b in bit_region do
    b.bit1 = false
    b.bit2 = false
  end
end

task blink1(bit_region : region(ispace(int1d), BitField))
where
  reads writes(bit_region.bit1)
do
  for b in bit_region do
    b.bit1 = not b.bit1
  end
end

task blink2(bit_region : region(ispace(int1d), BitField))
where
  reads writes(bit_region.bit2)
do
  for b in bit_region do
    b.bit2 = not b.bit2
  end
end

task main()
  var size = 60
  var bit_region = region(ispace(int1d, size), BitField)

  -- We have two partitions of the same region, one with small subregions and one with large subregions.
  var bit_region_partition_small = partition(equal, bit_region, ispace(int1d, 6))

  -- Now create an aliased partition of two subregions that both contain index 30
  var coloring = c.legion_domain_point_coloring_create()
  c.legion_domain_point_coloring_color_domain(coloring, [int1d](0), rect1d { 0, 30 })
  c.legion_domain_point_coloring_color_domain(coloring, [int1d](1), rect1d { 30, 59 })
  var bit_region_partition_large = partition(aliased, bit_region, coloring, ispace(int1d, 2))
  c.legion_domain_point_coloring_destroy(coloring)

  clear(bit_region)
  for i = 0, 3 do
    for color in bit_region_partition_small.colors do
      blink1(bit_region_partition_small[color])
    end
    for color in bit_region_partition_large.colors do
      blink2(bit_region_partition_large[color])
    end
  end
  printer(bit_region)
end

regentlib.start(main)
