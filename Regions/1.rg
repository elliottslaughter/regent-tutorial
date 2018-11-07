-- Copyright 2018 Stanford University
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

-- A field space is a list of fields, much like a struct in C (and similar to structs in Regent,
-- which we don't illustrate here.)
fspace BitField
{
  bit : bool,
}

task main()
  var size = 10

  -- An index space is a set of indices, which we also call points.  The ispace function takes a type (in this
  -- case 1-dimensional integers) and an integer i and creates a dense index space with the indies 0..i-1.
  -- Not illustrated are analagous ways to create 2- and 3-dimensional index spaces.
  --
  -- Dense index spaces created using ispace are called structured index spaces.

  var bit_indices = ispace(int1d, size)

  -- A region is the cross-product of an index space and a field space.  A region can be visualized as a table, with
  -- the rows being named by indices and one column for each field.  A particular point in the index space and a specific
  -- field address one entry in the region.  In this case, the region is a vector of bits of size "size".

  var bit_region = region(bit_indices, BitField)

  -- Here is one style for iterating over the elements (the rows) of a region.

  for b in bit_region do
    b.bit = false
  end

  c.printf("The bits are: ")

  -- Here is another way to iterate over regions.  Regions with structured index spaces have a field
  --  "bounds" with an upper and lower limit.  Bounds is a struct
  -- with two fields, "lo" and "hi".   In this example these fields are of type int1d, which can be cast
  -- to an integer to use in a for loop to iterate over the indices of the region.

  var limits = bit_region.bounds
  for i = [int](limits.lo), [int](limits.hi) + 1 do
    if bit_region[i].bit then
      c.printf("1 ")
    else
      c.printf("0 ")
    end
  end
  c.printf("\n")
end

regentlib.start(main)
