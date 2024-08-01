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

local format = require("std/format")

fspace BitField
{
  bit : bool,
}

task printer(bit_region : region(ispace(int1d), BitField))
where
  reads(bit_region.bit)
do
  format.print("The bits are: ")
  var limits = bit_region.bounds
  for i = [int](limits.lo), [int](limits.hi) + 1 do
    if bit_region[i].bit then
      format.print("1 ")
    else
      format.print("0 ")
    end
  end
  format.println("")
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

--
-- TODO  Create two partitions: one with 6 subregions of size 10, the other with 3 subregions
-- of size 20.  Modify the loop to alternately launch subtasks across first one, then the other,
-- partition on each iteration.
--
task main()
  var size = 60
  var num_pieces = 6
  var bit_region = region(ispace(int1d, size), BitField)

  var bit_region_partition = partition(equal, bit_region, ispace(int1d, num_pieces))

  -- Fill writes a particular value into a particular field for every point in the region.
  -- Here we use fill to replace the clear task.
  fill(bit_region.bit, false)

  for i = 0, 4 do
    launcher(bit_region, bit_region_partition)
  end
  printer(bit_region)
end

regentlib.start(main)
