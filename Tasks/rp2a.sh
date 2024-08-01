#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent 2a.rg -lg:prof 1 -lg:prof_logfile prof2a_%.gz -ll:cpu 4
