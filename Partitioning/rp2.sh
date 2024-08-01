#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent 2.rg -lg:prof 1 -lg:prof_logfile prof2_%.gz -ll:cpu 4
