############################################################
#          Initialization Script for Lavaan Toolkit        #
############################################################

# 1. Define the full list of required packages
pkgs <- c(
  "psych", "lavaan", "semPlot", "semTools", "MVN", 
  "dplyr", "tibble", "interactions", "ggplot2", "patchwork", 
  "gridExtra", "igraph", "purrr", "stringr", "tidySEM", 
  "DiagrammeRsvg", "rsvg", "lavaanPlot", "ggplotify", "png", 
  "grid", "cowplot"
)

# 2. Function to check and install missing packages
install_if_missing <- function(p) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, dependencies = TRUE)
  }
}

# Run the installation check
invisible(lapply(pkgs, install_if_missing))

# 3. Load all libraries quietly
# We use suppressPackageStartupMessages to keep the console clean
invisible(lapply(pkgs, function(p) {
  suppressPackageStartupMessages(library(p, character.only = TRUE))
}))

# 4. Automatically source all functions in the R/ folder
# This ensures that files 00 through 12 are loaded in order
if (dir.exists("R")) {
  function_files <- list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)
  # Sorting ensures 00 loads before 01, etc.
  function_files <- sort(function_files) 
  invisible(lapply(function_files, source))
  cat("\n🚀 Toolkit Ready! 13 functions and 22 libraries loaded.\n")
} else {
  stop("❌ Error: 'R' folder not found. Please check your working directory.")
}

cat("Run 'generate_citations()' to get version info for your manuscript.\n")
