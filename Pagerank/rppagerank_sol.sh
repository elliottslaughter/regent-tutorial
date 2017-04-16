#!/bin/bash -l
#
#PBS -l nodes=1
#PBS -l walltime=00:05:00
#PBS -d .

regent pagerank_sol.rg -logfile $PBS_O_WORKDIR/prof0 -hl:prof 1 -ll:cpu 8 -i rmat20.dat -p 8


