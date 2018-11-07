#!/bin/bash
#SBATCH --partition=aaiken
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:4
#SBATCH --exclusive
#SBATCH --time=00:05:00

source /home/groups/aaiken/eslaught/tutorial/env.sh

srun regent pagerank_sol.rg -hl:prof_logfile prof_%.gz -lg:prof 1 -ll:cpu 8 -i rmat20.dat -p 8 -ll:dma 2 -e 1e-8 -ll:util 2
