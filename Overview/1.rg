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

-- Some Lua code to import the regent library and include interfaces for standard C functions.
import "regent"
local c = regentlib.c

-- Tasks always begin with the keyword "task".  Tasks are Regent code, written in Regent syntax.
task main()
     c.printf("The answer is 42\n")
end

-- This the (Lua) command that kicks off the top-level task.
regentlib.start(main)