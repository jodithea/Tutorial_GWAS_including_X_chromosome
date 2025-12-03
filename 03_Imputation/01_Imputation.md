# Carry out imputation using the Michigan Imputation Server

* Go to website https://imputationserver.sph.umich.edu/
* Click 'Sign up now' and sign up for an account
* Go to your emails and click the link to verify your email address
* Login
* Along the top menu click 'Run' which brings down a drop down menu
* Click 'Genotype Imputation'
* Enter: 
	- Job name
	- Choose your reference panel: 1000G Phase 3 v5 (GRCh37/hg19)
	- Select the tutorial genotype VCF files: 'Tutorial_GWAS_including_X_chromosome/02_QC/Final_genotype_data_for_imputation/Genotypes_chr*_for_imputation.vcf.gz'
		- For chr 1 - 23 (autosomes = 1 - 22, X chromosome = 23)
	- Select array build: GRCh37/hg19
	- Select rsq Filter: Off
	- Select Phasing Engine: Eagle v2.4 (phased output)
	- Select Allele Frequency check: EUR 
	- Select Mode: Quality Control and Imputation
* Tick check boxes to confirm conditions for using the server
* Click 'Start Imputation'
