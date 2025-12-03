# Download the 1000 Genomes Phase 3 autosomal genotype data 

To be used to calculate ancestry PCs and filter ancestry outiers  

* On most HPC clusters the compute nodes have no outbound internet access so downloading these files within an interactive session or with a script will fail to find these files
* Instead download the files in the login node, where internet is allowed
* Copy and paste the following code into your HPC environment

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}

mkdir -p 04_Ancestry_Checks/1000G_data/

cd 04_Ancestry_Checks/1000G_data/

# Download 1000Genomes genotype data (VCF and index files), for autosomes
# Latest release = Phase 3 20130502
# This will take ~ 1 hour
for chr in {1..22}; do
  wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
  wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi
done

# Download file with sample information
wget https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/integrated_call_samples_v3.20130502.ALL.panel 
```
