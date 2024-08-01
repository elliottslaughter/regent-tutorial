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

local c = regentlib.c

fspace Node
{
  id : int64,
}

fspace Edge(r : region(ispace(int1d), Node))
{
  source_node : int1d,
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
    edges[j].source_node = [int1d](j)
    edges[j].dest_node   = dynamic_cast(int1d(Node, nodes), [int1d](j + 1))
  end

  var colors = ispace(int1d, Num_Parts)
  var edge_partition = partition(equal, edges, colors)

  for color in edge_partition.colors do
    c.printf("Edge subregion %ld: ", color)
    for e in edge_partition[color] do
      c.printf("(%2ld, %2ld) ", nodes[e.source_node].id, e.dest_node.id)
    end
    c.printf("\n")
  end

  var node_partition = image(nodes, edge_partition, edges.dest_node)

  for color in node_partition.colors do
    c.printf("Node subregion %ld: ", color)
    for n in node_partition[color] do
       c.printf("%2ld ", n.id)
    end
    c.printf("\n")
  end
end

regentlib.start(main)
