#!/bin/bash
#PBS -l walltime=01:30:00
#PBS -l mem=5GB
#PBS -l ncpus=1
#PBS -J 0-22

# This script converts the imputated genotype files to Plink format
# Then filters variants to only SNPs and filters on MAF and imputation score INFO
# Note: Tutorial originally developed using Michigan Imputation Server v2.0.10. Testing under v2.0.11 identified duplicate variant records in some imputed VCFs, which were addressed by removing duplicate variants from the VCF files

### Environment ###

module load plink/1.90b7
module load bcftools/1.22

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Add your password for the imputation results here as emailed to you by the Michigan Imputation Server. Make sure password is within quotation marks.
password="dJOFlq7{IS#5uv"
# List of files with imputed genotype data
files=(${directory}03_Imputation/Genotype_imputation_results/chr_*.zip)
# Extract "chr_*" from the file being used
chr=$(basename "${files[${PBS_ARRAY_INDEX}]}" .zip)
chr_num=${chr#chr_}

### Submit script ###

cd ${directory}03_Imputation/Genotype_imputation_results/

# 1) Unzip imputed genotype data
unzip -P "$password" ${chr}.zip

# 2) Rename variants from CHR:BP to CHR:BP:REF:ALLELE
bcftools annotate \
  -x ID \
  -I '%CHROM:%POS:%REF:%ALT' \
  -O z -o chr${chr_num}_renamed.vcf.gz \
  chr${chr_num}.dose.vcf.gz

# 3) Remove duplicates
# Some chromosomes have duplicate variants (same chr, position, ref and alt alleles - not just multiallelic)
# This causes an error in PLINK filtering steps
# So first remove these duplicate variants from vcf files
(
  zcat chr${chr_num}_renamed.vcf.gz | grep '^#'
  zcat chr${chr_num}_renamed.vcf.gz | grep -v '^#' \
    | awk -F"\t" '
      {
        key=$1"\t"$2"\t"$4"\t"$5
        if(!seen[key]++) print
      }'
) > chr${chr_num}_renamed_dedup.vcf

# 4) Convert renamed and deduplicated VCF files to Plink bed/bim/fam files
# Also only retain SNPs (i.e. remove indels) and add sex data
if [[ "$chr_num" == "X" ]]; then
    plink --vcf chr${chr_num}_renamed_dedup.vcf \
          --update-sex sex_data.txt \
          --snps-only just-acgt \
          --split-x b37 \
          --make-bed \
          --out chr${chr_num}_renamed_dedup

else
    plink --vcf chr${chr_num}_renamed_dedup.vcf \
          --update-sex sex_data.txt \
          --snps-only just-acgt \
          --make-bed \
          --out chr${chr_num}_renamed_dedup
fi

# 5) Create a file with imputation score INFO
# Use deduplicated VCF files to extract INFO score

grep -v '^#' chr${chr_num}_renamed_dedup.vcf | \
awk '
{
    split($8, info, ";")
    for(i in info)
        if(info[i] ~ /^R2=/)
            r2 = substr(info[i],4)

    print $1 ":" $2 ":" $4 ":" $5, r2
}' > chr${chr_num}_info.txt

# 6) Filter genotype data based on MAF > 0.01 and imputation quality scores in chr${chr}_info.txt file, Rsq>0.8.
# For X chr create separate PLINK file sets for X chr nPAR and X chr PAR
if [[ "$chr_num" == "X" ]]; then
    plink --bfile chr${chr_num}_renamed_dedup \
      --qual-scores chr${chr_num}_info.txt 2 1 \
      --qual-threshold 0.8 \
      --maf 0.01 \
      --make-bed \
      --out chr${chr_num}_filtered

   # Extract nPAR only (CHR 23)
    plink --bfile chr${chr_num}_filtered \
          --chr 23 \
          --make-bed \
          --out chr${chr_num}_nPAR_filtered

    # Extract PAR only (CHR 25)
    plink --bfile chr${chr_num}_filtered \
          --chr 25 \
          --make-bed \
          --out chr${chr_num}_PAR_filtered

else
    plink --bfile chr${chr_num}_renamed_dedup \
     --qual-scores chr${chr_num}_info.txt 2 1 \
     --qual-threshold 0.8 \
     --maf 0.01 \
     --make-bed \
     --out chr${chr_num}_filtered
fi
