############################################################
#                Internal Reliability Table                # 
############################################################

reliability_table <- function(data_list, check.keys = FALSE, exld = NULL) {
  
  # ---- 1. Input Standardization ----
  # If the user provides just one dataframe, wrap it in a list so the loop still works
  if (is.data.frame(data_list) || is.matrix(data_list)) {
    data_list <- list(scale1 = as.data.frame(data_list))
  }
  stopifnot(is.list(data_list))
  
  # ---- 2. Internal Helper: Pattern-based Variable Exclusion ----
  exclude_vars <- function(df) {
    keep <- rep(TRUE, ncol(df))
    
    if (!is.null(exld) && length(exld) > 0) {
      # Supports the "Group + Group" syntax used in your other functions
      groups <- lapply(exld, function(x) trimws(unlist(strsplit(x, "\\+"))))
      patterns <- unique(unlist(groups))
      
      for (p in patterns) {
        keep <- keep & !grepl(p, colnames(df))
      }
    }
    df[, keep, drop = FALSE]
  }
  
  # ---- 3. Main Reliability Calculation Loop ----
  main_out <- lapply(names(data_list), function(nm) {
    x <- as.data.frame(data_list[[nm]])
    x <- exclude_vars(x)  # Filter variables before analysis
    
    if (ncol(x) < 2) {
      warning(sprintf("Dataset '%s' needs at least 2 variables for Alpha; skipping.", nm))
      return(NULL)
    }
    
    # Use the psych package to compute Cronbach's Alpha
    a <- psych::alpha(x, check.keys = check.keys, warnings = FALSE)
    df <- as.data.frame(a$total)
    df$scale <- nm
    
    # Select key psychometric metrics for publication tables
    cols <- c("scale","raw_alpha","std.alpha","G6(smc)","average_r","S/N","ase","mean","sd","median_r")
    cols <- cols[cols %in% colnames(df)]
    df <- df[, cols, drop = FALSE]
    
    # Clean up decimals
    num_cols <- sapply(df, is.numeric)
    df[, num_cols] <- round(df[, num_cols], 3)
    
    df
  })
  
  reliability_df <- do.call(rbind, main_out)
  rownames(reliability_df) <- NULL
  
  # ---- 4. Diagnostic: Detecting Problematic Items ----
  # This part checks "Alpha if item dropped" to find items that correlate negatively 
  # with the total scale (indicates coding errors or bad items)
  neg_alpha_out <- lapply(names(data_list), function(nm) {
    x <- as.data.frame(data_list[[nm]])
    x <- exclude_vars(x)
    
    if (ncol(x) < 1) return(NULL)
    
    a <- psych::alpha(x, check.keys = FALSE, warnings = FALSE)
    alpha_drop <- as.data.frame(a$alpha.drop)
    
    # Flag items that, if removed, significantly improve the scale or show negative correlation
    neg_items <- alpha_drop[alpha_drop$raw_alpha < 0, , drop = FALSE]
    if (nrow(neg_items) > 0) {
      neg_items$item <- rownames(neg_items)
      neg_items$dataset <- nm
      rownames(neg_items) <- NULL
      
      cols_keep <- intersect(
        c("dataset","item","raw_alpha","std.alpha","average_r","r.drop","r.with.total"),
        colnames(neg_items)
      )
      neg_items <- neg_items[, cols_keep, drop = FALSE]
      return(neg_items)
    } else {
      return(NULL)
    }
  })
  
  neg_alpha_df <- do.call(rbind, neg_alpha_out)
  
  # Return a list containing both the clean summary and the diagnostic errors
  if (is.null(neg_alpha_df) || nrow(neg_alpha_df) == 0) {
    message("No items with negative raw_alpha found in any dataset.")
    neg_alpha_df <- data.frame()
  }
  
  list(
    reliability     = reliability_df,
    negative_items  = neg_alpha_df
  )
}
