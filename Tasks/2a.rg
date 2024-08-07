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

task summer(lim : int64)
  var sum : int64 = 0
  for i = 1, lim do
    sum += i
  end
  format.println("Summer is done!")
  return sum
end

-- Just making the point that subtasks can also launch subtasks ...
task subtracter(input : int64)
  format.println("Subtracter is done!")
  return input - 3
end

task tester(sum : int64)
  if sum >= 40 then
    sum = subtracter(sum)
  elseif sum <= 30 then
    sum = 0
  else
    sum += 3
  end
  format.println("Tester is done!")
  return sum
end

-- A main task with two subtasks
task main()
  var sum = summer(10)
  sum = tester(sum)
  format.println("Main is done!")
end

regentlib.start(main)
