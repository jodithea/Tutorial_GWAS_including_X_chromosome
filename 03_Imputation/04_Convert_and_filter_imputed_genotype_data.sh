#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l mem=5GB
#PBS -l ncpus=1
#PBS -J 0-22

# This script converts the imputated genotype files to Plink format
# Then filters variants on MAF and imputation score INFO

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

# 3) Convert .dose.vcf.gz files to Plink bed/bim/fam files
# Add sex data
# For X chromosome only: Split X into nPAR and PAR
if [[ "$chr_num" == "X" ]]; then
    plink --vcf chr${chr_num}_renamed.vcf.gz \
          --update-sex sex_data.txt \
          --split-x b37 \
          --make-bed \
          --out chr${chr_num}_renamed
else
    plink --vcf chr${chr_num}_renamed.vcf.gz \
          --update-sex sex_data.txt \
          --make-bed \
          --out chr${chr_num}_renamed
fi

# 4) Create a file with imputation score INFO
zcat chr${chr_num}.info.gz \
| awk '
!/^#/ {
    # Extract R2 from INFO column
    split($8, info, ";");
    r2 = "NA";
    for(i in info){
        if (info[i] ~ /^R2=/){
            r2 = substr(info[i], 4);
        }
    }

    # Make new variant ID to match as above
    id = $1 ":" $2 ":" $4 ":" $5;

    print id, r2;
}' > chr${chr_num}_info.txt

# 5) Filter genotype data based on MAF > 0.01 and imputation quality scores in chr${chr}_info.txt file, Rsq>0.8.
plink --bfile chr${chr_num}_renamed \
 --qual-scores chr${chr_num}_info.txt 2 1 \
 --qual-threshold 0.8 \
 --maf 0.01 \
 --make-bed \
 --out chr${chr_num}_filtered
