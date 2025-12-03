#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script carries out variant level QC on the autosomes and the pseudoautosomal region (PAR) of the X chromosome (coded as 25 or XY in plink)
# Filter variants with MAF < 1%, call rate < 95% and hardy weinburg equilibrium p < 10-6

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc2 \
 --chr 1-22,XY \
 --maf 0.01 \
 --geno 0.05 \
 --hwe 0.000001 \
 --make-bed \
 --out 02_QC/Genotype_checks/Genotypes_autosomes_XPAR_variantqc1

