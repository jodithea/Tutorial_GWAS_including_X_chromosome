#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=2GB
#PBS -l ncpus=1

# This script creates prepares for using the Wrayner checking tool for pre-imputation checks

### Environment ###

module load plink/1.90b7


### Preamble ###

# # Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

mkdir -p 02_QC/Wrayner_preimputation_checking/

# 1) Merge final QCed genotype files into one
# Merge QCed autosomes + X chr PAR with QCed X chr nPAR
# And change chr X nPAR (XY, 25) to also be labelled as X/23 so all variants on the X chromosome, regardless of if in nPAR or PAR, are labelled as X chromosome
# This is because the Wrayner checking tools and Michigan Imputation Server use this labelling of the X chromosome
# Michigan Imputation Server splits by nPAR and PAR using bp position
plink --bfile 02_QC/Genotype_checks/Genotypes_autosomes_XPAR_variantqc1 \
 --bmerge 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc2 \
 --make-bed \
 --out 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed

# Run --merge-x as separate command as otherwise throws error: --merge-x must be used with --make-bed and no other commands
plink --bfile 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed \
 --merge-x \
 --make-bed \
 --out 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX

# 2) Get allele frequencies from the final QCed genotype data
plink --bfile 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX \
 --freq \
 --out 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX_freq

# --output-chr MT \

# 3) Run the Wrayner checking tool perl script
perl 02_QC/Wrayner_preimputation_checking/HRC-1000G-check-bim.pl \
 -b 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX.bim \
 -f 02_QC/Wrayner_preimputation_checking/Genotypes_all_chr_QCed_mergeX_freq.frq \
 -r 02_QC/HRC_data/HRC.r1-1.GRCh37.wgs.mac5.sites.tab \
 -h

