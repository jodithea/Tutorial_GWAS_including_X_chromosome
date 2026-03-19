#!/bin/bash
#PBS -l walltime=00:20:00
#PBS -l mem=5GB
#PBS -l ncpus=1

# This script combines the fastGWA output summary statistics files to create the final summary statistics

### Environment ###


### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Update to prefix used to name the GWAS output
GWAS_output=GWAS

### Submit script ###

cd ${directory}

# Combine summary stats from autosomes + X PAR no dosage compensation + X nPAR
cat 05_GWAS/GWAS/${GWAS_output}_autosomes.fastGWA > 05_GWAS/GWAS/${GWAS_output}_autosomes_X_nodc.txt
tail -n +2 05_GWAS/GWAS/${GWAS_output}_chrX_nPAR_nodc.fastGWA >> 05_GWAS/GWAS/${GWAS_output}_autosomes_X_nodc.txt
tail -n +2 05_GWAS/GWAS/${GWAS_output}_chrX_PAR.fastGWA >> 05_GWAS/GWAS/${GWAS_output}_autosomes_X_nodc.txt
# Change chromosome 25 to also be 23 so both the PAR and nPAR regions of the X chromosome are chr23 for the X chromosome
awk '{ gsub("25", "23", $1); print }' 05_GWAS/GWAS/${GWAS_output}_autosomes_X_nodc.txt \
> 05_GWAS/GWAS/${GWAS_output}_nodc_temp.txt && \
mv 05_GWAS/GWAS/${GWAS_output}_nodc_temp.txt 05_GWAS/GWAS/${GWAS_output}_autosomes_X_nodc.txt

# Combine summary stats from autosomes + X PAR full dosage compensation + X nPAR
cat 05_GWAS/GWAS/${GWAS_output}_autosomes.fastGWA > 05_GWAS/GWAS/${GWAS_output}_autosomes_X_fulldc.txt
tail -n +2 05_GWAS/GWAS/${GWAS_output}_chrX_nPAR_fulldc.fastGWA >> 05_GWAS/GWAS/${GWAS_output}_autosomes_X_fulldc.txt
tail -n +2 05_GWAS/GWAS/${GWAS_output}_chrX_PAR.fastGWA >> 05_GWAS/GWAS/${GWAS_output}_autosomes_X_fulldc.txt
# Change chromosome 25 to also be 23 so both the PAR and nPAR regions of the X chromosome are chr23 for the X chromosome
awk '{ gsub("25", "23", $1); print }' 05_GWAS/GWAS/${GWAS_output}_autosomes_X_fulldc.txt \
> 05_GWAS/GWAS/${GWAS_output}_fulldc_temp.txt && \
mv 05_GWAS/GWAS/${GWAS_output}_fulldc_temp.txt 05_GWAS/GWAS/${GWAS_output}_autosomes_X_fulldc.txt
