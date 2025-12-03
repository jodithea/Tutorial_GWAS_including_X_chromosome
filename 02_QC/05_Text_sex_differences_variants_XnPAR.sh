#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=5GB
#PBS -l ncpus=1

# This script visualises and tests for sex differences in allele frequency and missingness of variants on the non-pseudoautosomal region (nPAR) of the X chromosome (coded as 23 or X in plink)

### Environment ###

module load plink/1.90b7
module load R/4.5.0

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

### Submit script ###

cd ${directory}

mkdir 02_QC/Plots/

# 1) Create file with FID, IID, Sex to use as an input to stratify plink estimates by sex
awk '{print $1,$2,$5}' 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc1.fam \
 > 02_QC/Lists/list_ids_sex.txt

# 2) Estimate allele frequencies and missingness for variants on the nPAR of the X chromosome for each sex
plink --bfile 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc1 \
 --chr X \
 --freq \
 --within 02_QC/Lists/list_ids_sex.txt \
 --out 02_QC/Genotype_checks/check_freq_by_sex_XnPAR

plink --bfile 02_QC/Genotype_checks/Genotypes_XnPAR_variantqc1 \
 --chr X \
 --missing \
 --within 02_QC/Lists/list_ids_sex.txt \
 --out 02_QC/Genotype_checks/check_missing_by_sex_XnPAR

# 3) Visualise sex differences in allele frequencies and missingness of each SNP
export directory
R --vanilla << 'EOF'
library(tidyverse)
dir <- Sys.getenv("directory")

# ALLELE FREQUENCIES
# Load data
freq <- read.table(file.path(dir, "02_QC/Genotype_checks/check_freq_by_sex_XnPAR.frq.strat"), header = TRUE)

# Change data frame so one row per sex
freq_wide <- freq %>%
  pivot_wider(names_from = CLST,
              values_from = c(MAF,MAC,NCHROBS))

# Calculate difference in MAF between females and males
freq_wide <- freq_wide %>%
  mutate(delta_maf = abs(MAF_1 - MAF_2))

# Plot the distribution of difference in MAF between females and males
delta_maf_plot <- ggplot(freq_wide, aes(x=delta_maf)) +
  geom_histogram(bins=50) +
  theme_classic() +
  labs(title="Distribution of absolute difference in MAF \nbetween females and males")

ggsave(delta_maf_plot, file = file.path(dir, "02_QC/Plots/Distr_MAF_sex_differences_absolute.png"), width = 20, height = 20, unit = "cm")

# Conduct Fishers exact test to determine if MAF differs between females and males more than expected by chance, for each SNP
freq_wide <- freq_wide %>%
  rowwise() %>%   
  mutate(
    fisher_p_maf = fisher.test(matrix(
      c(MAC_1,                      # female minor alleles
        NCHROBS_1 - MAC_1,          # female major alleles
        MAC_2,                      # male minor alleles
        NCHROBS_2 - MAC_2),         # male major alleles
      nrow = 2                      # creates 2×2 table
    ))$p.value
  )

# Plot the distribution of p-values
p_maf_plot <- ggplot(freq_wide, aes(x=fisher_p_maf)) +
  geom_histogram(bins=50) +
  theme_classic() +
  labs(title="Distribution of p-values from Fishers exact test \ncomparing MAF between females and males")

ggsave(p_maf_plot, file = file.path(dir, "02_QC/Plots/Distr_MAF_sex_differences_p.png"), width = 20, height = 20, unit = "cm")


# MISSINGNESS
# Load data
missing <- read.table(file.path(dir, "02_QC/Genotype_checks/check_missing_by_sex_XnPAR.lmiss"), header = TRUE)
# N_MISS	number of missing genotypes
# N_CLST	number of individuals in the sex group
# N_GENO	number of non-missing genotypes
# F_MISS	missingness rate = N_MISS / N_CLST

# Change data frame so one row per sex
missing_wide <- missing %>%
  pivot_wider(names_from = CLST,
              values_from = c(F_MISS, N_MISS, N_CLST, N_GENO))

# Calculate difference in MAF between females and males
missing_wide <- missing_wide %>%
  mutate(delta_missing_rate = abs(F_MISS_1 - F_MISS_2))

# Plot the distribution of difference in MAF between females and males
delta_missing_rate_plot <- ggplot(missing_wide, aes(x=delta_missing_rate)) +
  geom_histogram(bins=50) +
  theme_classic() +
  labs(title="Distribution of absolute difference in missingness rate \nbetween females and males")

ggsave(delta_missing_rate_plot, file = file.path(dir, "02_QC/Plots/Distr_missing_sex_differences_absolute.png"), width = 20, height = 20, unit = "cm")

# Conduct Fishers exact test to determine if MAF differs between females and males more than expected by chance, for each SNP
missing_wide <- missing_wide %>%
  rowwise() %>%   
  mutate(
    fisher_p_missing = fisher.test(matrix(
      c(N_MISS_1,                   # female no. missing
        N_CLST_1 - N_MISS_1,        # female no. not missing
        N_MISS_2,                   # male no. missing
        N_CLST_2 - N_MISS_2),       # male no. not missing
      nrow = 2                      # creates 2×2 table
    ))$p.value
  )

# Plot the distribution of p-values
p_missing_plot <- ggplot(missing_wide, aes(x=fisher_p_missing)) +
  geom_histogram(bins=50) +
  theme_classic() +
  labs(title="Distribution of p-values from Fishers exact test \ncomparing missingness between females and males")

ggsave(p_missing_plot, file = file.path(dir, "02_QC/Plots/Distr_missing_sex_differences_p.png"), width = 20, height = 20, unit = "cm")


# SAVE DATA
# Combine MAF and missingness dataframes
freq_missing <- freq_wide %>% 
  full_join(missing_wide)

# Save
write.table(freq_missing, 
            file = file.path(dir, "02_QC/Lists/list_snps_maf_missing_chrX.txt"),
            col.names = TRUE,
            row.names = FALSE,
            quote = FALSE,
            sep = "\t")
EOF
