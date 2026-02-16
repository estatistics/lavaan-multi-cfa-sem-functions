##############################################################################################
#                         Mediation Multi-Group Function (MLR)                               # 
##############################################################################################

mediation_multi_mlr <- function(data_list, model_list, estimator="MLR", check.gradient=FALSE, std.lv = TRUE) {
  
  # Prepare storage lists for various model outputs
  med_fits     <- list() # Raw lavaan objects
  r2_values    <- list() # Explained variance (R-squared)
  lavstd_list  <- list() # Standardized path coefficients
  mfit_indices <- list() # Fit measures (CFI, TLI, etc.)
  mi_indices   <- list() # Modification indices for model improvement
  
  # Optional: plotting setup
  # Creates a 2x2 window so you can see 4 mediation diagrams at once
  old_par <- par(mfrow = c(2, 2))      
  on.exit(par(old_par))                # Ensures plotting settings reset after the function ends
  
  # Loop through all datasets in your list
  for (nm in names(data_list)) {
    
    # ---- Name Validation ----
    # Ensures there is a corresponding model string for every dataset provided
    if (!nm %in% names(model_list)) {
      cat( "❌ Data/model names DO NOT match: skipping Mediation for", nm, "\n"  )
      next  }
    
    cat("✅ Data/model names match: Fitting Mediation for",  nm, "\n" )
    
    # ---- Model Fitting ----
    # Uses the 'sem' function. Iter.max is set high to help complex models converge.
    med_fit <- lavaan::sem(  model = model_list[[nm]], std.lv = std.lv,
                             data   = data_list[[nm]], estimator=estimator, 
                             check.gradient=check.gradient, control = list(iter.max = 10000) )
    
    # ---- Diagnostic: Modification Indices ----
    # Wraps in tryCatch because MI fails if the model is perfectly fit or singular
    mi_indx <- tryCatch({
      mi <- modindices(med_fit)
      # Specifically look for correlated errors (~~) with high impact (mi >= 1)
      dm <- mi[mi$op == "~~" & mi$mi >= 1, ]
      dm <- dm[order(dm$mi, decreasing = TRUE), ]
      head(dm, 5) # Show the top 5 ways to improve the model
    }, error = function(e) {
      cat("⚠️  MI skipped (singular information matrix or non-convergence)\n")
      NULL  })
    
    # ---- Model Fit Extraction ----
    # Calls your helper function 'fit_measures' defined in R/00_helpers.R
    fitidx <- tryCatch({  
      round(fit_measures(med_fit, use_scaled = (estimator == "MLR")), 3)
    }, error = function(e) {
      cat("⚠️  fit indices skipped (model did not converge)\n")
      NULL })
    
    # ---- Result Storage ----
    med_fits[[nm]]      <- med_fit
    r2_values[[nm]]     <- round(as.data.frame(inspect(med_fit, "r2")), 3)
    lavstd_list[[nm]]   <- standardizedsolution(med_fit, type = "std.all")
    mfit_indices[[nm]] <- fitidx
    mi_indices[[nm]]   <- mi_indx
    
    # ---- Visualizing the Mediation Path ----
    # Automatically generates a path diagram for every model in the loop
    semPaths(
      med_fit,
      what = "std",           # Show standardized coefficients
      layout = "circle",      # Clean geometric layout
      mar = c(2, 7, 2, 6),
      sizeMan = 6, sizeLat = 5,
      edge.label.cex = 1.2,   # Make numbers readable
      fade = FALSE,           # Keep paths bold
      residuals = TRUE        # Show error variances
    )
  }
  
  # Return a structured list containing all statistical and diagnostic data
  return(list(
    fits         = med_fits,
    r2           = r2_values,
    standardized = lavstd_list,
    fit_indices  = mfit_indices,
    mi_indices   = mi_indices
  ))
}
