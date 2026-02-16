############################################################
#       Batch Q-Q Plot Generation (Multiple Datasets)      # 
############################################################

run_qqplots_cfa <- function(data_list,       id_name_var = NULL, 
                            sensitivity = 0, cut_off = 1,     
                            plotit = FALSE,
                            arrange_plots = TRUE,
                            ncol_grid = 3,
                            exld = c("ATT", "ARR")) {
  
  qqplot_list  <- list()  # To store ggplot objects for the grid
  results_list <- list()  # To store the actual outlier detection data
  
  for(nm in names(data_list)) {
    cat("Processing Q-Q Plot for:", nm, "\n")
    
    # 1. Call the outlier_remove_cfa function for the current dataset
    # This calculates Mahalanobis distances and flags outliers
    res <- outlier_remove_cfa(
      df_data_wt_id = data_list[[nm]],
      id_name_var = id_name_var,
      sensitivity = sensitivity,
      cut_off = cut_off,
      exld = exld,
      plotit = plotit # Set to FALSE to avoid messy base-R plots in loop
    )
    
    # 2. Prepare Theoretical Chi-square Quantiles
    # We need these to create the reference line for the Q-Q plot
    n <- nrow(data_list[[nm]])
    ppoints_n <- ppoints(n)
    # The degree of freedom (df) is the number of variables analyzed
    theo <- qchisq(ppoints_n, df = ncol(data_list[[nm]]))
    obs <- sort(res$mahal_distances)
    
    # 3. Create ggplot Q-Q plot
    # Using ggplot2 allows for much cleaner and professional-looking grid layouts
    df_plot <- data.frame(theo = theo, obs = obs)
    p <- ggplot(df_plot, aes(x = theo, y = obs)) +
      geom_point(alpha = 0.5) + # Alpha adds transparency to see overlapping points
      geom_abline(slope = 1, intercept = 0, color = "red", size = 1) +
      ggtitle(paste("Dataset:", nm)) +
      xlab("Theoretical Chi-square Quantiles") +
      ylab("Observed Mahalanobis Distances") +
      theme_minimal()
    
    qqplot_list[[nm]] <- p
    results_list[[nm]] <- res
  }
  
  # 4. Grid Arrangement
  # If enabled, uses grid.arrange to put all plots onto one single page
  # This makes it very easy to compare data quality across different groups/timepoints
  if(arrange_plots && length(qqplot_list) > 0) {
    do.call(gridExtra::grid.arrange, c(qqplot_list, ncol = ncol_grid))
  }
  
  # Return the results so the user can see which specific IDs were flagged
  return(list(
    results = results_list
  ))
}
