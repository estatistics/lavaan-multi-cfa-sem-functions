############################################################
#       CFA Range Table (Min/Max Summary Table)            # 
############################################################

cfa_range_table <- function(cfa_list,
                            num_cols = c("est.std", "se", "z", "pvalue",
                                         "ci.lower", "ci.upper")) {
  # 1. Assign a letter to each CFA (a, b, c...) for identification
  # If you have 3 timepoints, they will be labeled a, b, and c.
  tbl_letters <- letters[seq_along(cfa_list)]
  
  # ---- Internal Helper: Range Labeling ----
  # Formats the result as "MinLetter - MaxLetter" (e.g., "0.750a - 0.820c")
  range_label <- function(x, letters) {
    x_r <- round(x, 3)
    fmt <- function(v) sprintf("%.3f", v) # Force exactly 3 decimal places
    paste0(
      fmt(x_r[which.min(x_r)]), letters[which.min(x_r)], "-",
      fmt(x_r[which.max(x_r)]), letters[which.max(x_r)]
    )
  }
  
  # 2. Combine and Clean Data ----
  # This merges all CFA results and strips time-suffixes (like _t1)
  # so that "Item1_t1" and "Item1_t2" are recognized as the same item.
  cfa_long <- purrr::map2_dfr(
    cfa_list,
    tbl_letters,
    ~ .x %>%
      dplyr::mutate(
        table_letter = .y,
        lhs_base = stringr::str_remove(lhs, "_t.*$"), # Removes suffixes from Latents
        rhs_base = stringr::str_remove(rhs, "_t.*$")  # Removes suffixes from Items
      )
  )
  
  # 3. Build Summary ----
  # Groups by variable and operation (e.g., factor loading =~ or covariance ~~)
  # and applies the range_label function to every numerical column.
  cfa_long %>%
    dplyr::group_by(lhs_base, op, rhs_base) %>%
    dplyr::summarise(
      dplyr::across(dplyr::all_of(num_cols), ~ range_label(.x, table_letter)),
      .groups = "drop"
    ) %>%
    dplyr::rename(lhs = lhs_base, rhs = rhs_base)
}
