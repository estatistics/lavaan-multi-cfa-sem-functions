############################################################
#          Automated Software Citation Generator           # 
############################################################



generate_citations <- function(pkgs, include_r = TRUE, include_rstudio = TRUE) {
  
  format_authors_apa <- function(cit) {
    authors_obj <- cit$author
    if (is.null(authors_obj)) return("Unknown Author")
    
    formatted <- sapply(authors_obj, function(p) {
      # Handle cases where family is NULL but given contains the full name (like your 'psych' example)
      family <- if (!is.null(p$family)) paste(p$family, collapse = " ") else ""
      given  <- if (!is.null(p$given)) paste(p$given, collapse = " ") else ""
      
      if (nchar(family) > 0 && nchar(given) > 0) {
        # Standard: Revelle, W.
        given_parts <- unlist(strsplit(given, "[ -]"))
        initials <- paste0(substr(given_parts, 1, 1), ".", collapse = " ")
        return(paste0(family, ", ", initials))
      } else if (nchar(family) > 0) {
        # Group Author: R Core Team
        return(family)
      } else if (nchar(given) > 0) {
        # Edge case: All name info in 'given' (William Revelle)
        # We try to split it to move the last word to the front for APA
        parts <- unlist(strsplit(given, " "))
        if (length(parts) > 1) {
          last_name <- parts[length(parts)]
          initials <- paste0(substr(parts[-length(parts)], 1, 1), ".", collapse = " ")
          return(paste0(last_name, ", ", initials))
        }
        return(given)
      }
      return("Unknown Author")
    })
    
    formatted <- trimws(formatted)
    n <- length(formatted)
    if (n == 1) return(formatted)
    if (n == 2) return(paste(formatted, collapse = " & "))
    return(paste0(paste(formatted[-n], collapse = ", "), ", & ", formatted[n]))
  }
  
  build_apa_string <- function(cit) {
    if (length(cit) > 1) cit <- cit[[1]]
    
    authors <- format_authors_apa(cit)
    year    <- if (!is.null(cit$year)) cit$year else format(Sys.Date(), "%Y")
    
    title   <- gsub("[{}]", "", cit$title)
    title   <- gsub("\\\\texttt", "", title)
    title   <- gsub("\n", " ", title)
    
    note    <- if (!is.null(cit$note)) paste0(cit$note, ".") else ""
    doi_str <- if (!is.null(cit$doi)) paste0("https://doi.org/", cit$doi) else ""
    url_str <- if (!is.null(cit$url)) cit$url else ""
    
    apa <- paste0(authors, " (", year, "). *", title, "*.", 
                  if (note != "") paste0(" ", note) else "",
                  if (doi_str != "") paste0(" ", doi_str) else "",
                  if (url_str != "" && url_str != doi_str) paste0(" ", url_str) else "")
    return(trimws(apa))
  }
  
  pkg_names <- c()
  citations_only <- c()
  
  # 1. R Core
  if (include_r) {
    pkg_names <- c(pkg_names, "R")
    citations_only <- c(citations_only, build_apa_string(citation()))
  }
  
  # 2. RStudio
  if (include_rstudio) {
    pkg_names <- c(pkg_names, "RStudio")
    citations_only <- c(citations_only, "Posit team (2025). *RStudio: Integrated Development Environment for R*. Posit Software, PBC. http://www.posit.co/")
  }
  
  # 3. Packages
  for (p in pkgs) {
    if (requireNamespace(p, quietly = TRUE)) {
      pkg_names <- c(pkg_names, p)
      citations_only <- c(citations_only, build_apa_string(citation(p)))
    }
  }
  
  # Alphabetical Sort
  sorting_index <- order(citations_only)
  
  return(list(
    Packages = pkg_names[sorting_index],
    Citations = citations_only[sorting_index]
  ))
}
  cat("--- End of Citations ---\n")
}

# Example usage
pkg_citations <- generate_apa_citations()
