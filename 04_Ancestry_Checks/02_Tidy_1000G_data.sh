#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l mem=80GB
#PBS -l ncpus=1
#PBS -J 0-22

# This script cleans the 1000 Genomes Phase 3 genotype data and converts from VCFs to PLINK

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

vcf=(${directory}04_Ancestry_Checks/1000G_data/ALL.chr*.phase3_shapeit2_mvncall_integrated_v*.20130502.genotypes.vcf.gz)
chr=$(basename "${vcf[${PBS_ARRAY_INDEX}]}" | \
      sed 's|ALL.chr||' | \
      sed 's|.phase3_shapeit2_mvncall_integrated_v[0-9A-Za-z.]*.20130502.genotypes.vcf.gz||')

### Submit script ###

cd ${directory}

mkdir -p 04_Ancestry_Checks/1000G_data/Duplicates_removed/
mkdir -p 04_Ancestry_Checks/1000G_data/Duplicates_removed/Plink_format/

cd 04_Ancestry_Checks/1000G_data/

# 1) Remove duplicates 
# Some chromosomes have duplicate variants (same chr, position, ref and alt alleles - not just multiallelic)
# This causes an error when creating variant IDs
# So first remove these duplicate variants from vcf files
(
  zcat ${vcf[${PBS_ARRAY_INDEX}]} | grep '^#'
  zcat ${vcf[${PBS_ARRAY_INDEX}]} | grep -v '^#' \
    | LC_ALL=C sort -t $'\t' -k1,1 -k2,2n -k4,4 \
    | awk -F"\t" 'BEGIN{prev=""} {key=$1"\t"$2"\t"$4; if(key==prev) next; print; prev=key;}'
) > Duplicates_removed/chr${chr}_dedup.vcf

# 2) Convert VCF to PLINK bed/bim/fam format
# Also create variant IDs and restrict to SNPs only
plink --vcf Duplicates_removed/chr${chr}_dedup.vcf \
 --snps-only just-acgt \
 --set-missing-var-ids @:#:\$1:\$2 \
 --make-bed \
 --out Duplicates_removed/Plink_format/chr${chr}


