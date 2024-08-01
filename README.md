# Introduction to the Legion Programming Model

## Setup Instructions

Basic sanity check that everything works:

```bash
ssh USERNAME@sapling.stanford.edu
git clone https://github.com/elliottslaughter/regent-tutorial.git tutorial
cd tutorial
source env.sh
cd Overview
sbatch r1.sh
squeue --me # wait until it shows the job has completed
less slurm-*.out
```

## Editor Support for Regent Syntax

Emacs:

```bash
mv -f ~/.emacs ~/.emacs.backup
ln -s /home/groups/aaiken/eslaught/econf/quickstart.el ~/.emacs
```

Vim:

```bash
mkdir -p ~/.vim/syntax
wget -O ~/.vim/syntax/regent.vim https://raw.githubusercontent.com/StanfordLegion/regent.vim/master/regent.vim
echo "au BufNewFile,BufRead *.rg set filetype=regent" >> ~/.vimrc
```

## Running Legion Prof

```bash
cd tutorial/Tasks
make clean
sbatch rp1.sh
squeue --me # wait for this to complete
legion_prof_to_public_html
```

Open the resulting link in your web browser.

## Running Legion Spy

```bash
cd tutorial/Tasks
make clean
sbatch rs4.sh
squeue --me # wait for this to complete
legion_spy_to_public_html
```

Open the resulting link in your web browser.

## Alternatives to SCP

SSHFS:

```bash
mkdir tutorial
sshfs USERNAME@sapling.stanford.edu:tutorial tutorial
```

Cyberduck: https://cyberduck.io/

## Links

  * [Legion home page](http://legion.stanford.edu)
  * [Regent home page](http://regent-lang.org/)
  * Tutorial slides (TBD)
  * PageRank example:
      * [pagerank\_baseline.rg](https://gitlab.com/StanfordLegion/legion/raw/master/language/examples/pagerank/pagerank_baseline.rg)
