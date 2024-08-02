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

fspace Edge(r : region(ispace(int1d), Node))
{
  source_node : int1d(Node, r),
  dest_node   : int1d(Node, r),
}

--
-- Control replication works best if we factor the program into
-- tasks. Therefore we'll split up the main pieces here for execution.
--

task init_nodes(nodes : region(ispace(int1d), Node),
                Num_Elements : int)
where
  reads writes(nodes)
do
  for i = 0, Num_Elements do
    nodes[i].id = i
  end
end

task init_edges(nodes : region(ispace(int1d), Node),
                edges : region(ispace(int1d), Edge(nodes)),
                Num_Elements : int)
where
  reads writes(edges)
do
  for j = 0, Num_Elements - 1 do
    edges[j].source_node = dynamic_cast(int1d(Node, nodes), j)
    edges[j].dest_node   = dynamic_cast(int1d(Node, nodes), j + 1)
  end
end

task print_edges(nodes : region(ispace(int1d), Node),
                 edges : region(ispace(int1d), Edge(nodes)),
                 color : int1d)
where
  reads(nodes, edges)
do
  format.print("Edge subregion {}: ", color)
  for e in edges do
    format.print("({2}, {2}) ", nodes[e.source_node].id, e.dest_node.id)
  end
  format.println("")
end

task print_nodes(nodes : region(ispace(int1d), Node), color : int1d)
where
  reads(nodes)
do
  format.print("Node subregion {}: ", color)
  for n in nodes do
    format.print("{2} ", n.id)
  end
  format.println("")
end

--
-- Declare a control replicated task with `__demand(__replicate)`. The
-- compiler will throw an error if the optimization cannot be proven to be
-- safe. It is a defensive programming practice to annotate tasks with the
-- optimizations you think will apply, so that the compiler can check your
-- assumptions.
--
-- The `__demand(__inner)` is optional but helpful, and ensures the task does
-- not attempt to directly access global data (a potential scalability
-- hazard).
--

__demand(__replicable, __inner)
task main()
  -- This task will run on multiple nodes. The OPERATIONS launched by this
  -- task will appear to execute once only.

  var Num_Parts = 4
  var Num_Elements = 20

  -- The format library is safe to use in control replication, and will print
  -- exactly once.
  format.println("Running with {} elements and {} subregions",
                 Num_Elements, Num_Parts)

  -- We can allocate regions, etc. as normal.
  var nodes = region(ispace(int1d, Num_Elements), Node)
  var edges = region(ispace(int1d, Num_Elements - 1), Edge(nodes))

  -- Perform initialization in a subtask: do not access the data directly.
  init_nodes(nodes, Num_Elements)
  init_edges(nodes, edges, Num_Elements)

  -- Partition as normal.
  var colors = ispace(int1d, Num_Parts)
  var edge_partition = partition(equal, edges, colors)

  -- Here we do an index launch. This is a parallel task launch that the
  -- runtime can analyze in O(1) time. Again, the compiler will check all the
  -- necessary invariants to make sure this is safe.
  __demand(__index_launch)
  for color in edge_partition.colors do
    print_edges(nodes, edge_partition[color], color)
  end

  var node_partition = image(nodes, edge_partition, edges.source_node)

  for color in node_partition.colors do
    print_nodes(node_partition[color], color)
  end
end

regentlib.start(main)
