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

-- An example of a subtask: summer is called from within main.
task summer(lim : int64)
  var sum : int64 = 0
  for i = 1, lim do
    sum += i
  end
  c.printf("Summer is done!\n")
  return sum
end

task main()
  var sum = summer(10)
  if sum >= 40 then
    sum -= 3
  elseif sum <= 30 then
    sum = 0
  else
    sum += 3
  end
  c.printf("The answer is: %ld\n", sum)
end

regentlib.start(main)
