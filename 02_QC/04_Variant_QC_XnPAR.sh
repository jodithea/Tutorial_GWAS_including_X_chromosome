#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script carries out variant level QC on the non-pseudoautosomal region (nPAR) of the X chromosome (coded as 23 or X in plink)
# Identify variants with MAF < 1% and call rate < 95% in each sex separately, and filter variants that are below cut-offs in at least one sex
# Filter variants with hardy weinburg equilibrium p < 10-6 in females only

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc2 \
 --chr X \
 --filter-females \
 --maf 0.01 \
 --geno 0.05 \
 --hwe 0.000001 \
 --write-snplist \
 --out 02_QC/Lists/list_snps_to_keep_chrX_females

plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc2 \
 --chr X \
 --filter-males \
 --maf 0.01 \
 --geno 0.05 \
 --write-snplist \
 --out 02_QC/Lists/list_snps_to_keep_chrX_males

# Only keep SNPs that pass filters in both sexes
sort 02_QC/Lists/list_snps_to_keep_chrX_females.snplist \
 02_QC/Lists/list_snps_to_keep_chrX_males.snplist \
 | uniq -d > \
 02_QC/Lists/list_snps_to_keep_chrX.txt

plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc2 \
 --chr X \
 --extract 02_QC/Lists/list_snps_to_keep_chrX.txt \
 --make-bed \
 --out 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc1
