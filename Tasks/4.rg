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

-- Run this program with a command line like:
--   ./regent.py example5.rg -ll:cpu 4
-- On a multicore machine with at least 4 CPUs, you should see 
--   * "Task main" is printed close to the beginning --- the main task completes before all or almost all subtasks.
--   * Negative subtasks execute after their corresponding positive subtasks.  The Regent system automatically detects
--     that there is a dependency between them and does not start the negative subtask until the result of the positive
--     subtask is available
--   * Positive subtasks have no dependencies between them and run in an unpredictable order with respect to each other;
--     similarly for negative subtasks.
--
import "regent"
local c = regentlib.c

task printer(i: int64)
     c.printf("Task %d\n", i)
     return i
end

task main()
     for i = 1, 100 do
       var j: int64
       j = printer(i)  -- positive subtask
       printer(-j)     -- negative subtask
     end
     c.printf("Task main\n")
end

regentlib.start(main)