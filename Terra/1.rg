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

-- To improve the performance of example7.rg, we now write the computational
-- leaf task as a terra function.  Terra is targeted at producing high performance
-- sequential code and has extensive support for vector intrinsics (not illustrated
-- in this example).  The basic syntax of Regent and Terra is similar; in fact, for
-- this function all we need to do is change the keyword "task" to "terra".

terra hits(iterations: int64)
     var total: int64 = 0
     for i = 1, iterations do
          var x: double = std.drand48()
     	  var y: double = std.drand48()
          if (x * x) + (y * y) <= 1.0 then
     	     total = total + 1
          end
     end
     return total
end

task main()

     var iterations: int64 = 2500
     
     var hits1 = hits(iterations)
     var hits2 = hits(iterations)
     var hits3 = hits(iterations)
     var hits4 = hits(iterations)
     var totalhits = hits1 + hits2 + hits3 + hits4
     c.printf("The area of a unit circle is approximately: %5.4f\n", totalhits / float(iterations))
end

regentlib.start(main)
