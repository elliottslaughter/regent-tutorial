#!/bin/bash -e
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent_release 4.rg -ll:cpu 4 -lg:prof 1 -lg:prof_logfile prof4_%.gz
