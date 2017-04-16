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

--
-- A parameterized field space is a function, creating a 
-- different field space for each distinct argument.
--
fspace Edge(r: region(Node)) {
    source_node : ptr(Node, r),
    dest_node: ptr(Node, r)
}

task main()
   var Num_Parts = 4
   var Num_Elements = 20

--
-- Both the node and edge regions are unstructured --- the
-- index space is an abstract "pointer".  Note unstructured
-- index spaces still have a maximum size.
--
   var nodes = region(ispace(ptr, Num_Elements), Node)
   var edges = region(ispace(ptr, Num_Elements), Edge(nodes))

   for i = 0, Num_Elements do
--  Elements of unstructured regions have to be allocated before
--  they can be used.  The "new" operator returns a previously
--  unallocated element of the region.
        var node = new(ptr(Node, nodes))
	node.id = i
   end

--
-- Create a linked list of the nodes, with an edge from node i to node i + 1
--
   for n in nodes do
      for m in nodes do
         if m.id == n.id + 1 then
            var edge = new(ptr(Edge(nodes), edges))
            edge.source_node = n
            edge.dest_node = m
         end
      end
   end

   for edge in edges do
      c.printf("Edge from node %d to %d\n", edge.source_node.id, edge.dest_node.id)
   end
end
  
regentlib.start(main)