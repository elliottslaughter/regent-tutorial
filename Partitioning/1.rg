-- Copyright 2016 Stanford University
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
local std = terralib.includec("stdlib.h")

fspace BitField
{
   bit : bool;
}

task clear(bit_region: region(ispace(int1d), BitField))
where
   writes(bit_region.bit)
do
   for b in bit_region do
      b.bit = false
   end
end

task printer(bit_region: region(ispace(int1d), BitField))
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

task blink(bit_region: region(ispace(int1d), BitField))
where
   reads writes(bit_region.bit)
do
   for b in bit_region do
     b.bit = not b.bit
   end
end

task main()
     var size = 60
     var num_pieces = 6
     var bit_region = region(ispace(int1d,size), BitField)

-- To enable parallel computation on regions, Regent has mechanisms for partitioning regions into
-- subregions.  The following call partition's its region argument into num_pieces subregions. Note
-- the result of the call is a partition, which can be thought of as an array of the subregions.

     var bit_region_partition = partition(equal, bit_region, ispace(int1d, num_pieces))

     clear(bit_region)
     printer(bit_region)

     -- Launch a subtask on each subregion.  Partitions know their set of subregions, referred to as 
     -- the set of "colors".
     for c in bit_region_partition.colors do
        blink(bit_region_partition[c])
     end       
     printer(bit_region)
end

regentlib.start(main)
