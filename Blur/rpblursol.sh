#!/bin/bash -e
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent_release blur_solution.rg -i images/earth.png -p 8 -ll:cpu 4 -lg:prof 1 -lg:prof_logfile prof_blur_sol_%.gz
