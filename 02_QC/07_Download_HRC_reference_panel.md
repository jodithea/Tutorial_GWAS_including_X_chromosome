# Download the Haplotype Reference Consortium Reference Panel 

We will be imputing our tutorial genotype data using this reference panel and we need to download it to do some pre-imputation checks first

* On most HPC clusters the compute nodes have no outbound internet access so downloading these files within an interactive session or with a script will fail to find these files
* Instead download the files in the login node, where internet is allowed
* Copy and paste the following code into your HPC environment

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}

mkdir 02_QC/HRC_data/

cd 02_QC/HRC_data/

wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz

# Extract files from zip
gzip -d HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
```
