 scale_descriptives <- function(dt,
                                 prefix_patterns,
                                 exld = NULL,
                                 incl = NULL,      # e.g. c("ICAWS","OCS")
                                 score_type = c("mean", "sum"),
                                 add_total = FALSE,
                                 digits = 2) {
    
    library(dplyr)
    library(purrr)
    
    score_type <- match.arg(score_type)
    
    # 1️⃣ Remove excluded variables
    if (!is.null(exld)) {
      dt <- dt %>% select(-any_of(exld))
    }
    
    # 2️⃣ Split into subscales
    split_list <- lapply(prefix_patterns, function(prefix) {
      dt %>% select(starts_with(prefix))
    })
    names(split_list) <- prefix_patterns
    
    # 3️⃣ Create optional joined scale
    if (!is.null(incl)) {
      
      # check validity
      if (!all(incl %in% names(split_list))) {
        stop("Some 'incl' subscales not found in prefix_patterns.")
      }
      
      joined_name <- paste(incl, collapse = "_")
      split_list[[joined_name]] <- bind_cols(split_list[incl])
    }
    
    # 4️⃣ Optionally add total
    if (add_total) {
      split_list$Total <- bind_cols(split_list)
    }
    
    # 5️⃣ Compute descriptives
    results <- map_dfr(
      split_list,
      function(df) {
        
        scale_score <- if (score_type == "mean") {
          rowMeans(df, na.rm = TRUE)
        } else {
          rowSums(df, na.rm = TRUE)
        }
        
        tibble(
          Mean = mean(scale_score, na.rm = TRUE),
          SD   = sd(scale_score, na.rm = TRUE),
          Min  = min(scale_score, na.rm = TRUE),
          Max  = max(scale_score, na.rm = TRUE),
          N    = sum(!is.na(scale_score))
        )
      },
      .id = "Scale"
    )
    
    results %>%
      mutate(across(where(is.numeric), ~ round(.x, digits)))
  }
