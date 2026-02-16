############################################################
#       Comprehensive Multivariate Normality (MVN)         # 
############################################################

mvn_all <- function(data_list, 
                    mvn_test = "hz", 
                    univariate_test = "AD",
                    exld = NULL) {
  
  univariate_list   <- list()
  multivariate_list <- list()
  
  for(nm in names(data_list)) {
    cat("Processing MVN for:", nm, "\n")
    
    # ---- Internal Helper: Dynamic Variable Exclusion ----
    exclude_vars <- function(df) {
      # 1. Automatically exclude ID columns (e.g., ID, id_t1, ID_user)
      # The regex "^ID(_|$)" specifically looks for 'ID' at the start
      keep <- !grepl("^ID(_|$)", names(df), ignore.case = TRUE)
      
      # 2. Exclude user-specified patterns (e.g., demographics or metadata)
      if (!is.null(exld) && length(exld) > 0) {
        excl_cols <- unique(unlist(lapply(exld, function(p) {
          grepl(p, names(df))
        })))
        keep <- keep & !excl_cols
      }
      
      df[, keep, drop = FALSE]
    }
    
    # Apply the exclusion logic to the current dataset
    df_to_test <- exclude_vars(data_list[[nm]])
    
    # ---- Safety Check ----
    # Prevents the MVN package from crashing if a dataset has zero columns
    if (ncol(df_to_test) == 0) {
      warning(sprintf("Skipping MVN for '%s': no variables left after exclusions", nm))
      next
    }
    
    # ---- Run MVN Test Suite ----
    # Defaults to Henze-Zirkler (hz) for Multivariate and Anderson-Darling (AD) for Univariate
    mvn_res <- MVN::mvn(
      data = df_to_test,
      mvn_test = mvn_test,
      univariate_test = univariate_test,
      tidy = TRUE # Returns clean dataframes instead of messy list objects
    )
    
    # ---- Result Aggregation ----
    # We tag the results with the dataset name so they remain identifiable after merging
    univariate_list[[nm]]   <- mvn_res$univariate_normality
    multivariate_list[[nm]] <- mvn_res$multivariate_normality
  }
  
  # Return a list containing two master tables: one for items, one for whole datasets
  list(
    univariate   = if(length(univariate_list) > 0) do.call(rbind, univariate_list) else NULL,
    multivariate = if(length(multivariate_list) > 0) do.call(rbind, multivariate_list) else NULL
  )
}
