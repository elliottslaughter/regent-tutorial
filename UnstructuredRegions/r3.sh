#!/bin/bash -e
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00

srun regent 3.rg
