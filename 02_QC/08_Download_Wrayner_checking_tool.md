# Download the Wrayner imputation preparation and checking tool

* Go to website: https://www.well.ox.ac.uk/~wrayner/tools/
* Scroll down to 'HRC or 1000G Imputation preparation and checking'
* Check which is the latest version, as of making this tutorial it is version 4.3.0

* Download this version of the checking tool
	-  On most HPC clusters the compute nodes have no outbound internet access so downloading these files within an interactive session or with a script will fail to find these files
	- Instead download the files in the login node, where internet is allowed
* Copy and paste the following code into your HPC environment

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}

mkdir 02_QC/Wrayner_preimputation_checking/

cd 02_QC/Wrayner_preimputation_checking/

wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.3.0.zip

#Extract files from zip
unzip HRC-1000G-check-bim-v4.3.0.zip
```
