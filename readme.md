This repo contains the extraction, matching, and analysis code and compiled 
HTML for a comparison of the hazard of Parkinson's disease (PD) in men using 
terazosin or related drugs doxazosin or alfuzosin (collectively TZ/DZ/AZ) to
men using tamsulosin, a drug used for the same reasons and in the same class 
as TZ/DZ/AZ but thought not to have an effect, and 5a reductase inhibitors 
(5ARI), which are used to treat the same condition that TZ/DZ/AZ are commonly
used for. 

The code for this project is hosted as Rmarkdown files at the 
[GitHub repo](https://github.com/iacobus42/parkinson-disease-5ari) for this
project. Compiled HTML versions of Rmarkdown are in the repo or can be viewed
online [here](https://jacobsimmering.com/publication/simmering-2022-5ari/code.html).

- `find_treated.[Rmd|html]` identifies and extracts users of TZ, DZ, AZ, and tamsulosin
- `find_treated_demographics_enrollments.[Rmd|html]` adds enrollment and demographic data to ever users
- `find_pd_dates.[Rmd|html]` finds the first diagnosis dates of PD for everyone in the Truven database
- `reduce_treated_enrollments.[Rmd|html]` reduces the ever users enrollment periods, removes people with pre-existing PD
- `find_luts_procs.[Rmd|html]` finds LUTS procedures (PSA measurement, uroflow, etc) in the Truven database
- `build_model_data_treated.[Rmd|html]` builds the model data set for propensity score model estimation
- `fit_psm.[Rmd|html]` generates the propensity score models and fitted values
- `match.[Rmd|html]` generates matches, largely a wrapper around the function in `match.cpp`
- `match.cpp` includes a C++ function used by `match.Rmd` to do the matching on propensity score and enrollment time
- `analysis/analysis_functions.R` provides a function for making comparison tables to assess balance in cohorts
- `analysis/tz-tam.[Rmd|html]` provides TZ/DZ/AZ versus tamsulosin analysis
- `analysis/tz-5ari.[Rmd|html]` provides TZ/DZ/AZ versus 5ARI analysis
- `analysis/tam-5ari.[Rmd|html]` provides tamsulosin versus 5ARI analysis
- `sge.sh` the job submission script
- `tz-5ari-production.e8087386` and `tz-5ari-production.e8087386` are the output and error files for the job submitted by `sge.sh`
