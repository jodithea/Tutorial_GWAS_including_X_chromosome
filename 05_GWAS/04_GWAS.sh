#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l mem=10GB
#PBS -l ncpus=5

# This script uses fastGWA in the GCTA package to run a GWAS
# Use the sparse GRM output form the previous script to account for relatedness
# --fastGWA-mlm-binary is used for a binary outcome (outputs effect size on the log-odds scale). Change to --fastGWA-mlm for a continuous outcome.
# For autosomes (chr 1 - 22) and X chromosome

### Environment ###

module load GCTA/1.94.1


### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Sparse GRM file
sparseGRM=Sparse_GRM_autosomes
# Add filename including the list of individuals within your ancestry of interest, as created in 04_Ancestry_Checks with the standard devidation threshold chosen
list_ancestry_individuals=04_Ancestry_Checks/PCA_data/EUR_IDs_5SD.txt
# Phenotype file in format FID IID phenotype. No headers. For binary phenotypes use cases = 1, controls = 0
# This phenotype file is provided as part of the tutorial in the directory '01_Phenotype_Data'
pheno=01_Phenotype_Data/pheno.txt
# Quantitative covariate file in format FID IID quantitative_covars - e.g. FID IID PC1 PC2 PC3 PC4. No headers.
qcovar=05_GWAS/Files_for_GWAS/qcovar_PCs.txt
# Categorical covariate file in format FID IID categorical_covars - e.g. FID IID Sex. No headers.
covar=05_GWAS/Files_for_GWAS/covar_sex.txt
# Name of GWAS output file
output=GWAS


### Submit script ###

cd ${directory}

mkdir 05_GWAS/GWAS/

# 1)  Save the estimated fastGWA model parameters from an analysis for a binary outcome with the autosomes, restricted to European ancestry only
gcta-1.94.1 --mbfile ${directory}05_GWAS/Files_for_GWAS/list_autosomes_genotype_data.txt \
 --grm-sparse 05_GWAS/GRM/${sparseGRM} \
 --model-only \
 --fastGWA-mlm-binary \
 --keep ${list_ancestry_individuals} \
 --pheno ${pheno} \
 --qcovar ${qcovar} \
 --covar ${covar} \
 --thread-num 5 \
 --out 05_GWAS/GWAS/${output}_modelonly

# 2) Load the saved model above to run association tests for autosomes
gcta-1.94.1 --mbfile ${directory}05_GWAS/Files_for_GWAS/list_autosomes_genotype_data.txt \
 --grm-sparse 05_GWAS/GRM/${sparseGRM} \
 --load-model 05_GWAS/GWAS/${output}_modelonly.fastGWA \
 --thread-num 5 \
 --out 05_GWAS/GWAS/${output}_autosomes

# 3) Load the saved model above to run association tests for ChrX nPAR: full dosage compensation
gcta-1.94.1 --bfile ${directory}03_Imputation/Genotype_imputation_results/chrX_nPAR_filtered \
 --grm-sparse 05_GWAS/GRM/${sparseGRM} \
 --load-model 05_GWAS/GWAS/${output}_modelonly.fastGWA \
 --dc 1 \
 --thread-num 5 \
 --out 05_GWAS/GWAS/${output}_chrX_nPAR_fulldc

# 4) Load the saved model above to run association tests for ChrX nPAR: no dosage compensation
gcta-1.94.1 --bfile ${directory}03_Imputation/Genotype_imputation_results/chrX_nPAR_filtered \
 --grm-sparse 05_GWAS/GRM/${sparseGRM} \
 --load-model 05_GWAS/GWAS/${output}_modelonly.fastGWA \
 --dc 0 \
 --thread-num 5 \
 --out 05_GWAS/GWAS/${output}_chrX_nPAR_nodc

#  Load the saved model above to run association tests for ChrX PAR (no dosage compensation specification needed, treat like autosomes)
gcta-1.94.1 --bfile ${directory}03_Imputation/Genotype_imputation_results/chrX_PAR_filtered \
 --grm-sparse 05_GWAS/GRM/${sparseGRM} \
 --load-model 05_GWAS/GWAS/${output}_modelonly.fastGWA \
 --thread-num 5 \
 --out 05_GWAS/GWAS/${output}_chrX_PAR


# Columns in output summary stats
#  CHR: chromosome
#  SNP: SNP
#  POS: SNP position
#  A1: effect allele
#  A2: other allele
#  N: per allele sample size
#  AF1: frequency of A1 (effect allele)
#  BETA: SNP effect
#  SE: standard error
#  P: p-value

