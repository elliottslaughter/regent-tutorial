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
}

--
-- A parameterized field space is a function, creating a different
-- field space for each distinct argument.
--
fspace Edge(r : region(ispace(int1d), Node))
{
  source_node : int1d(Node, r),
  dest_node   : int1d(Node, r),
}

task main()
  var Num_Parts = 4
  var Num_Elements = 20

  --
  -- The edges region references the nodes: note the type is
  -- `Edges(nodes)`, i.e., edges into the nodes region.
  --
  var nodes = region(ispace(int1d, Num_Elements), Node)
  var edges = region(ispace(int1d, Num_Elements - 1), Edge(nodes))

  --
  -- Initialize the nodes. Every node contains a unique ID.
  --
  for i = 0, Num_Elements do
    nodes[i].id = i
  end

  --
  -- Create a linked list of the nodes, with an edge from node i to
  -- node i + 1.
  --
  for j = 0, Num_Elements - 1 do
    edges[j].source_node = dynamic_cast(int1d(Node, nodes), j)
    edges[j].dest_node   = dynamic_cast(int1d(Node, nodes), j + 1)
  end

  --
  -- Regent automatically dereferences the indices on access; the
  -- compiler knows that `edge.source_node` refers to an element of
  -- the `nodes` regions.
  --
  for edge in edges do
    format.println("Edge from node {2} to {2}", edge.source_node.id, edge.dest_node.id)
  end
end

regentlib.start(main)
