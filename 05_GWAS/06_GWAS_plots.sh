#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l mem=20GB
#PBS -l ncpus=1

# This script creates Manhattan and QQ Plots (including lambda value) from the GWAS summary statistics 

### Environment ###

module load R/4.5.0


### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/mnt/backedup/home/jodiT/Working/Tutorial_GWAS_including_X_chromosome/
# p-value threshold for GWAS (where horizontal line will be placedon manhattan plot)
p_threshold=5e-08
# name of your input GWAS summary statistics file
input=GWAS_autosomes_X_nodc.txt
output=${input%.txt}


### Run script ###

cd ${directory}05_GWAS/

Rscript --vanilla 06_GWAS_plots.R GWAS/${input} GWAS/${output} ${p_threshold} 

