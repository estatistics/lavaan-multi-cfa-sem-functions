############################################################
#             Multivariate Outlier Removal (CFA)           # 
############################################################

outlier_remove_cfa <- function(df_data_wt_id, id_name_var,
                               sensitivity = 3,
                               cut_off = 1,
                               plotit = TRUE,
                               exld = c("ATT", "ARR")) {
  
  # Safety check: If the dataset is empty, stop and return an empty structure
  if (nrow(df_data_wt_id) == 0) {
    warning("Dataset is empty; skipping.")
    return(list(
      data_out_id = df_data_wt_id,
      mahal_distances = numeric(0),
      outliers = character(0)
    ))
  }
  
  # ---- Helper: Remove rows with too many NAs ----
  # Mahalanobis distance cannot be calculated if rows have missing values
  delete.na <- function(df, n = 0) df[rowSums(is.na(df)) <= n, ]
  df_data_wt_id <- delete.na(df_data_wt_id)
  
  # ---- Remove ID column ----
  # We separate the ID so it doesn't interfere with the math, but keep the original df to return it later
  df_data <- df_data_wt_id[, !(colnames(df_data_wt_id) %in% id_name_var), drop = FALSE]
  
  # ---- Exclude variables by pattern (optional) ----
  # Allows skipping specific columns (like attention checks or irrelevant metadata)
  if (!is.null(exld) && length(exld) > 0) {
    excl_cols <- unique(unlist(lapply(exld, function(p) {
      grep(p, colnames(df_data))
    })))
    
    if (length(excl_cols) > 0) {
      df_data <- df_data[, -excl_cols, drop = FALSE]
    }
  }
  
  # ---- Safety check ----
  if (ncol(df_data) == 0) {
    stop("All variables excluded from Mahalanobis calculation.")
  }
  
  # ---- Mahalanobis distance calculations ----
  # This measures how far each person is from the "average" center of the data cloud
  mahal_data <- mahalanobis(df_data, colMeans(df_data), cov(df_data))
  ord_mahal <- sort(mahal_data, decreasing = TRUE)
  
  # Sensitivity: Flag the top X most extreme cases
  ids_mahal <- names(ord_mahal[1:sensitivity])
  
  # ---- Cut-off logic ----
  # Calculates the percentage of the distance relative to the maximum
  # and identifies "jumps" in distance between ranked cases
  mh_perc <- round((ord_mahal / max(ord_mahal, na.rm = TRUE)) * 100, 2)
  mh_diff <- mh_perc - c(mh_perc[-1], 0)
  mahal_out_vals <- mh_diff[mh_diff > cut_off]
  list_data_out <- names(mahal_out_vals)
  
  # ---- Create Clean Dataset ----
  # Filters out the identified outliers from the original dataframe (with IDs intact)
  mhdata_out_id <- df_data_wt_id[!(rownames(df_data_wt_id) %in% list_data_out), ]
  
  # ---- Visual Diagnostics ----
  # Plots the distances against a Chi-square distribution. 
  # Points far away from the red line are multivariate outliers.
  if (plotit) {
    par(mfrow = c(1, 1))
    qqplot(
      qchisq(ppoints(nrow(df_data)), df = ncol(df_data)),
      mahal_data,
      main = "Chi-square Q-Q Plot (Mahalanobis)",
      xlab = "Theoretical Chi-square Quantiles",
      ylab = "Mahalanobis Distances"
    )
    abline(0, 1, col = "red")
  }
  
  # ---- Return results ----
  list(
    data_out_id = mhdata_out_id, # The "cleaned" data
    mahal_distances = mahal_data, # Raw distance scores
    outliers = list_data_out     # List of removed IDs
  )
}
