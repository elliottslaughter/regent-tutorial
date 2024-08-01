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

-- Run this program with a command line like:
--   ./regent.py example4.rg -ll:cpu 4 -ll:util 2
-- On a multicore machine with at least 4 CPUs, you should see a couple of
-- interesting things in the output:
--   * "Task main" is probably printed first --- the main task completes before all or almost all subtasks.
--   * The subtasks do not execute in the order they are issued.
--
import "regent"
local format = require("std/format")

task printer(i : int64)
  format.println("Task {}", i)
end

task main()
  for i = 1, 100 do
    printer(i)
  end
  format.println("Task main")
end

regentlib.start(main)
