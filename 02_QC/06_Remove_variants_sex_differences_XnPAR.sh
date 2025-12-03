#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script removes variants with sex differences in allele frequency and missingness on the non-pseudoautosomal region (nPAR) of the X chromosome (coded as 23 or X in plink)

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Set P-value from Fishers exact test to use as a threshold to remove variants (i.e. variants below this threshold show evidence of sex differneces in MAF/missingness and will be removed)
threshold=0.000001 

### Submit script ###

cd ${directory}

# 1) Create list of SNPs to remove based on chosen p-value threshold for exact fisher test of MAF (column 12) and missingness (column 22)
awk -v thresh="$threshold" '($12 < thresh || $22 < thresh) {print $2}' \
 02_QC/Lists/list_snps_maf_missing_chrX.txt \
 > 02_QC/Lists/list_snps_remove_sex_diff_XnPAR.txt

# 2) Remove these variants on the nPAR of the X chromosome
plink --bfile 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc1 \
 --chr X \
 --exclude 02_QC/Lists/list_snps_remove_sex_diff_XnPAR.txt \
 --make-bed \
 --out 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc2

# Note that no variants have a p-value < 0.000001 for MAF or missingness so no variants are removed
