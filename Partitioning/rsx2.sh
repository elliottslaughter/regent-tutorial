#!/bin/bash -l
#
#PBS -l nodes=1
#PBS -l walltime=00:05:00
#PBS -d .

regent x2.rg  -logfile $PBS_O_WORKDIR/spy0 -hl:spy 1 -ll:cpu 4


