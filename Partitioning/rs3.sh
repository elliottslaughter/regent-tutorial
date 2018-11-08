#!/bin/bash
#SBATCH --partition=aaiken
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:4
#SBATCH --exclusive
#SBATCH --time=00:05:00

source /home/groups/aaiken/eslaught/tutorial/env.sh

srun regent 3.rg -logfile spy3_%.log -lg:spy 1 -ll:cpu 4
