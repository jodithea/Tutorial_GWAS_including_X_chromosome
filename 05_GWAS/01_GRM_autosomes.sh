#!/bin/bash
#PBS -l walltime=00:20:00
#PBS -l mem=1GB
#PBS -l ncpus=5

# This script uses the GCTA package to create a Genetic Relationship Matrix (GRM)
# We create this GRM only using a set of directly genotyped SNPs from the autosomes that have been filtered
# The GRM calculation in GCTA is not suitable for cross-ancestry data (inflated relationship coefficients will arise in this case)
# Thus only use SNPs from your ancestry of interest - here we are using European individuals only

### Environment ###

module load plink/1.90b7
module load GCTA/1.94.1


### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/mnt/backedup/home/jodiT/Working/Tutorial_GWAS_including_X_chromosome/
# Add filename including the list of individuals within your ancestry of interes, as created in 04_Ancestry_Checks
list_ancestry_individuals=04_Ancestry_Checks/PCA_data/EUR_IDs_3SD.txt


### Submit script ###

cd ${directory}

mkdir 05_GWAS/GRM/

# 1) Filter autosomal directly genotyped SNPs (i.e. before imputation)
# Filter on MAF of 0.01, geno 0.02, mind 0.02, hwe 0.0000000001 and LD pruning:  window size = 1500kb; step size (variant ct) = 150; r^2 threshold = 0.2
plink --bfile 01_Genotype_Data/Genotypes_all_chr \
 --chr 1-22 \
 --maf 0.01 \
 --geno 0.02 \
 --mind 0.02 \
 --hwe 0.0000000001 \
 --indep-pairwise 1500 150 0.2 \
 --out 05_GWAS/GRM/Directly_genotyped_SNPs_filtered_autosomes

# Outputs:
# *.prune.in = list of SNPs that have passed thresholds
# *.prune.out = list of SNPs that didn't pass the thresholds


# 2) Now create GRM using this filtered set of autosomal SNPs, using European individuals only
gcta-1.94.1 \
 --bfile 01_Genotype_Data/Genotypes_all_chr \
 --keep ${list_ancestry_individuals} \
 --extract 05_GWAS/GRM/Directly_genotyped_SNPs_filtered_autosomes.prune.in \
 --make-grm  \
 --thread-num 5 \
 --out 05_GWAS/GRM/GRM_autosomes

# GRM outputs:
# "grm.bin": the actual binary file containing the GRM elements. 
# "grm.N.bin": contains information about how many genetic markers were used to calculate the GRM. 
# "grm.id": a text file containing two columns of data, respectively, the participant family and individual IDs.
