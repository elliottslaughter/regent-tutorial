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

fspace IntField
{
  i : int32,
}

task clear(int_region : region(ispace(int1d), IntField))
where
  writes(int_region.i)
do
  for x in int_region do
    x.i = 0
  end
end

--
-- The inc task both reads and writes the region.
--
task inc(int_region : region(ispace(int1d), IntField))
where
  reads writes(int_region.i)
do
  for j = 0, 1000 do
    for x in int_region do
      x.i += 1
    end
  end
end

task main()
  var size = 10000
  var int_region = region(ispace(int1d, size), IntField)

  clear(int_region)
  for i = 0, 5 do
    inc(int_region)
  end
end

regentlib.start(main)
