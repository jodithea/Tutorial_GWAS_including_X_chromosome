#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=5GB
#PBS -l ncpus=1

# This script uses our tutorial genotype data merged with the 1000G reference genotype data (autosomes only) and runs PCA using only the pruned SNPs

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

# 1) Create list of all genotype data filenames
> 04_Ancestry_Checks/Merged_study_and_1000G/list_merge_genotype_data.txt   # clear file
for i in {2..22}; do
  echo "04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_chr${i}_filtered" >> 04_Ancestry_Checks/Merged_study_and_1000G/list_merge_genotype_data.txt
done

# 2) Merge genotype data files from all chromosomes into one
plink --bfile 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_chr1_filtered \
 --merge-list 04_Ancestry_Checks/Merged_study_and_1000G/list_merge_genotype_data.txt \
 --make-bed \
 --out 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_autosomes_filtered

# 3) Run PCA, using merged 1000G + tutorial genotype data for all autosomes, only pruned SNPs
plink --bfile 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_autosomes_filtered \
 --pca \
 --out 04_Ancestry_Checks/Merged_study_and_1000G/Genotypes_study_and_1000G_autosomes_filtered_pca


