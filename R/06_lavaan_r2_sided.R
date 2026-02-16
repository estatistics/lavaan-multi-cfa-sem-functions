############################################################
#           Lavaan R-Squared Side-by-Side Table           # 
############################################################

lavaan_r2_sided <- function(r2_list, round_djigits = 3) {
  # r2_list: A named list of data frames (extracted from lavaan)
  # round_djigits: Precision for the R² values
  
  datasets <- names(r2_list)
  
  # Assumes all datasets in the list have the same number of variables 
  # (e.g., comparing the same model across different time points)
  n <- nrow(r2_list[[1]])  
  
  # ---- 1. Column Preparation ----
  # For each dataset, extract the variable names and their corresponding R²
  cols_list <- lapply(datasets, function(nm) {
    df <- r2_list[[nm]]
    # Extract first column (R2) and round it
    r2 <- round(df[, 1], round_djigits)
    # Extract rownames (Variable names)
    vars <- rownames(df)
    cbind(vars, r2)
  })
  
  # ---- 2. Merge Logic ----
  # Combine the columns side-by-side (horizontally)
  wide_table <- do.call(cbind, cols_list)
  
  # Add a simple index row to keep the table organized
  wide_table <- cbind(index = 1:n, wide_table)
  
  # Convert to a standard data frame for better handling in R
  wide_table <- as.data.frame(wide_table, stringsAsFactors = FALSE)
  
  # ---- 3. Dynamic Renaming ----
  # Create clear headers like 'T1_var', 'T1_R2', 'T2_var', 'T2_R2'
  new_colnames <- c("index")
  for(nm in datasets) {
    new_colnames <- c(new_colnames, paste0(nm, "_var"), paste0(nm, "_R2"))
  }
  colnames(wide_table) <- new_colnames
  
  return(wide_table)
}
