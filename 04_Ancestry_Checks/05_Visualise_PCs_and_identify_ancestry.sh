#!/bin/bash
#PBS -l walltime=00:10:00
#PBS -l mem=1GB
#PBS -l ncpus=1

# This script visualises where the tutorial individuals sit in relation to the 1000G super populations
# And creates a list of individuals of European ancestry

# Note that the tutorial genotype data is the 1000G data, so we are going to see exact overlap between our tutorial genotype data and some of the 1000G reference genotype data
# This won't happen with your own genotype data, there will be more variation

# Note this script is for Europeans. Adjust this script if you want to work with a different ancestry

# Note specify the threshold (in standard deviations) to visualise and define individuals of European ancestry. Can adjust this threshold and run this script multiple times to determine the best threshold to use.

### Environment ###

module load plink/1.90b7

module load R/4.5.0

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

# Choose threshold to use to remove ancestry outliers, in standard deviations
# Look at the plots produced from this script - if this doesn't look like a good threshold update (e.g. change to threshold=4) and re-run the script until you find a threshold that looks good
# Here, I ran the script with the threshold of 3, 4, 5, and 6 and decided to use a threshold of 5SD
threshold=5

### Submit script ###

cd ${directory}

mkdir -p 04_Ancestry_Checks/Plots/

# In R create PCA plots and list of individuals with European ancestry, based on specified threshold

export directory
export threshold
R --vanilla << 'EOF'
library(tidyverse)
dir <- Sys.getenv("directory")
threshold <- as.numeric(Sys.getenv("threshold"))


# Load data
pca <- read.table(file.path(dir, "04_Ancestry_Checks/PCA_data/Genotypes_study_and_1000G_autosomes_filtered_pca.eigenvec"), header = FALSE)
colnames(pca) <- c("FID", "IID", paste0("PC", 1:20))

sample_info_1000G <- read.table(file.path(dir, "04_Ancestry_Checks/1000G_data/integrated_call_samples_v3.20130502.ALL.panel"), header = TRUE)

# Merge datasets
df <- pca %>%
  full_join(sample_info_1000G, by = c("IID" = "sample"))

# Calculate the mean +/- threshold for 1000G individuals from European super-population
# For first 4 PCs
thresholds <- df %>%
  filter(super_pop == "EUR") %>%
  summarise(
    mean_PC1 = mean(PC1, na.rm = TRUE),
    sd_PC1   = sd(PC1, na.rm = TRUE),
    mean_PC2 = mean(PC2, na.rm = TRUE),
    sd_PC2   = sd(PC2, na.rm = TRUE),
    mean_PC3 = mean(PC3, na.rm = TRUE),
    sd_PC3   = sd(PC3, na.rm = TRUE),
    mean_PC4 = mean(PC4, na.rm = TRUE),
    sd_PC4   = sd(PC4, na.rm = TRUE)
  ) %>%
  mutate(
    PC1_min = mean_PC1 - threshold * sd_PC1,
    PC1_max = mean_PC1 + threshold * sd_PC1,
    PC2_min = mean_PC2 - threshold * sd_PC2,
    PC2_max = mean_PC2 + threshold * sd_PC2,
    PC3_min = mean_PC3 - threshold * sd_PC3,
    PC3_max = mean_PC3 + threshold * sd_PC3,
    PC4_min = mean_PC4 - threshold * sd_PC4,
    PC4_max = mean_PC4 + threshold * sd_PC4
  )


# Identify which individuals from our tutorial data are outside the mean +/- threshold for the first 4 PCs of the 1000G EUR individuals
df <- df %>% 
  mutate(
    EUR = case_when(
      is.na(super_pop) & 
        (
          PC1 < thresholds$PC1_min | PC1 > thresholds$PC1_max |
          PC2 < thresholds$PC2_min | PC2 > thresholds$PC2_max |
          PC3 < thresholds$PC3_min | PC3 > thresholds$PC3_max |
          PC4 < thresholds$PC4_min | PC4 > thresholds$PC4_max
      ) ~ "Outside",
      
      is.na(super_pop) & 
        (
          PC1 >= thresholds$PC1_min & PC1 <= thresholds$PC1_max &
          PC2 >= thresholds$PC2_min & PC2 <= thresholds$PC2_max &
          PC3 >= thresholds$PC3_min & PC3 <= thresholds$PC3_max &
          PC4 >= thresholds$PC4_min & PC4 <= thresholds$PC4_max
      ) ~ "Inside",
    )
  )

# Create PCA plots
# 1000 Genomes individuals used to define the PC axes
# 1000G individuals coloured by super-population
# Overlay points from tutorial individuals, coloured by if inside or outside the EUR threshold
PC1_PC2_plot <- ggplot() +
  geom_point(data = df %>% filter(!is.na(super_pop)),
             aes(x = PC1, y = PC2, fill = super_pop),
             alpha = 0.6, size = 2, shape = 21, colour = "transparent") +
  geom_point(data = df %>% filter(is.na(super_pop)),
             aes(x = PC1, y = PC2, colour = EUR, shape = EUR),
             size = 3, alpha = 0.6) +
  scale_fill_viridis_d("1000G Super-population") +
  scale_colour_manual(paste0("Study individuals within \nmean +/-", threshold, "SD \nfor the first 4 PCs \nof the 1000G EUR individuals"),
                    values = c("Inside" = "black", "Outside" = "red")) +
  scale_shape_manual(paste0("Study individuals within \nmean +/-", threshold, "SD \nfor the first 4 PCs \nof the 1000G EUR individuals"),
                     values = c("Inside" = 0, "Outside" = 2)) +
  scale_x_continuous("PC1") +
  scale_y_continuous("PC2") +
  theme_classic() +
  theme(legend.position = "right")

PC3_PC4_plot <- ggplot() +
  geom_point(data = df %>% filter(!is.na(super_pop)),
             aes(x = PC3, y = PC4, fill = super_pop),
             alpha = 0.6, size = 2, shape = 21, colour = "transparent") +
  geom_point(data = df %>% filter(is.na(super_pop)),
             aes(x = PC3, y = PC4, colour = EUR, shape = EUR),
             size = 3, alpha = 0.6) +
  scale_fill_viridis_d("1000G Super-population") +
  scale_colour_manual(paste0("Study individuals within \nmean +/-", threshold, "SD \nfor the first 4 PCs \nof the 1000G EUR individuals"),
                      values = c("Inside" = "black", "Outside" = "red")) +
  scale_shape_manual(paste0("Study individuals within \nmean +/-", threshold, "SD \nfor the first 4 PCs \nof the 1000G EUR individuals"),
                     values = c("Inside" = 0, "Outside" = 2)) +
  scale_x_continuous("PC3") +
  scale_y_continuous("PC4") +
  theme_classic() +
  theme(legend.position = "right")

# Save plots
ggsave(PC1_PC2_plot, file = paste0(dir, "04_Ancestry_Checks/Plots/PC1_PC2_", threshold, "SD_plot.png"), width = 20, height = 20, unit = "cm")
ggsave(PC3_PC4_plot, file = paste0(dir, "04_Ancestry_Checks/Plots/PC3_PC4_", threshold, "SD_plot.png"), width = 20, height = 20, unit = "cm")

# Create list of individuals that are classified as European ancestry
# Individuals from our tutorial data that are inside the mean +/- threshold for the first 4 PCs of the 1000G EUR individuals are classified as European ancestry
EUR_IDs <- df %>% 
  filter(EUR == "Inside") %>% 
  select("FID", "IID")

# Save list
write.table(EUR_IDs,
            file = paste0(dir, "04_Ancestry_Checks/PCA_data/EUR_IDs_", threshold, "SD.txt"),
            col.names = TRUE,
            row.names = FALSE,
            quote = FALSE,
            sep = "\t")

EOF
