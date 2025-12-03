#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script creates a file with sex for each individual to be used in plink when making bed/bim/fam files
# Needs 3 cols: FID and IID and sex (1 or M = male, 2 or F = female, 0 = missing)

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}03_Imputation/Genotype_imputation_results/

awk '{print $1,$2,$5}' ${directory}01_Genotype_Data/Genotypes_all_chr.fam > sex_data.txt
