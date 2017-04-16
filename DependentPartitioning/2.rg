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

--
-- In this example, we first partition the edges into a number
-- of subregions.
--
   var colors = ispace(int1d, Num_Parts)
   var edge_partition = partition(equal, edges, colors)

   for color in edge_partition.colors do
     c.printf("Edge subregion %d: ", color)
     for e in edge_partition[color] do
        c.printf("(%d,%d) ", e.source_node.id, e.dest_node.id)
     end
     c.printf("\n")
   end

--
-- node_partition is a dependent partition, collecting all the source nodes
-- into a given subregion of edges into a corresponding subregion of nodes.
--
   var node_partition = image(nodes, edge_partition, edges.source_node)

   for color in node_partition.colors do
     c.printf("Node subregion %d: ", color)
     for n in node_partition[color] do
        c.printf("%d ", n.id)
     end
     c.printf("\n")
   end




end
  
regentlib.start(main)