#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script creates a list of all the SNPs and their p-values from the GWAS summary statistics
# This SNP list is created to be used in plink to carry out clumping to identify the number of independent SNPs that are genome-wide significant

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Update to filename of GWAS summary statistics which you want to use for clumping
GWAS_sumstats=${directory}05_GWAS/GWAS/GWAS_autosomes_X_fulldc.txt

### Submit script ###

cd ${directory}

mkdir -p 06_Clumping/Clumped/

# Make a list of SNPs from GWAS summary statistics to input for clumping
# Format = SNP ID in column 1 with header "SNP", P-value in column 2 with header "P"
# SNP ID used in GWAS summary statistics needs to match SNP ID used in the genotype reference file being used for clumping (here we use 1000 Genomes Phase 3)
awk 'NR>1 {
    chr=$1
    if (chr==23) chr="X"
    file="06_Clumping/Clumped/GWAS_SNP_list_for_clumping_chr"chr".txt"
    if (!seen[chr]++) print "SNP P" > file
    print $2, $13 >> file
}' "${GWAS_sumstats}"
