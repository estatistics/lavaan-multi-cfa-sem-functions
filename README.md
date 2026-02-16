# A multi function helper package for multiple CFAs and multiple SEMS

### lavaan-multi-cfa-sem-functions
Automated R functions for lavaan & semPlot that can handle multiple datasets (eg. different experimental treatments, time series) and organize tables from multiple CFAs and SEMS per case, per treatment etc.

Instead of manually running and extracting results for each model, these functions allow you to pass a list of dataframes and receive organized summary tables for:
a) Batch CFA/SEM: Compare model fit and factor loadings across all cases/treatments simultaneously.
b) Test-Retest Reliability: Automated ICC calculation (1k, 2k) for scale stability.
c) Diagnostic Suite: Batch Multivariate Normality (MVN) testing with intelligent variable filtering."
d) Auto-Splitting datasets in subscales for finer results. 
e) Excluding criteria eg. "ID"s, defining time series patterns eg. T1 t2, grepping specific vars for each case.

# TOOLS Explanation

### check_df_list()
This diagnostic utility performs a comprehensive "Sanity Check" across a list of multiple dataframes. Before running complex CFA or SEM models.This function scans every column in every dataset to identify potential mathematical "show-stoppers"—such as non-numeric data, missing values (NA/NaN), infinite values, or unexpected negative numbers. It returns a single, organized summary table, allowing researchers to quickly verify data integrity across multiple experimental treatments or longitudinal waves, time series, at a glance.

Detects in a list of dataframes "show-stoppers":
- non-numeric data
- missing values (NA/NaN),
- infinite values
- unexpected negative numbers

### fit_measures()
fit_measures() 
- It is extracting fit indices (χ2/df ratio, CFI, TLI, RMSEA, SRMR, etc.) from lavaan CFAs/SEMs and presenting them in a clean, vertical dataframe format, rounded in 3 decimals.
- Crucially, the function includes a use_scaled toggle to automatically switch between standard Maximum Likelihood (ML) indices and Robust (Scaled) indices, which are required when data is non-normal.


