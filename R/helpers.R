###############################################################
# Helper functions
###############################################################

check_duplicates <- function(df, merge_vars){
  # check if a dataframe is duplicated across any rows
  # returns TRUE if there are duplicates, false if not
  de_dup <- df %>%
    dplyr::select(all_of(merge_vars)) %>%
    anyDuplicated()
  if (de_dup == 0){
    return(FALSE)
  }
  else {
    return(TRUE)
  }
}

# replaces the vars
replace_var <- function(df, varname, suffix1 = ".x", suffix2 = ".y"){
  # coalesce .x and .y merged suffix variables
  return(dplyr::coalesce(df[[paste0(varname,suffix1)]], df[[paste0(varname,suffix2)]]))
}

# helper function that combines variables instead of using suffixes
replace_allvars <- function(df, varnames, suffix1 = ".x", suffix2 = ".y"){
  if (length(varnames) > 1){
  # iterate over a varlist and coalesce the merged suffix variables
  x_vars <- unlist(sapply(varnames, function(x) paste0(x, ".x")), use.names = FALSE)
  y_vars <- unlist(sapply(varnames, function(x) paste0(x, ".y")), use.names = FALSE)
  } else if (length(varnames == 1)) {
    x_vars <- paste0(varnames, ".x")
    y_vars <- paste0(varnames, ".y")
  } else{
    return(df)
  }
  for (i in varnames){
    df[i] <- replace_var(df, i)
  }
  # drop merged suffix varaibles
  df1 <- df %>%
    dplyr::select(!all_of(x_vars)) %>%
    dplyr::select(!all_of(y_vars))
  # return
  return(df1)
}
