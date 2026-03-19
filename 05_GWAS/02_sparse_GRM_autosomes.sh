#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=5

# This script uses the GCTA package to create a sparse GRM from the full GRM, which is then used to run GWAS in fastGWA
# --make-bK-sparse sets the cutoff threshold - entries below this value are set to 0 (so only makes pairs of individuals whose entries in the GRM are greater than this value)
# Default threshold is 0.05.

### Environment ###

module load GCTA/1.94.1

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/mnt/backedup/home/jodiT/Working/Tutorial_GWAS_including_X_chromosome/


### Submit script ###

cd ${directory}

gcta-1.94.1 \
 --grm 05_GWAS/GRM/GRM_autosomes \
 --make-bK-sparse 0.05 \
 --out 05_GWAS/GRM/Sparse_GRM_autosomes 
