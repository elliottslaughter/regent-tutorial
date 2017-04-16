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

-- This example moves the initialization and printing of the region into tasks.

--
-- Tasks that use regions must declare their privileges on the region's fields, which describe
-- how the task will use each field.  The clear task just writes to the bit field of the region.
-- Privileges are type checked by the Regent compiler: the task body and any subtasks called by the
-- task can only use the declared privileges.
--
-- Note the ttype of the region includes the types of the index and field spaces.
--
task clear(bit_region: region(ispace(int1d), BitField))
where
    writes(bit_region.bit)
do
   for b in bit_region do
      b.bit = false
   end
end

--
-- The printer task reads the bit field of the region.
--
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

task main()
     var size = 10
     var bit_region = region(ispace(int1d,size), BitField)
          
     clear(bit_region)
     printer(bit_region)
end

regentlib.start(main)
