#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script carries out sample level QC
# Remove samples with low call rate < 95%
# Remove samples with a mismatch between sex inferred from genotype data and reported sex
# Remove samples with extreme heterozygosity

### Environment ###

module load plink/1.90b7
module load R/4.5.0

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/


### Submit script ###

cd ${directory}

mkdir 02_QC/Genotype_checks/
mkdir 02_QC/Lists/

# 1) Remove samples with low call rate < 95%
# Do this as the first step so following QC steps aren't biased by poor samples
plink --bfile 01_Genotype_Data/Genotypes_all_chr \
 --mind 0.05 \
 --make-bed \
 --out 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc1

# 2) Prune SNPs for linkage disequilibrium (LD)
# We will use the list of SNPs in linkage equilibrium output (rmeoved SNPs in LD) to only keep these SNPs when using --check-sex and --het in the below steps, as these use allele frequencies which are affected by LD structure
plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc1 \
 --indep-pairwise 50 5 0.2 \
 --out 02_QC/Genotype_checks/check_LD

# 3) Check sex mismatch
# Only include SNPs that have been pruned for LD (when ran using all SNPs identified 50 samples with sex mismatch, when ran only using SNPs in linkage equilibrium identified 18 samples with sex mismatch  - this highlights the importanc eof using pruned SNPs only).
plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc1 \
 --check-sex \
 --extract 02_QC/Genotype_checks/check_LD.prune.in \
 --out 02_QC/Genotype_checks/check_sex

# 4) Check for extreme heterozygosity
# Only include SNPs that have been pruned for LD
plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc1 \
 --het \
 --extract 02_QC/Genotype_checks/check_LD.prune.in \
 --out 02_QC/Genotype_checks/check_het

# 5) Create list of sex mismatch and heterozygosity outlier samples to remove
# Use *.sexcheck output to find samples with "PROBLEM" in the STATUS column (column 5) - i.e. sex inferred from genotype data (F < 0.2 = female and > 0.8 = male) does not match reported sex
# Here, we are just using the default F-statistics of  < 0.2 = female and > 0.8 = male 
# Ideally should also plot F-statistic distribution from the .sexcheck file to identify the best cut-offs to use
awk '$5=="PROBLEM" {print $1, $2}' 02_QC/Genotype_checks/check_sex.sexcheck > 02_QC/Lists/list_sex_outliers.txt

# Use *.het output to identify samples +/- 3 SD from mean of F coefficient estimates for assessing heterozygosity (column 6)
# Here, we are using the common cut-off of 3SD above and below the mean F coefficient
# Ideally should also plot the F-statistic distribution from the heterozygosity distribution to identify the best cut-offs to use
export directory
R --vanilla << 'EOF'
library(tidyverse)
dir <- Sys.getenv("directory")
het <- read.table(file.path(dir, "02_QC/Genotype_checks/check_het.het"), header = TRUE)
stats <- het %>%
  summarise(
    mean_F = mean(F, na.rm = TRUE),
    sd_F   = sd(F, na.rm = TRUE),
    lower_3SD = mean_F - 3 * sd_F,
    upper_3SD = mean_F + 3 * sd_F
  )
het_outliers <- het %>%
  filter(F < stats$lower_3SD | F > stats$upper_3SD) %>%
  select(FID, IID)
write.table(het_outliers,
            file.path(dir, "02_QC/Lists/list_het_outliers.txt"),
            col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")
EOF

# Combine the two lists to make one list of samples to remove
cat 02_QC/Lists/list_sex_outliers.txt 02_QC/Lists/list_het_outliers.txt \
    | sort -u > 02_QC/Lists/list_sex_and_het_outliers.txt

# 6) Remove samples
plink --bfile 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc1 \
 --remove 02_QC/Lists/list_sex_and_het_outliers.txt \
 --make-bed \
 --out 02_QC/Genotype_checks/Genotypes_all_chr_sampleqc2
