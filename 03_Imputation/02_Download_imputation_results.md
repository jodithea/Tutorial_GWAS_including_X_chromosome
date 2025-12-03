# Download imputation results from the Michigan Imputation Server

* You will get an email when the imputation run has finished, use the link to go to the imputation results
* You can also go to the website: https://imputationserver.sph.umich.edu/ 
	- Login 
	- Click on 'Jobs' in the top menu
	- Click on your chosen job
* Click on the 'Results' tab
* Click 'wget' in the top right of the Downloads box
* Copy the wget commands, they will be of this format:
	- wget https://imputationserver.sph.umich.edu/share/results/*/chr_*.zip
	- wget https://imputationserver.sph.umich.edu/share/results/*/qc_report.txt
	- wget https://imputationserver.sph.umich.edu/share/results/*/quality-control.html
	- There may also be some other documents such as *chunks-excluded.txt, *snps-excluded.txt
* In your HPC environment navigate to your working directory:

```bash
# Update to point to location where you are doing this tutorial
directory=/path/Tutorial_GWAS_including_X_chromosome/

cd ${directory}

mkdir 03_Imputation/Genotype_imputation_results/

cd 03_Imputation/Genotype_imputation_results/
```
* Download the imputation results
	- Paste the wget commands
	- On most HPC clusters the compute nodes have no outbound internet access so downloading these files within an interactive session or with a script will fail to find these files
	- Instead download the files in the login node, where internet is allowed
