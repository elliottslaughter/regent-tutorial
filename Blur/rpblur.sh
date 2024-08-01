#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent blur.rg -lg:prof 1 -lg:prof_logfile prof_blur_%.gz -ll:cpu 4 -i images/earth.png -p 8
