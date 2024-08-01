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
local c = regentlib.c

-- To improve parallelism of example6.rg, subtasks now carry out many iterations of the
-- simulation independently.  The important aspect here is that the results of one subtask
-- are not needed until all the subtasks have completed, which allows the Regent runtime to
-- issue all the subtasks before performing the sum.

task hits(iterations : int64)
  var total: int64 = 0
  for i = 1, iterations do
    var x : double = c.drand48()
    var y : double = c.drand48()
    if (x * x) + (y * y) <= 1.0 then
     	total = total + 1
    end
  end
  return total
end

task main()
  var iterations : int64 = 2500

  var hits1 = hits(iterations)
  var hits2 = hits(iterations)
  var hits3 = hits(iterations)
  var hits4 = hits(iterations)
  var totalhits = hits1 + hits2 + hits3 + hits4
  format.println("The area of a unit circle is approximately: {5.4}", totalhits / [double](iterations))
end

regentlib.start(main)
