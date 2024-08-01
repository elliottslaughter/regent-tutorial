#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent x1.rg -logfile $PBS_O_WORKDIR/spy0 -hl:spy 1 -ll:cpu 4
