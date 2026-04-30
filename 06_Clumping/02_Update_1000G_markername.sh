#!/bin/bash
#PBS -l walltime=01:00:00
#PBS -l mem=10GB
#PBS -l ncpus=1
#PBS -J 0-22

# This script updates the downloaded 1000 Genomes genotype data file (.bim) so that SNP ID matches between 1000 genomes and your GWAS summary statistics
# We can't match on Markername CHR:BP because of multi-allelic sites
# Therefore match on Markername CHR:BP:Allele1:Allele2. 
# However, order of alleles may be different in your GWAS summary statistics and 1000 Genomes, so make sure 1000 Genomes Markername is the same, even if alleles are flipped

### Environment ###

module load plink/1.90b7

### Preamble ###

# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/
# Update to filename of GWAS summary statistics which you want to use for clumping
GWAS_sumstats=${directory}05_GWAS/GWAS/GWAS_autosomes_X_fulldc.txt
# Add filename of reference genotype data, here we are using 1000 Genomes Phase 3 as downloaded and tidied in this tutorial
ref=(${directory}04_Ancestry_Checks/1000G_data/Duplicates_removed/Plink_format/chr*.bim)
ref_prefix=${ref[${PBS_ARRAY_INDEX}]%.bim}
chr=$(basename "${ref_prefix}" | \
      sed 's|chr||')

### Submit script ###

cd ${directory}

mkdir -p 06_Clumping/1000G_with_GWAS_Markername/


# 1) Make SNP renaming file. Coll 1 = old ID (ID in 10000Genomes) and col 2 = new ID (ID in GWAS sumstats)
awk '
BEGIN { OFS="\t" }

#################################################
# FIRST FILE = GWAS summary statistics
#################################################
FNR==NR {

    if (NR==1) next

    gwaschr=$1
    if (gwaschr==23) gwaschr="X"
    if (gwaschr==25) gwaschr="X"

    gwasbp=$3
    gwasa1=$4
    gwasa2=$5
    gwasid=$2

    # same allele order (CHR:BP:A1:A2)
    key1 = gwaschr ":" gwasbp ":" gwasa1 ":" gwasa2

    # flipped allele order (CHR:BP:A2:A1)
    key2 = gwaschr ":" gwasbp ":" gwasa2 ":" gwasa1

    map[key1]=gwasid
    map[key2]=gwasid

    next
}

#################################################
# SECOND FILE = 1000 Genomes .bim file
#################################################
{
    G1000chr=$1
    if (G1000chr==23) G1000chr="X"

    G1000id=$2
    G1000bp=$4
    G1000a1=$5
    G1000a2=$6

    key = G1000chr ":" G1000bp ":" G1000a1 ":" G1000a2

    if (key in map)
        print G1000id, map[key]
}

' "${GWAS_sumstats}" "${ref[${PBS_ARRAY_INDEX}]}" \
> "06_Clumping/1000G_with_GWAS_Markername/Update_1000G_to_GWAS_Markername_chr${chr}.txt"


# 2) Update the Markername in the 1000Genomes genotype files using PLINK and this list of SNP IDs
plink \
  --bfile ${ref_prefix} \
  --update-name 06_Clumping/1000G_with_GWAS_Markername/Update_1000G_to_GWAS_Markername_chr${chr}.txt \
  --make-bed \
  --out 06_Clumping/1000G_with_GWAS_Markername/1000G_chr${chr}_GWASMarkername

