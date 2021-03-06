# Introduction to the Legion Programming Model

## Setup Instructions

Basic sanity check that everything works:

```
ssh SUNetID@login.sherlock.stanford.edu
git clone https://github.com/elliottslaughter/regent-tutorial.git tutorial
cd tutorial/Overview
sbatch r1.sh
squeue -u $(whoami) # wait until it shows the job has completed
less slurm-*.out
```

## Editor Support for Regent Syntax

Emacs:

```
mv -f ~/.emacs ~/.emacs.backup
ln -s /home/groups/aaiken/eslaught/econf/quickstart.el ~/.emacs
```

Vim:

```
mkdir -p ~/.vim/syntax
wget -O ~/.vim/syntax/regent.vim https://raw.githubusercontent.com/StanfordLegion/regent.vim/master/regent.vim
echo "au BufNewFile,BufRead *.rg set filetype=regent" >> ~/.vimrc
```

## Running Legion Prof

```
cd tutorial/Tasks
make clean
sbatch rp1.sh
# wait for this to complete
make prof
```

On your personal machine:

```
scp -r SUNetID@login.sherlock.stanford.edu:tutorial/Tasks/legion_prof .
```

Then open `legion_prof/index.html` in your browser.

## Running Legion Spy

```
cd tutorial/Tasks
make clean
sbatch rs4.sh
# wait for this to complete
make spy
```

On your personal machine:

```
scp SUNetID@login.sherlock.stanford.edu:tutorial/Tasks/*.pdf .
```

Then open the PDF files.

## Alternatives to SCP

SSHFS:

```
mkdir tutorial
sshfs SUNetID@login.sherlock.stanford.edu:tutorial tutorial
```

Cyberduck: https://cyberduck.io/

## Links

  * [Legion home page](http://legion.stanford.edu)
  * [Regent home page](http://regent-lang.org/)
  * [Tutorial slides](http://sapling.stanford.edu/~eslaught/tutorial/tutorial.pdf)
  * PageRank example:
      * [pagerank\_baseline.rg](https://gitlab.com/StanfordLegion/legion/raw/master/language/examples/pagerank/pagerank_baseline.rg)
  * PageRank performance profiles:
      * [1 node, 8 cpus](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_cpu8/?start=125149396.30288485&end=151606741.6373197&collapseAll=false&resolution=10)
      * [1 node, 1 gpu](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_gpu1/?start=29233303.237794884&end=33604068.32550413&collapseAll=false&resolution=10)
      * [1 node, 2 gpus](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_gpu2/?start=29310768.00662945&end=32218582.293001413&collapseAll=false&resolution=10)
      * [1 node, 4 gpus](http://sapling.stanford.edu/~zhihao/pagerank_baseline_node1_gpu4/?start=32152385.0357884&end=34533632.9802233&collapseAll=false&resolution=10)
