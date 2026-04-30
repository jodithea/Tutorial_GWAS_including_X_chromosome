#!/bin/bash
#PBS -l walltime=00:20:00
#PBS -l mem=10GB
#PBS -l ncpus=1
#PBS -J 0-22

# This script uses plink to carry out clumping to identify the number of independent SNPs that are genome-wide significant
# Autosomes + X chromosome

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Add filename of list of SNPs created from your GWAS summary statistics
GWAS_SNPs=GWAS_SNP_list_for_clumping.txt
# Add filename of reference genotype data, here we are using 1000 Genomes Phase 3 as downloaded and tidied in this tutorial and then Markername matched to our GWAS summary statistics
ref=(${directory}06_Clumping/1000G_with_GWAS_Markername/1000G_chr*_GWASMarkername.bed)
ref_prefix=${ref[${PBS_ARRAY_INDEX}]%.bed}
chr=$(basename "${ref_prefix}" | \
      sed 's|1000G_chr||' |
      sed 's|_GWASMarkername||')
# Add filename of metadata of reference genotype data to determine individuals of chosen ancestry to keep (here, EUR)
ref_metadata=04_Ancestry_Checks/1000G_data/integrated_call_samples_v3.20130502.ALL.panel

### Submit script ###

cd ${directory}

mkdir -p 06_Clumping/Clumped/


# 1) Make list of individuals from ancestry of choice for your referenve genotype data (here, Europeans)
awk '($3=="EUR"){print $1,$1}' ${ref_metadata} > 06_Clumping/Clumped/1000G_EUR_individuals.txt

# 2) Run clumping
plink --bfile ${ref_prefix} \
  --keep 06_Clumping/Clumped/1000G_EUR_individuals.txt \
  --clump 06_Clumping/Clumped/${GWAS_SNPs%.txt}_chr${chr}.txt \
  --clump-p1 0.0001 \
  --clump-p2 1 \
  --clump-r2 0.1 \
  --clump-kb 1000 \
  --out 06_Clumping/Clumped/chr${chr}_clumped


# CLUMPING ANALYSIS DETAILS
# -- clump                     text files with a header line, a column containing variant IDs (SNP), and another column containing p-values (P)
# --clump-p1 0.0001            Significance threshold for index SNPs (i.e. the most significant SNP in each clump must have a p-value at this value or lower)
# --clump-p2 1                 Secondary significance threshold for clumped SNPs (i.e. SNPs with p-value at this value or lower will be listed as a SNP within the appropriate clump - using 1 means all SNPs are assigned into a clump)
# --clump-r2 0.50              LD threshold for clumping based on maximum likelihood haplotype frequency estimates
# --clump-kb 250               Physical distance threshold for clumping (The maximum distance from the lead variant for SNPs to be considered to be clumped with it)




# OUPUT
#      CHR     Chromosome code
#      F       Results fileset code (1,2,...)
#      SNP     SNP identifier
#      BP      Physical position of SNP (base-pairs)
#      TOTAL   Total number of other SNPs in clump (i.e. passing --clump-kb and --clump-r2 thresholds)
#      NSIG    Number of clumped SNPs that are not significant ( p > 0.05 )
#      S05     Number of clumped SNPs 0.01 < p < 0.05
#      S01     Number of clumped SNPs 0.001 < p < 0.01
#      S001    Number of clumped SNPs 0.0001 < p < 0.001
#      S0001   Number of clumped SNPs p < 0.0001
#      SP2     List of SNPs names (and fileset code) clumped and significant at --clump-p2
