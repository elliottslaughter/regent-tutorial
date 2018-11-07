-- Copyright 2018 Stanford University
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
  bit : bool;
}

task printer(bit_region : region(ispace(int1d), BitField))
where
  reads(bit_region.bit)
do
  c.printf("The bits are: ")
  var limits = bit_region.bounds
  for i = [int](limits.lo), [int](limits.hi) + 1 do
    if bit_region[i].bit then
      c.printf("1 ")
    else
      c.printf("0 ")
    end
  end
  c.printf("\n")
end

task blink(bit_region : region(ispace(int1d), BitField))
where
  reads writes(bit_region.bit)
do
  for b in bit_region do
    b.bit = not b.bit
  end
end

task launcher(br : region(ispace(int1d), BitField),
              p  : partition(disjoint, br, ispace(int1d)))
where
  reads writes(br.bit)
do
  for c in p.colors do
    blink(p[c])
  end
end

task main()
  var size = 60
  var num_pieces_large = 6
  var num_pieces_small = 3
  var bit_region = region(ispace(int1d, size), BitField)

  var bit_region_partition_large = partition(equal, bit_region, ispace(int1d, num_pieces_large))
  var bit_region_partition_small = partition(equal, bit_region, ispace(int1d, num_pieces_small))

  fill(bit_region.bit, false)
  for i = 0, 4 do
    launcher(bit_region, bit_region_partition_small)
    launcher(bit_region, bit_region_partition_large)
  end
  printer(bit_region)
end

regentlib.start(main)
