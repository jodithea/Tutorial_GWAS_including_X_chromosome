#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script combines clumping results from all chromosomes (autosomes + X chromosome) into one file
# And creates a file identifying the independent genome-wide significant SNPs

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

mkdir -p 06_Clumping/Clumped/

# 1) Combine results from all chromosomes into one file

# Get header line from one file
head -n 1 "$(ls -1 06_Clumping/Clumped/chr*.clumped | head -n 1)" > 06_Clumping/Clumped/All_chromosomes.clumped

# Take contents (minus the headerline) from the file containing the clumping results for each chromosome and concatenate into one file 
# (-q to suppress printing file name when cat)
# (awk 'NF' to skip empty rows, which there are lots of in plink clumping output files)
tail -q -n +2 06_Clumping/Clumped/chr*.clumped | awk 'NF' >> 06_Clumping/Clumped/All_chromosomes.clumped

# 2) Create a file identifying the independent genome-wide significant SNPs
awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' 06_Clumping/Clumped/All_chromosomes.clumped | head -n 1 > 06_Clumping/Clumped/All_chromosomes_genomewide_sig.clumped
awk '($5 < 5e-08) {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' 06_Clumping/Clumped/All_chromosomes.clumped >> 06_Clumping/Clumped/All_chromosomes_genomewide_sig.clumped

# 3) Create file that summarises the number of independent genome-wide significant SNPs
echo "Number of independent genome-wide significant SNPs = $(( $(wc -l < 06_Clumping/Clumped/All_chromosomes_genomewide_sig.clumped) - 1 ))" \
> 06_Clumping/Clumped/All_chromosomes_number_genomewide_sig.txt
