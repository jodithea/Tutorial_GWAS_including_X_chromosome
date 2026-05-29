# Download raw genotype data to run the full tutorial from the beginning

The genotype data to use in this tutorial has been archived on Zenodo and assigned a DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17796418.svg)](https://doi.org/10.5281/zenodo.17796418)


* On most HPC clusters the compute nodes have no outbound internet access so downloading these files within an interactive session or with a script will fail to find these files
* Instead download the files in the login node, where internet is allowed
* After cloning the github repository, copy and paste the following code into your HPC environment

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}

# Download file
wget https://zenodo.org/record/20438428/files/Tutorial_GWAS_including_X_chromosome_raw_genotype_data.tar.gz

# Extract files from tarred directory
tar -xzvf Tutorial_GWAS_including_X_chromosome_raw_genotype_data.tar.gz --keep-old-files
```
