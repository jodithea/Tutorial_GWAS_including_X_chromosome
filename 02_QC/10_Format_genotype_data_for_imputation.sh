#!/bin/bash
#PBS -l walltime=00:20:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script formats the final genotype files to upload to the Michigan Imputations Server

### Environment ###

module load plink/1.90b7
module load vcftools/0.1.16

### Preamble ###

# # Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

mkdir -p 02_QC/Final_genotype_data_for_imputation/

# VCF files (1 per chromosome): sort variants by genomic position and zip
for i in {1..23}; do
	vcf-sort 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX-updated-chr"$i".vcf | \
	bgzip -c > 02_QC/Final_genotype_data_for_imputation/Genotypes_chr"$i"_for_imputation.vcf.gz
done
