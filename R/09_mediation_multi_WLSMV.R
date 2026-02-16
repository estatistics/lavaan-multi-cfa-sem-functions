##############################################################################################
#                      Mediation Multi-Group Function (WLSMV for Categorical)                # 
##############################################################################################

mediation_multi_WLSMV <- function(data_list, model_list, ordered="joboffer", estimator="WLSMV",
                                  node_size = 1.8, edge_label_size = 1.5, arrow_width = 1) {
  
  # Create a directory to store all the generated plots automatically
  plot_dir <- "mediation_plots"
  if(!dir.exists(plot_dir)) dir.create(plot_dir)
  
  # Storage for all statistical outputs
  med_fits     <- list()
  r2_values    <- list()
  lavstd_list  <- list()
  mfit_indices <- list()
  thresholds   <- list() # Specific to categorical data (thresholds between categories)
  reliabs_res  <- list() # Composite reliability stats
  plot_list    <- list() 

  for (nm in names(data_list)) {
    if (!nm %in% names(model_list)) next
    
    cat("✅ Processing WLSMV Model for:", nm, "\n")
    
    # Fit the SEM model with 'ordered' variables specified
    med_fit <- lavaan::sem(model = model_list[[nm]], ordered = ordered, 
                           estimator = estimator, std.lv = TRUE, data = data_list[[nm]])
    
    # ---- Advanced Psychometrics: AVE & Omega ----
    # WLSMV users often need to prove the reliability of their latent constructs
    latents_med <- lavaan::lavNames(med_fit, type = "lv")
    latents_med <- latents_med[ !(latents_med %in% as.character(ordered))] 
    std_sol     <- standardizedSolution(med_fit, type = "std.all")
  
    rel_results  <- list()
    for(f in latents_med){
      # Extract standardized loadings for each latent factor
      loadings <- std_sol$est.std[std_sol$lhs == f & std_sol$op == "=~"]
      sum_loadings_sq <- sum(loadings)^2
      sum_sq_loadings <- sum(loadings^2)
      sum_error_var <- sum(1 - loadings^2)
      
      # Formula for Composite Reliability (Omega)
      omega <- sum_loadings_sq / (sum_loadings_sq + sum_error_var)
      # Formula for Average Variance Extracted (AVE)
      ave <- sum_sq_loadings / (sum_sq_loadings + sum_error_var)
      
      rel_results[[f]] <- c(Omega = round(omega, 3), AVE = round(ave, 3))
    }                                
                                     
    # --- Data Extraction ---
    med_fits[[nm]]      <- med_fit
    r2_values[[nm]]     <- round(as.data.frame(inspect(med_fit, "r2")), 3)
    lavstd_list[[nm]]   <- standardizedsolution(med_fit, type = "std.all")
    mfit_indices[[nm]]  <- tryCatch({ round(fit_measures(med_fit, use_scaled = TRUE), 3) }, error = function(e) NULL)
    thresholds[[nm]]    <- inspect(med_fit, "est")$tau
    reliabs_res[[nm]]   <- rel_results
    
    # --- Visualization 1: tidySEM ---
    # Generates a publication-quality tree-structure plot
    p_tidy <- tryCatch({
      lay <- get_layout(med_fit, layout_algorithm = "layout_as_tree")
      graph_data <- prepare_graph(med_fit, layout = lay, rect_width = 1, rect_height = 0.8)
      
      graph_data$nodes$size <- node_size 
      graph_data$edges$label_size <- edge_label_size 
      
      tp <- plot(graph_data) + theme_bw() + labs(title = paste(nm, "tidySEM"))
      ggsave(file.path(plot_dir, paste0("tidySEM_", nm, ".png")), tp, width = 8, height = 6)
      tp
    }, error = function(e) NULL)
    plot_list[[nm]] <- p_tidy
   
    # --- Visualization 2: lavaanPlot ---
    # Saves a high-resolution PNG using the DiagrammeR engine
    tryCatch({
      lp <- lavaanPlot(model = med_fit, coefs = TRUE, stand = TRUE, sig = 1.0)
      svg_code <- DiagrammeRsvg::export_svg(lp)
      rsvg::rsvg_png(charToRaw(svg_code), file.path(plot_dir, paste0("lavaanPlot_", nm, ".png")))
      cat("📷 Saved lavaanPlot for", nm, "\n")
    }, error = function(e) { cat("⚠️ lavaanPlot failed for", nm, "\n") })
  }
  
  # Arrange all tidySEM plots into a grid for easy comparison
  valid_plots <- plot_list[!sapply(plot_list, is.null)]
  if(length(valid_plots) > 0){
    print(cowplot::plot_grid(plotlist = valid_plots, ncol = 2, labels = "AUTO"))
  }
  
  return(list(fits    = med_fits, 
              r2_vals = r2_values,
              lavstd  = lavstd_list, 
              mfits   = mfit_indices,
              threshs = thresholds,
              reliabs = reliabs_res,
              plots   = plot_list))
}
