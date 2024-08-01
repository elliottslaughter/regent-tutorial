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

task main()
  var Num_Parts = 4
  var Num_Elements = 20

  var nodes = region(ispace(int1d, Num_Elements), Node)
  var edges = region(ispace(int1d, Num_Elements - 1), Edge(nodes))

  for i = 0, Num_Elements do
    nodes[i].id = i
  end

  for j = 0, Num_Elements - 1 do
    edges[j].source_node = dynamic_cast(int1d(Node, nodes), [int1d](j))
    edges[j].dest_node   = dynamic_cast(int1d(Node, nodes), [int1d](j + 1))
  end

  var colors = ispace(int1d, Num_Parts)
  var edge_partition = partition(equal, edges, colors)

  for color in edge_partition.colors do
    format.print("Edge subregion {}: ", color)
    for e in edge_partition[color] do
      format.print("({2}, {2}) ", nodes[e.source_node].id, e.dest_node.id)
    end
    format.println("")
  end

  var node_partition_upper = image(nodes, edge_partition, edges.dest_node)
  var node_partition_lower = image(nodes, edge_partition, edges.source_node)

  --
  -- Now we construct two partitions: One of the nodes in the interior of each node subregion
  -- (i.e., no nodes connected with a node in another partition) and another of the edges
  -- in each subregion connecting only the private nodes.
  --
  var private_nodes_partition = node_partition_upper & node_partition_lower
  var private_edges_partition_upper = preimage(edges, private_nodes_partition, edges.dest_node)
  var private_edges_partition_lower = preimage(edges, private_nodes_partition, edges.source_node)
  var private_edges_partition = private_edges_partition_upper & private_edges_partition_lower

  for color in private_nodes_partition.colors do
    format.print("Private nodes subregion {}: ", color)
    for n in private_nodes_partition[color] do
      format.print("{2} ", n.id)
    end
    format.println("")
  end

  for color in private_edges_partition.colors do
    format.print("Private edges subregion {}: ", color)
    for e in private_edges_partition[color] do
      format.print("({2},{2}) ", e.source_node.id, e.dest_node.id)
    end
    format.println("")
  end
end

regentlib.start(main)
