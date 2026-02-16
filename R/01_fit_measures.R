############################################################
#             Function for Fit Indices Extraction          # 
############################################################

fit_measures <- function(fit_x, use_scaled = FALSE) {
  
  # Extract all available fit measures from the lavaan object
  all_fits <- lavaan::fitMeasures(fit_x)
  
  # ---- Determine which indices to keep ----
  # Robust estimators (like MLR or WLSMV) produce "scaled" indices. 
  # This section handles switching between standard and robust output.
  if (use_scaled) {
    # Identify all names that end in ".scaled"
    scaled_idx <- grep("\\.scaled$", names(all_fits), value = TRUE)
    
    # Define a set of priority scaled indices to extract
    keep <- c("nobs", "chisq.scaled", "df.scaled", "pvalue.scaled", scaled_idx)
    
    # Filter to only keep those that exist in the current model
    keep <- keep[keep %in% names(all_fits)]
    fits <- all_fits[keep]
    
    # Manually calculate the Scaled Chi-square/df ratio (common reporting metric)
    if (all(c("chisq.scaled","df.scaled") %in% names(fits))) {
      chsq_df <- round(fits["chisq.scaled"] / fits["df.scaled"], 3)
      names(chsq_df) <- "chisq/df.scaled"
      # Put the ratio at the front of the vector
      fits_out <- c(chsq_df, fits[setdiff(names(fits), c("chisq.scaled","df.scaled"))])
    } else {
      fits_out <- fits
    }
    
  } else {
    # Standard (Unscaled) indices for normal Maximum Likelihood (ML)
    standard_idx <- c("nobs", "chisq","df","pvalue",
                      "cfi","tli","ifi","nnfi","rfi","mfi","rni","gfi",
                      "rmsea","rmr","srmr","pnfi","pgfi","bic","aic","ecvi")
    
    keep <- standard_idx[standard_idx %in% names(all_fits)]
    fits <- all_fits[keep]
    
    # Calculate the standard Chi-square/df ratio
    if (all(c("chisq","df") %in% names(fits))) {
      chsq_df <- round(fits["chisq"] / fits["df"], 3)
      names(chsq_df) <- "chisq/df"
      fits_out <- c(chsq_df, fits[setdiff(names(fits), c("chisq","df"))])
    } else {
      fits_out <- fits
    }
  }
  
  # Round all values to 3 decimal places for publication readiness
  fits_out <- round(fits_out, 3)
  
  # Convert the vector into a clean data.frame for easier merging into tables
  df <- data.frame(value = fits_out)
  rownames(df) <- names(fits_out)
  
  return(df)
}
