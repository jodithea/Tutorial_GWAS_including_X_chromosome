#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=5GB
#PBS -l ncpus=1

# This script merges the imputed genotype data files from each chomosome into one file set (bed/bim/fam) containing all chromosomes

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}03_Imputation/Genotype_imputation_results/


# Create list of all genotype data filenames
> list_merge_genotype_data.txt   # clear file
for i in {2..22}; do
  echo "chr${i}_filtered" >> list_merge_genotype_data.txt
done
echo "chrX_filtered" >> list_merge_genotype_data.txt

# Merge genotype data files from all chromosomes into one
plink --bfile chr1_filtered \
 --merge-list list_merge_genotype_data.txt \
 --make-bed \
 --out all_chr_filtered
