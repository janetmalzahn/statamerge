########################################
# stata_merge function
# Janet Malzahn
# July 17, 2022
########################################
statamerge <- function(master, using, mergetype = "1:1", merge_vars,
                        keepusing, suffix1 = ".x", suffix2 = ".y"){
  # check for uniqueness in master and using
  if ((check_duplicates(master,merge_vars)) & (mergetype != "m:1")){
    stop("Master is not unique on merge variables")
  }
  if ((check_duplicates(using, merge_vars)) & (mergetype != "1:m")){
    stop("Using is not unique on merge variables")
  }
  if (length(intersect(colnames(master),
                       c("statamergemaster",
                         "statamergeusing",
                         "merge_code")))!= 0){
    stop("Rename variables statamergemaster, statamergeusing,
         or merge_code in master to avoid variable name conflicts")
  }
  if (length(intersect(colnames(using),
                       c("statamergemaster",
                         "statamergeusing",
                         "merge_code")))!= 0){
    stop("Rename variables statamergemaster, statamergeusing,
         or merge_code in master to avoid variable name conflicts")
  }

  # print message if no merge_type specified
  print(paste("Performing", mergetype, "merge"))

  # make extravariables to use at the ends
  master$statamergemaster <- 1
  using$statamergeusing <- 2

  # merge datasets together
  merged_df <- full_join(master, using, by = all_of(merge_vars))

  # get overlapping columns not in merge variable
  overlap_vars <- setdiff(intersect(colnames(master),
                                    colnames(using)),
                          merge_vars)

  # coalesce .x and .y variables so overlapping vars are just one var instead of 2
  merged_df <- replace_allvars(df = merged_df,
                               varnames = overlap_vars,
                               suffix1 = suffix1,
                               suffix2 = suffix2)

  # make a merge key and keep relevant variables
  merged_df <- merged_df %>%
    rowwise() %>%
    dplyr::mutate(merge_code = sum(statamergemaster,
                                   statamergeusing,
                                   na.rm = TRUE)) %>%
    ungroup() %>%
    # drop intermediate statamergemaster statamergeusing vars
    dplyr::select(!c(statamergemaster,statamergeusing))

  # print results
  merged_df %>%
    group_by(merge_code) %>%
    summarize(n = n()) %>%
    print()

  return(merged_df)
}

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

replace_var <- function(df, varname, suffix1 = ".x", suffix2 = ".y"){
  # coalesce .x and .y merged suffix variables
  return(coalesce(df[[paste0(varname,suffix1)]], df[[paste0(varname,suffix2)]]))
}

replace_allvars <- function(df, varnames, suffix1 = ".x", suffix2 = ".y"){
  # iterate over a varlist and coalesce the merged suffix variables
  x_vars <- sapply(varnames, function(x) paste0(x, ".x"))
  y_vars <- sapply(varnames, function(x) paste0(x, ".y"))
  for (i in varnames){
    df[i] <- replace_var(df, i)
  }
  # drop merged suffix varaibles
  df1 <- df %>%
    dplyr::select(!x_vars) %>%
    dplyr::select(!y_vars)
  # return
  return(df1)
}

