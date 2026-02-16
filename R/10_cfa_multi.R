############################################################
#                Batch CFA Multi-Function                  # 
############################################################

cfa_multi <- function(data_list, model_list) {
  
  # Prepare storage lists for batch results
  cfa_fits     <- list()
  r2_values    <- list()
  lavstd_list  <- list()
  mfit_indices <- list()
  mi_indices   <- list()
  plots_cfa    <- list()
  
  # Setup plotting grid: displays 4 models at once (2 rows, 2 columns)
  old_par <- par(mfrow = c(2, 2))      
  on.exit(par(old_par))                # Restores original plot settings when finished
  
  # Iterates through each dataset provided in the list
  for (nm in names(data_list)) {
    
    # ---- Name Validation ----
    # Checks if there is a corresponding model definition for the current dataset
    if (!nm %in% names(model_list)) {
      cat( "❌ Data/model names DO NOT match: skipping CFA for", nm, "\n"  )
      next  }
    
    cat("✅ Data/model names match: Fitting CFA for",  nm, "\n" )
    
    # ---- Fit CFA Model ----
    # Uses standard CFA settings with latent variables scaled to 1 (std.lv = TRUE)
    cfa_fit <- lavaan::cfa(  model = model_list[[nm]], std.lv = TRUE,
                             data   = data_list[[nm]]  )
    
    # ---- Diagnostic: Modification Indices ----
    # Searches for suggested paths to improve model fit
    mi_indx <- tryCatch({
      mi <- modindices(cfa_fit)
      # Focuses on correlated errors (~~) that would significantly drop Chi-square
      dm <- mi[mi$op == "~~" & mi$mi >= 1, ]
      dm <- dm[order(dm$mi, decreasing = TRUE), ]
      head(dm, 5) # Extracts top 5 suggestions
    }, error = function(e) {
      cat("⚠️  MI skipped (singular information matrix)\n")
      NULL  })
    
    # ---- Extract Fit Stats ----
    # Uses the 'fit_measures' helper to get CFI, TLI, RMSEA, and SRMR
    fitidx <- tryCatch({  round(fit_measures(cfa_fit), 3)
    }, error = function(e) {
      cat("⚠️  fit indices skipped (model did not converge)\n")
      NULL })
    
    # ---- Result Storage ----
    cfa_fits[[nm]]      <- cfa_fit
    r2_values[[nm]]     <- round(as.data.frame(inspect(cfa_fit, "r2")), 3)
    lavstd_list[[nm]]   <- standardizedsolution(cfa_fit, type = "std.all")
    mfit_indices[[nm]]  <- fitidx
    mi_indices[[nm]]    <- mi_indx
    
    # ---- Visualizing the Factor Structure ----
    # A "Function Factory" is used here to 'lock' the cfa_fit object.
    # This prevents the common error where only the last plot is saved in a loop.
    plots_cfa[[nm]] <- (function(f_fit) {
      force(f_fit) 
      function(...) {
        semPlot::semPaths(
          f_fit, 
          what = "std",       # Standardized loadings
          layout = "tree",    # Factor on top, items on bottom
          mar = c(2, 7, 2, 6),
          sizeMan = 6, sizeLat = 5,
          edge.label.cex = 1.2,
          rotation = 2,       # Rotates the plot for better horizontal fit
          residuals = TRUE
        )
      }
    })(cfa_fit)
  }
  
  # Return the complete analysis suite
  return(list(
    fits         = cfa_fits,
    r2           = r2_values,
    standardized = lavstd_list,
    fit_indices  = mfit_indices,
    mi_indices   = mi_indices,
    plots        = plots_cfa
  ))
}

# in order to produce in a grid plots
# par(mfrow = c(1, 2))
# lapply(cfa_res$plots, function(p_func) p_func())

                          
