#!/bin/bash

#Set the name of the job.
#$ -N tz-5ari-production

#Set the shell that should be used to run the job.
#$ -S /bin/bash

#Set the current working directory as the location for the error and output files.
#(Will show up as .e and .o files)
#$ -cwd

#Select the queue to run in
#$ -q UI

#Select the number of slots the job will use
#$ -pe smp 56

#Print information from the job into the output file
/bin/echo Running on host: `hostname`.
/bin/echo In directory: `pwd`
/bin/echo Starting on: `date`

#Description
desc=""
project=""
disease=""

#Script Paths
script_path="~/projects/pd-preprint/"

# Print job info to job_history file
echo Job: $JOB_NAME "/" ID: $JOB_ID  "/" Date: `date` "/" Disease: $disease "/"  Project: $project "/" Desc: $desc "/" Path: $script_path >> /Users/jsimmeri/job_history.txt

#Send e-mail at beginning/end/suspension of job
#$ -m bes

#E-mail address to send to
#$ -M jacob-simmering@uiowa.edu

#INPUT JOB HERE
cd ~/projects/pd-preprint/

################################################################################
# Data Extraction ##############################################################
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('find_treated.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('find_treated_demographics_enrollments.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('find_pd_dates.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('reduce_treated_enrollments.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('find_luts_procs.Rmd')"

################################################################################
# Data Processing and Matching #################################################
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('build_model_data_treated.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('fit_psm.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('match.Rmd')"

################################################################################
# Main Analysis ################################################################
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('analysis/tz-tam.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('analysis/tz-5ari.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('analysis/tam-5ari.Rmd')"

################################################################################
# Sensitivity Analysis: Must Have BPH ##########################################
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/bph-restricted/fit_psm.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/bph-restricted/match.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/bph-restricted/analysis.Rmd')"

################################################################################
# Sensitivity Analysis: Outcome is DX Only #####################################
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/dx-only-outcome/find_pd_dates.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/dx-only-outcome/reduce_treated_enrollments.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/dx-only-outcome/build_model_data_treated.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/dx-only-outcome/fit_psm.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/dx-only-outcome/match.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/dx-only-outcome/analysis.Rmd')"

################################################################################
# Sensitivity Analysis: Time-Varying Coefficients ##############################
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/time-varying-effect/analysis.Rmd')"

################################################################################
# Sensitivity Analysis: Variable Lead-In +/- Time-Varying Coefficients #########
################################################################################
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/washout/fit_psm.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/washout/match.Rmd')"
singularity exec ~/r_404.sif Rscript -e "rmarkdown::render('sensitivity-analyses/washout/analysis.Rmd')"
