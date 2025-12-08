# Download genotype data to use in tutorial

The genotype data to use in this tutorial has been archived on Zenodo and assigned a DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17796418.svg)](https://doi.org/10.5281/zenodo.17796418)


* On most HPC clusters the compute nodes have no outbound internet access so downloading these files within an interactive session or with a script will fail to find these files
* Instead download the files in the login node, where internet is allowed
* Copy and paste the following code into your HPC environment

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}01_Genotype_Data

wget https://zenodo.org/records/17796418/files/tutorial_genotype_data.zip?download=1/tutorial_genotype_data.zip -O tutorial_genotype_data.zip

# Extract files from zip
unzip tutorial_genotype_data.zip
```
