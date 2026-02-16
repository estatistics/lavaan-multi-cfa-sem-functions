# A multi function helper package for multiple CFAs and multiple SEMS

### lavaan-multi-cfa-sem-functions
Automated R functions for lavaan & semPlot that can handle multiple datasets (eg. different experimental treatments, time series) and organize tables from multiple CFAs and SEMS per case, per treatment etc.

Instead of manually running and extracting results for each model, these functions allow you to pass a list of dataframes and receive organized summary tables for:
a) Batch CFA/SEM: Compare model fit and factor loadings across all cases/treatments simultaneously.
b) Test-Retest Reliability: Automated ICC calculation (1k, 2k) for scale stability.
c) Diagnostic Suite: Batch Multivariate Normality (MVN) testing with intelligent variable filtering."
d) Auto-Splitting datasets in subscales for finer results. 
e) Excluding criteria eg. "ID"s, defining time series patterns eg. T1 t2, grepping specific vars for each case.

--------
--------
# TOOLS Explanation

### check_df_list()
This diagnostic utility performs a comprehensive "Sanity Check" across a list of multiple dataframes. Before running complex CFA or SEM models.This function scans every column in every dataset to identify potential mathematical "show-stoppers"—such as non-numeric data, missing values (NA/NaN), infinite values, or unexpected negative numbers. It returns a single, organized summary table, allowing researchers to quickly verify data integrity across multiple experimental treatments or longitudinal waves, time series, at a glance.

Detects in a list of dataframes "show-stoppers":
- non-numeric data
- missing values (NA/NaN),
- infinite values
- unexpected negative numbers

--------

### fit_measures()
- It is extracting fit indices (χ2/df ratio, CFI, TLI, RMSEA, SRMR, etc.) from lavaan CFAs/SEMs and presenting them in a clean, vertical dataframe format, rounded in 3 decimals.
- Crucially, the function includes a use_scaled toggle to automatically switch between standard Maximum Likelihood (ML) indices and Robust (Scaled) indices, which are required when data is non-normal.

--------

### outlier_remove_cfa()
This function automates multivariate outliers detection using Mahalanobis Distance, identifying cases that exhibit unusual patterns across multiple variables simultaneously. It features a flexible "sensitivity" and "cut-off" system to pinpoint extreme cases and provides a Chi-square Q-Q plot to visualize data normality.
- It handles missing values
- ID exclusion
- Returning a cleaned dataset ready for robust structural equation modeling
- Reports exactly the rows that outliers exists
  
--------
 
### run_qqplots_cfa()
It generates ggplot2 Chi-square Q-Q plots for a list of dataframes by using the previous function outlier_remove_cfa() that it is based on Mahalanobis Distance. It can help identifies extreme cases across all datasets simultaneously. The function automatically arranges these multi plots into an organized grid. Ideal for initial data screening when you examine multiple datasets.

--------

### split_dt_subscales()
You can provide prefixes, and it splits your dataset (main scale) into subscales' datasets. Each dataset one subscale for easier manipulation, easier producing reliabilities etc. 
- It automates the creation of scale-specific datasets by identifying column name prefixes (e.g., "DEPR", "ANX"). 
- It supports complex grouping logic, allowing you to combine multiple prefixes into a single sub-dataset using the + operator (e.g., "DEPR + ANX").
- So, you can join two or more subscales together, and produce unified statistics for them 

--------

### reliability_table()
Providing a list of dataframes, and splitted dataframes, it produce automatically all reliabilities per scale, per subscale in a neat table.Based on the psych::alpha function, it produces a summary table containing Cronbach's Alpha, Guttman's Lambda 6, and average inter-item correlations.
- A unique feature. It flags "negative items"—variables that correlate negatively with the scale total. This allows researchers to quickly identify items that require reverse-coding or exclusion before proceeding to CFA/SEM.

--------

### lavaan_r2_sided()
- By providing a list of lavaan results (Multi CFA / Multi SEM)
- it bind all explained variances (R2) into a single wide-format, side-by-side comparison table eg. Case A R2, Case B R2, Case C R2 etc.
- Direct comparison of  explained variances (R2) across many treatments, cases, multiple SEMs, multiple CFAs.

--------

### mvn_all()
mvn_all() provides a batch-processing solution for testing these assumptions across multiple datasets (eg., across experimental groups or time points). 
- It performs both Univariate and Multivariate normality tests simultaneously.
- A smart exclusion filter to ignore ID and metadata columns
- Helping to decide maybe the SEM estimator (Standard ML vs Robust MLR/WLSMV).

--------

### mediation_multi_mlr()
- Automation of the estimation of complex mediation models across multiple datasets (eg., across different experimental conditions or time waves). 
- By default utilizing the Robust Maximum Likelihood (MLR) estimator\
- Therefore, it provides reliable standard errors and fit indices even when multivariate normality assumptions are violated.
- It produces semPaths plots for every model in a list of datasets in a 2x2 grid
- It returns Mediation/SEM lavaan fits, lavaan r2_values, lavaan standardized tables, lavaan fit_indices (eg. CFI, TLI etc.), mi_indices (top 5). 

--------
### mediation_multi_WLSMV()
This function can produce lavaan WLSMV stats from multiple datasets and tidy them in summary tables. 
- It is specifically engineered when you like to use WLSMV estimator
- lavaan WLSMV estimator produces somewhat different lavaan statistics than ML or MLR. 
- Automates the calculation of Composite Reliability (Omega)
- Automates the calculation of Average Variance Extracted (AVE) for latent constructs.
- Dual-plotting engine (cause WLSMV created problems with semPATHS)
- Saves these high-resolution diagrams from both tidySEM and lavaanPlot into a dedicated directory (cause tidySEM utilizes View tab in Rstudio, and not Display tab).






