############################################################
#             Fit Indices Bind Function                    # 
############################################################

fit_indx_bind <- function(fit_indices_list) {
    # Combines multiple fit measure dataframes (from fit_measures()) side-by-side
    # do.call(cbind, ...) ensures that CFI, TLI, RMSEA, etc., stay in their rows
    # while each dataset gets its own column.
    df <- do.call(cbind, fit_indices_list)
    
    # Assigns the dataset names (e.g., "Time1", "Time2") as column headers
    colnames(df) <- names(fit_indices_list)
    
    return(df)
}
