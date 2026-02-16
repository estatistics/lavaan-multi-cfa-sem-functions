############################################################
#             List of Datasets Error Check                 # 
############################################################

check_df_list <- function(df_list) {
  # Ensures the input is a list; if not, the function stops immediately
  stopifnot(is.list(df_list))
  
  # If the list isn't named (e.g., list(df1, df2)), give it default names 
  # so the output table is easy to read
  if(is.null(names(df_list))) {
    names(df_list) <- paste0("df_", seq_along(df_list))
  }
  
  # Loop through each dataset in the list
  res <- lapply(names(df_list), function(nm) {
    df <- df_list[[nm]]
    
    # Analyze every column in the current dataframe for common data issues
    col_info <- lapply(df, function(col) {
      list(
        is_numeric   = is.numeric(col),
        is_integer   = is.integer(col),
        all_na       = all(is.na(col)),     # True if the whole column is empty
        any_na       = any(is.na(col)),     # True if there's at least one hole
        any_nan      = any(is.nan(col)),    # True if there are 'Not a Number' errors
        any_inf      = any(is.infinite(col)), # True if there are 'Infinite' values
        any_zero     = any(col == 0, na.rm = TRUE),      # Checks for zeros (common in Likert scales)
        any_negative = any(col < 0, na.rm = TRUE)        # Checks for negatives (often error codes)
      )
    })
    
    # Transform the list of column stats into a clean dataframe
    col_df <- do.call(rbind, lapply(col_info, function(x) as.data.frame(x, stringsAsFactors=FALSE)))
    col_df$column <- rownames(col_df)
    rownames(col_df) <- NULL
    col_df$dataset <- nm # Keep track of which dataset the column belongs to
    col_df
  })
  
  # Stack the results from all datasets into one final master table
  final_df <- do.call(rbind, res)
  
  # Reorder columns for a logical flow (ID info first, then logical checks)
  final_df <- final_df[, c("dataset", "column", "is_numeric", "is_integer", "all_na", "any_na",
                             "any_nan", "any_inf", "any_zero", "any_negative")]
  
  return(final_df)
}
