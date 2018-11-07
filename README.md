# Introduction to the Legion Programming Model

## Links

  * [Legion home page](http://legion.stanford.edu)
  * [Regent home page](http://regent-lang.org/)
  * [Tutorial slides](slides.pdf) (TODO)
  * PageRank example:
      * [pagerank\_baseline.rg](https://gitlab.com/StanfordLegion/legion/raw/master/language/examples/pagerank/pagerank_baseline.rg)
  * PageRank performance profiles:
      * [1 node, 8 cpus](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_cpu8/?start=125149396.30288485&end=151606741.6373197&collapseAll=false&resolution=10)
      * [1 node, 1 gpu](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_gpu1/?start=29233303.237794884&end=33604068.32550413&collapseAll=false&resolution=10)
      * [1 node, 2 gpus](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_gpu2/?start=29310768.00662945&end=32218582.293001413&collapseAll=false&resolution=10)
      * [1 node, 4 gpus](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_gpu4/?start=32152385.0357884&end=34533632.9802233&collapseAll=false&resolution=10)

## Setup Instructions

Basic sanity check that everything works:

```
ssh SUNetID@login.sherlock.stanford.edu
source /home/groups/aaiken/eslaught/tutorial/env.sh
salloc --partition=aaiken --tasks 1 --nodes=1 --cpus-per-task=10 --gres=gpu:4 --time=01:00:00
srun regent $EXAMPLES/circuit.rg -ll:gpu 4
```

Running the example code:

```
# Remember to do this inside salloc.
cd $EXAMPLES/pagerank
srun regent pagerank_baseline.rg -graph hollywood.gr -nw 8 -ni 10 -ll:cpu 8 -ll:csize 10000
srun regent pagerank_baseline.rg -graph hollywood.gr -nw 8 -ni 10 -ll:cpu 8 -ll:csize 10000 -ll:gpu 1 -ll:fsize 4096 -ll:zsize 4096
```
