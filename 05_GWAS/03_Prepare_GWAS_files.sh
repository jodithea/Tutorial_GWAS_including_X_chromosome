#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l mem=5GB
#PBS -l ncpus=1

# This script prepares files needed to input into fastGWA in the GCTA package to run a GWAS

### Environment ###


### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

mkdir 05_GWAS/Files_for_GWAS/

# 1) Create list of the imputed and filtered genotype filenames for the autosomes
> 05_GWAS/Files_for_GWAS/list_autosomes_genotype_data.txt   # clear file
for i in {1..22}; do
  echo "03_Imputation/Genotype_imputation_results/chr${i}_filtered" >> 05_GWAS/Files_for_GWAS/list_autosomes_genotype_data.txt
done


# 2) Create qcovar file = file with quantitative covariates to include in the GWAS
# In format FID IID quantitative_covars with no headers
# Here we are doing FID IID PC1 PC2 PC3 PC4
awk '{print $1,$2,$3,$4,$5,$6}' 04_Ancestry_Checks/PCA_data/Genotypes_study_filtered_pca.eigenvec > 05_GWAS/Files_for_GWAS/qcovar_PCs.txt


# 3) Create covar file = Categorical covariate file
# In format FID IID categorical_covars with no headers
# Here we are doing FID IID Sex
awk '{print $1,$2,$5}' 03_Imputation/Genotype_imputation_results/all_chr_filtered.fam > 05_GWAS/Files_for_GWAS/covar_sex.txt
