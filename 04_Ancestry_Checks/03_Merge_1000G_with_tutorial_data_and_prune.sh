#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l mem=50GB
#PBS -l ncpus=1
#PBS -J 1-22

# This script merges our tutorial genotype data with the 1000 Genomes reference genotype data
# Autosomes only as this is what we'll use to look at ancestry

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

chr="${PBS_ARRAY_INDEX}"

### Submit script ###

cd ${directory}

mkdir -p 04_Ancestry_Checks/Merged_study_and_1000G/

# 1) Merge tutorial genotype data with 1000G refernece genotype data
plink --bfile 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX-updated-chr${chr} \
 --bmerge 04_Ancestry_Checks/1000G_data/Duplicates_removed/Plink_format/chr${chr} \
 --make-bed \
 --out 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_chr${chr}

# 2) Prune SNPs
# Keep only high quality SNPs not in LD (only use these pruned SNPs for calculating PCs)
plink --bfile 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_chr${chr} \
 --maf 0.05 \
 --geno 0.05 \
 --indep-pairwise 50 5 0.2 \
 --make-bed \
 --out 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_chr${chr}_filtered

