#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent pagerank_sol.rg -lg:prof 1 -lg:prof_logfile prof_pagerank_sol_%.gz -ll:cpu 8 -i rmat20.dat -p 8 -ll:dma 2 -e 1e-8 -ll:util 2
