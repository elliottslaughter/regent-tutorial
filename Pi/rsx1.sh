#!/bin/bash -e
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent x1.rg -ll:cpu 4 -lg:spy -logfile spy0_%.log
