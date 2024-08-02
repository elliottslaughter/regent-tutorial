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

fspace Node
{
  id : int64,
  color: int1d,
}

fspace Edge
{
  source_node : int1d,
  dest_node   : int1d,
}

task main()
  var Num_Parts = 4
  var Num_Elements = 20

  var nodes = region(ispace(int1d, Num_Elements), Node)
  var edges = region(ispace(int1d, Num_Elements - 1), Edge)

  --
  -- The Nodes field space now includes a coloring field.  The following
  -- loop assigns colors in round-robin fashion.
  --
  for i = 0, Num_Elements do
    nodes[i].id = i
    nodes[i].color = i % Num_Parts
  end

  for j = 0, Num_Elements - 1 do
    edges[j].source_node = j
    edges[j].dest_node   = j + 1
  end

  --
  -- Partition the nodes using the coloring field.
  --
  var colors = ispace(int1d, Num_Parts)
  var node_partition = partition(nodes.color, colors)

  for color in node_partition.colors do
    format.print("Node subregion {}: ", color)
    for n in node_partition[color] do
      format.print("{2} ", n.id)
    end
    format.println("")
  end
end

regentlib.start(main)
