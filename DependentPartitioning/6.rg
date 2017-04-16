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

fspace Node {
 id: int64
}

fspace Edge(r: region(Node)) {
    source_node : ptr(Node, r),
    dest_node: ptr(Node, r)
}

task main()
   var Num_Parts = 4
   var Num_Elements = 20

   var nodes = region(ispace(ptr, Num_Elements), Node)
   var edges = region(ispace(ptr, Num_Elements), Edge(nodes))

   for i = 0, Num_Elements do
        var node = new(ptr(Node, nodes))
	node.id = i
   end

   for n in nodes do
      for m in nodes do
         if m.id == n.id + 1 then
            var edge = new(ptr(Edge(nodes), edges))
            edge.source_node = n
            edge.dest_node = m
         end
      end
   end

   var colors = ispace(int1d, Num_Parts)
   var edge_partition = partition(equal, edges, colors)

   for color in edge_partition.colors do
     c.printf("Edge subregion %d: ", color)
     for e in edge_partition[color] do
        c.printf("(%d,%d) ", e.source_node.id, e.dest_node.id)
     end
     c.printf("\n")
   end

   var node_partition_upper = image(nodes, edge_partition, edges.dest_node)
   var node_partition_lower = image(nodes, edge_partition, edges.source_node)
   --
   -- In this example we create a subregion of nodes consisting of those nodes
   -- that are both source and destination nodes in the corresponding edges subregion.
   --
   var private_nodes_partition = node_partition_upper & node_partition_lower 

   for color in private_nodes_partition.colors do
     c.printf("Node subregion %d: ", color)
     for n in private_nodes_partition[color] do
        c.printf("%d ", n.id)
     end
     c.printf("\n")
   end




end
  
regentlib.start(main)