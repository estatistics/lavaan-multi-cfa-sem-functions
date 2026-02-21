############################################################
#          Automated Software Citation Generator           # 
############################################################

generate_apa_citations <- function() {
  
  core_pkgs <- c("psych", "lavaan", "semPlot", "semTools", "MVN", 
                 "dplyr", "tibble", "interactions", "ggplot2", "patchwork", 
                 "gridExtra", "igraph", "purrr", "stringr", "tidySEM", 
                 "DiagrammeRsvg", "rsvg", "lavaanPlot", "ggplotify", "png", 
                 "grid", "cowplot")
  
  cat("\n--- APA-Style Package Citations ---\n\n")
  
  # R itself
  r_cit <- citation()
  cat(paste0("R: ", r_cit$textVersion, "\n\n"))
  
  # RStudio
  if (exists("RStudio.Version")) {
    rs_cit <- paste0("RStudio: RStudio ", RStudio.Version()$version, "\n")
    cat(rs_cit, "\n")
  }
  
  # Loop through packages
  for (p in core_pkgs) {
    if (requireNamespace(p, quietly = TRUE)) {
      cit <- citation(p)
      
      # Some packages have multiple citations; usually take the first
      if (length(cit) > 1) cit <- cit[[1]]
      
      # Print APA-like citation
      cat(paste0(cit$textVersion, "\n\n"))
    } else {
      cat(paste0("Package '", p, "' not installed.\n\n"))
    }
  }
  
  cat("--- End of Citations ---\n")
}

# Example usage
pkg_citations <- generate_apa_citations()
