# A multi function helper package for multiple CFAs and multiple SEMS

### lavaan-multi-cfa-sem-functions
Automated R functions for lavaan & semPlot that can handle multiple datasets (eg. different experimental treatments, time series) and organize tables from multiple CFAs and SEMS per case, per treatment etc.

Instead of manually running and extracting results for each model, these functions allow you to pass a list of dataframes and receive organized summary tables for:
a) Batch CFA/SEM: Compare model fit and factor loadings across all cases/treatments simultaneously.
b) Test-Retest Reliability: Automated ICC calculation (1k, 2k) for scale stability.
c) Diagnostic Suite: Batch Multivariate Normality (MVN) testing with intelligent variable filtering."
d) Auto-Splitting datasets in subscales for finer results. 
e) Excluding criteria eg. "ID"s, defining time series patterns eg. T1 t2, grepping specific vars for each case.

# CAUTION: Most of these functions WORK with:
- A list of datasets
- A list of lavaan models
- Both lists must be named
- list of datasets & list of lavaan models must have identical names
- eg.

```
# Common names for BOTH Datasets and Models
# Naming the datasets
all_datasets <- list(  name_time1 = df_time1, name_time2 = df_time2, name_time3 = df_time3 )
names_for_list_of_dfs <- c( "df_time1","df_time2","df_time3" )

# Naming the models
all_models  <- list( name_time1  = model_time1,  name_time2 = model_time2,  name_time3  = model_time3 )

# Assign them to new vars for clarity, security against data change
data_dfs_lst   = all_datasets
models_dfs_lst = all_models
cfa_multi(data_dfs_lst, models_dfs_lst)

```


--------
--------
# TOOLS Explanation

### check_df_list()
This diagnostic utility performs a comprehensive "Sanity Check" across a list of multiple dataframes, before running complex CFA or SEM models. It scans every column in every dataset (list of datasets) to identify potential mathematical "show-stoppers":
- non-numeric data
- missing values (NA/NaN),
- infinite values
- unexpected negative numbers
- It returns a single, organized summary table
- Allowing researchers to quickly verify data integrity across multiple experimental treatments or longitudinal waves, time series, at a glance.
- eg. `check_df_list(df_list_of_dt)`

--------

### fit_measures()
- It is extracting fit indices (χ2/df ratio, CFI, TLI, RMSEA, SRMR, etc.) from lavaan CFAs/SEMs and presenting them in a clean, vertical dataframe format, rounded in 3 decimals.
- Crucially, the function includes a use_scaled toggle to automatically switch between standard Maximum Likelihood (ML) indices and Robust (Scaled) indices, which are required when data is non-normal.
- It is mostly a helper function for other multi CFA/SEM data functions but it can be used independently too for single datasets 
- Simple use eg. `fit_measures(cfa_fit)`

--------

### outlier_remove_cfa()
This function automates multivariate outliers detection using Mahalanobis Distance, identifying cases that exhibit unusual patterns across multiple variables simultaneously. It features a flexible "sensitivity" and "cut-off" system to pinpoint extreme cases and provides a Chi-square Q-Q plot to visualize data normality.
- It handles missing values
- IDs exclusion provided
- Returning a cleaned dataset ready for robust structural equation modeling
- Reports exactly the rows that outliers exists
- It is mostly a helper function for run_qqplots_cfa() but it can used independently too for single datasets
- Sensitivity and cut_off options can be used to exclude outliers
- Simple use eg.
 ```
  outliers_res <- outlier_remove_cfa(data_dt$Time1, sensitivity = 1, 
                   cut_off =1, plotit = TRUE, id_name_var="id",
                   exld  = c("idt1"))
  ```
--------
 
### run_qqplots_cfa()
- It generates ggplot2 Chi-square Q-Q plots for a list of dataframes by using the previous function outlier_remove_cfa()
- it is based on Mahalanobis Distance.
- It can help identifies extreme cases across all datasets simultaneously. T
- Automatically arranges these multi plots into an organized grid.
- Ideal for initial data screening when you examine multiple datasets.
- IDs exclusion provided
- Sensitivity and cut_off options can be used to exclude outliers
```
run_qqplots_cfa(list_of_dataframes, sensitivity = 1, 
                cut_off = 1, plotit = FALSE, ncol_grid = 2, 
                exld  = c("idt1", "idt2"))
```
--------

### split_dt_subscales()
You can provide prefixes, and it splits your dataset (main scale) into subscales' datasets. Each dataset one subscale for easier manipulation, easier producing reliabilities etc. 
- It automates the creation of scale-specific datasets by identifying column name prefixes (e.g., "DEPR", "ANX"). 
- It supports complex grouping logic, allowing you to combine multiple prefixes into a single sub-dataset using the + operator (e.g., "DEPR + ANX").
- So, you can join two or more subscales together, and produce unified statistics for them 
- eg. `split_dt_subscales(list_of_dfs, prefix_patterns = c("SUB1", "SUB2", "SUB3"))`. eg. SUB1 = subscale 1 prefix eg. "CDS".

--------

### reliability_table()
Providing a list of dataframes, and splitted dataframes, it produce automatically all reliabilities per scale, per subscale in a neat table.Based on the psych::alpha function, it produces a summary table containing Cronbach's Alpha, Guttman's Lambda 6, and average inter-item correlations.
- A unique feature. It flags "negative items"—variables that correlate negatively with the scale total. This allows researchers to quickly identify items that require reverse-coding or exclusion before proceeding to CFA/SEM.
- eg. `reliability_table(splitted_list_of_dfs)` using the results of the split_dt_subscales().

--------

### lavaan_r2_sided()
- By providing a list of lavaan results (Multi CFA / Multi SEM)
- it bind all explained variances (R2) into a single wide-format, side-by-side comparison table eg. Case A R2, Case B R2, Case C R2 etc.
- Direct comparison of  explained variances (R2) across many treatments, cases, multiple SEMs, multiple CFAs.
- eg. `lavaan_r2_sided(list_of_lavaan_results_fits_from_a_list_of_dfs$r2)` 
--------

### mvn_all()
mvn_all() provides a batch-processing solution for testing these assumptions across multiple datasets (eg., across experimental groups or time points). 
- It performs both Univariate and Multivariate normality tests simultaneously.
- A smart exclusion filter to ignore ID and metadata columns
- Helping to decide maybe the SEM estimator (Standard ML vs Robust MLR/WLSMV).
- eg. `mvn_all(list_of_dfs, exld  = c("SUB_A", "SUB_B"))$univariate`. eg. SUB1 = subscale 1 prefix eg. excluding items/vars that dont work eg. "CDS".
--------

### mediation_multi_mlr()
- Automation of the estimation of complex mediation models across multiple datasets (eg., across different experimental conditions or time waves). 
- By default utilizing the Robust Maximum Likelihood (MLR) estimator\
- Therefore, it provides reliable standard errors and fit indices even when multivariate normality assumptions are violated.
- It produces semPaths plots for every model in a list of datasets in a 2x2 grid
- It returns Mediation/SEM lavaan fits, lavaan r2_values, lavaan standardized tables, lavaan fit_indices (eg. CFI, TLI etc.), mi_indices (top 5). 
- eg. mediation or SEM:
 ```
mediation_multi_mlr(data_list = list_of_dfs, model_list = list_of_lavaan_models, estimator="MLR",  
                                      check.gradient = FALSE,  std.lv = TRUE)
```
--------

### mediation_multi_WLSMV()
This function can produce lavaan WLSMV stats from multiple datasets and tidy them in summary tables. 
- It is specifically engineered when you like to use WLSMV estimator
- lavaan WLSMV estimator produces somewhat different lavaan statistics than ML or MLR. 
- Automates the calculation of Composite Reliability (Omega)
- Automates the calculation of Average Variance Extracted (AVE) for latent constructs.
- Dual-plotting engine (cause WLSMV created problems with semPATHS)
- Saves these high-resolution diagrams from both tidySEM and lavaanPlot into a dedicated directory (cause tidySEM utilizes View tab in Rstudio, and not Display tab).
- Specifically, it returns from a list of dataframes: med_fits (mediation/SEM fits), r2_values, lavaan std tables, WLSMV thresholds, reliabilities (Omega, AVE), and a plot list.
- eg. using WLSMV estimator: 
```
mediation_multi_WLSMV(data_list = list_of_dfs, model_list = list_of_lavaan_models,
                                    ordered = NULL,  estimator = "WLSMV" )
```

--------

### cfa_multi()
- Producing a list of CFAs from a list of dataframes eg. time series CFAs, Case A, Case B etc.
- it returns from a list of dataframes:
  - med_fits (mediation/SEM fits)
  - r2_values
  - lavaan std table
  - fit_indices
  - mi_indices
  - semPlots
  - eg. `cfa_multi(list_of_dfs, list_of_lavaan_models)`
  
```
# Use together with this function
# to produce multi plots nicely in a grid all together 
par(mfrow = c(1, 2))
cfa_res<-cfa_multi(.....)
lapply(cfa_res$plots, function(p_func) p_func())
```

--------

### cfa_range_table()
By Providing a list of lavaan std tables:
- It consolidates multiple std solution tables into a single, high-density ranged summary table.
  - eg. Time 1, Time 2, Time 3. It may produces 3 large std tables.  
- It identifies the minimum and maximum values for factor loadings, standard errors, and p-values across all models.
- Unique labeling each min and max value with a reference letter eg. 0.750a - 0.820c eg. T1=a, T2=b, T3=c
- With a single look, you know which dataframe produced which min / max values in std table
- It saves space & time, by producing easy & quick looking results for further assessment
- eg. `cfa_range_table(list_of_lavaan_fits$standardized)` 

--------

### fit_indx_bind()
By Providing a list of lavaan CFA/SEM results:
- Aggregate the results of multi-model analyses (fit indices) into a single comparison matrix. 
- Make a ncie table of Fit measures across many lavaan analyses eg. Time 1, Time 2, Time 3, all binded in a sngle table.
- Quick comparison & easy to assess fit indices across multiple lavaan CFA/SEM results.
- eg. ` fit_indx_bind(list_of_lavaan_fits$fit_indices)` 


