#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script splits the X chromosome into non-pseudoautosomal region (nPAR) (coded as CHR 23) and pseudoautosomal region (PAR) (coded as CHR 25)
# And merge all individual chomosome genotype data files into one file set (bed/bim/fam) containing all chromosomes

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}


# Split chromosome X
plink --bfile 01_Genotype_Data/Genotypes_chrX \
 --split-x b37 \
 --make-bed \
 --out 01_Genotype_Data/Genotypes_chrX_split

# Create list of all genotype data filenames
> 01_Genotype_Data/list_merge_genotype_data.txt   # clear file
for i in {2..22}; do
  echo "01_Genotype_Data/Genotypes_chr${i}" >> 01_Genotype_Data/list_merge_genotype_data.txt
done
echo "01_Genotype_Data/Genotypes_chrX_split" >> 01_Genotype_Data/list_merge_genotype_data.txt

# Merge genotype data files from all chromosomes into one
plink --bfile 01_Genotype_Data/Genotypes_chr1 \
 --merge-list 01_Genotype_Data/list_merge_genotype_data.txt \
 --make-bed \
 --out 01_Genotype_Data/Genotypes_all_chr
