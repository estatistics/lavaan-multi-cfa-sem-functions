############################################################
#          Automated Software Citation Generator           # 
############################################################

generate_citations <- function() {
  
  # 1. Define the core software list
  # We pull the names of all libraries currently loaded in the session
  # that match the ones we initialized in init.R
  core_pkgs <- c("psych", "lavaan", "semPlot", "semTools", "MVN", 
                 "dplyr", "tibble", "interactions", "ggplot2", "patchwork", 
                 "gridExtra", "igraph", "purrr", "stringr", "tidySEM", 
                 "DiagrammeRsvg", "rsvg", "lavaanPlot", "ggplotify", "png", 
                 "grid", "cowplot")
  
  # 2. Get R and RStudio info
  software_names <- c("R", "RStudio")
  software_versions <- c(
    R.version.string,
    if(exists("RStudio.Version")) paste0("RStudio ", RStudio.Version()$version) else "Not in RStudio"
  )
  
  # 3. Loop through packages and grab versions automatically
  for (p in core_pkgs) {
    if (requireNamespace(p, quietly = TRUE)) {
      software_names <- c(software_names, p)
      software_versions <- c(software_versions, as.character(packageVersion(p)))
    }
  }
  
  # 4. Create the final data frame
  pkg_info <- data.frame(
    Software = software_names,
    Version = software_versions,
    stringsAsFactors = FALSE
  )
  
  # 5. Generate a simple text citation block for the manuscript
  cat("\n--- Manuscript Citation Helper ---\n")
  cat("All analyses were conducted in", R.version.string, "using the following packages:\n")
  cat(paste(core_pkgs, collapse = ", "), ".\n")
  cat("----------------------------------\n\n")
  
  return(pkg_info)
}
