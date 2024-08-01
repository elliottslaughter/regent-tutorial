#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --time=00:05:00

srun regent pagerank_sol.rg -i rmat20.dat -p 8 -e 1e-8 -lg:prof 1 -lg:prof_logfile prof_pagerank_sol_%.gz -ll:cpu 8 -ll:util 2 -ll:bgwork 2
