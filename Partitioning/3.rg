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

--
-- Note that passing a partition as an argument also requires that the region from which
-- the partition was created is also passed as an argument so that Regent knows what
-- the privileges will be (the privileges on the parent region apply to any subregions as well).
--
-- The types here are interesting.  In particular, the partition has a type that includes the value
-- of the parent region (another reason knowledge of the parent region is required).
--
-- Finally, one might infer that passing the parent region as an argument is wasteful---do we
-- actually copy the entire parent region to whereever the launcher task runs?!  The answer is no,
-- we don't. Observe that launcher names the parent region as an argument but it isn't used in
-- the body --- only the subregions are actually referred to.  The Regent implementation makes a 
-- distinction between naming a region and using its contents, and in this case the Regent compiler
-- will infer that it does not need a copy of the br region to run the launcher task.
--
task launcher(br: region(ispace(int1d), BitField), p: partition(disjoint, br, ispace(int1d))) 
where
   reads writes(br.bit)
do
   for c in p.colors do
      blink(p[c])
   end
end

task main()
     var size = 60
     var num_pieces = 6
     var bit_region = region(ispace(int1d,size), BitField)
        
     var bit_region_partition = partition(equal, bit_region, ispace(int1d, num_pieces))  

     clear(bit_region)

     for i = 0,4 do
       launcher(bit_region, bit_region_partition)
     end
     printer(bit_region)
end

regentlib.start(main)
