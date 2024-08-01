#!/bin/bash
#SBATCH --partition=all
#SBATCH --tasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=10
#SBATCH --time=00:05:00

srun regent x2.rg -logfile spyx2_%.log -lg:spy 1 -ll:cpu 4
