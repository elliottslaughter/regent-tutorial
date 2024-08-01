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

-- This example illustrates some basic Regent syntax.
--   * The declaration of a local variable "sum".  Note that Regent
--     has type inference so the type declaration is optional if an
--     initial value is provided.  The type is shown here so you can
--     see what the syntax for this is.
--   * A simple "for" loop.  Note the iteration variable is implicitly
--     declared and the type is omitted.  The end of the body of the
--     "for" loop is marked with the keyword "end".
--   * An "if" statement, with "elseif" and "else" branches.  This
--     "if" is particularly silly, as only the first branch is ever
--     taken.  An "if" is also closed by an "end".

task main()
  var sum : int64 = 0
  for i = 1, 10 do
    sum += i
  end
  if sum >= 40 then
    sum -= 3
  elseif sum <= 30 then
    sum = 0
  else
    sum += 3
  end
  format.println("The answer is {}", sum)
end

regentlib.start(main)
