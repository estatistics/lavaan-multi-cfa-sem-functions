# A multi function helper package for multiple CFAs and multiple SEMS

### lavaan-multi-cfa-sem-functions
Automated R functions for lavaan & semPlot that can handle multiple datasets (eg. different experimental treatments, time series) and organize tables from multiple CFAs and SEMS per case, per treatment etc.

Instead of manually running and extracting results for each model, these functions allow you to pass a list of dataframes and receive organized summary tables for:
a) Batch CFA/SEM: Compare model fit and factor loadings across all cases/treatments simultaneously.
b) Test-Retest Reliability: Automated ICC calculation (1k, 2k) for scale stability.
c) Diagnostic Suite: Batch Multivariate Normality (MVN) testing with intelligent variable filtering."
d) Auto-Splitting datasets in subscales for finer results. 
e) Excluding criteria eg. "ID"s, defining time series patterns eg. T1 t2, grepping specific vars for each case.
