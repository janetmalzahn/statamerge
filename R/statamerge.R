########################################
# stata_merge function
# Janet Malzahn
# July 17, 2022
########################################
#' Title
#'
#' @param master A dataframe containing the primary data
#' @param using A dataframe containing the data to merge to the primary data
#' @param mergetype A string that denotes the type of merge to perform (1:1, m:1, 1:m)
#' @param merge_vars A vector of the variables to merge the data on
#' @param suffix1 A string denoting an alternate intermediate suffix for the join (.x)
#' @param suffix2 A string denoting an alternate intermediate suffix for the join (.y)
#'
#' @return A merged dataframe
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' statamerge(dplyr::band_instruments, dplyr::band_members, mergetype = "1:1", merge_vars = "name")
#'
#' @export
statamerge <- function(master, using, mergetype = "1:1", merge_vars,
                       suffix1 = ".x", suffix2 = ".y"){
  # check for uniqueness in master and using
  if ((check_duplicates(master,merge_vars)) & (mergetype != "m:1")){
    stop("Master is not unique on merge variables")
  }
  if ((check_duplicates(using, merge_vars)) & (mergetype != "1:m")){
    stop("Using is not unique on merge variables")
  }
  if (length(generics::intersect(colnames(master),
                       c("statamergemaster",
                         "statamergeusing",
                         "merge_code")))!= 0){
    stop("Rename variables statamergemaster, statamergeusing,
         or merge_code in master to avoid variable name conflicts")
  }
  if (length(generics::intersect(colnames(using),
                       c("statamergemaster",
                         "statamergeusing",
                         "merge_code")))!= 0){
    stop("Rename variables statamergemaster, statamergeusing,
         or merge_code in using to avoid variable name conflicts")
  }

  # print message if no merge_type specified
  print(paste("Performing", mergetype, "merge"))

  # get overlapping columns not in merge variable
  overlap_vars <- generics::setdiff(generics::intersect(colnames(master),
                                                        colnames(using)),
                                    merge_vars)

  # make extravariables to use at the ends
  master$statamergemaster <- 1
  using$statamergeusing <- 2

  # make extra variable to denote if all merge_columns are missing
  master <- master %>%
    dplyr::mutate(statamergemissing = ifelse(dplyr::if_all(merge_vars, .fns = is.na), 3, 1))
  using <- using %>%
    dplyr::mutate(statamergemissing = ifelse(dplyr::if_all(merge_vars, .fns = is.na), 2, 1))

  # merge datasets together

  merged_df <- dplyr::full_join(master,
                                using,
                                by = tidyselect::all_of(c(merge_vars,
                                                          "statamergemissing")),
                                na_matches = "na") %>%
    dplyr::select(-statamergemissing)

  print(colnames(merged_df))


  # coalesce .x and .y variables so overlapping vars are just one var instead of 2
  merged_df <- replace_allvars(df = merged_df,
                               varnames = as.vector(overlap_vars),
                               suffix1 = suffix1,
                               suffix2 = suffix2)

  # make a merge key and keep relevant variables
  merged_df <- merged_df %>%
    dplyr::rowwise() %>%
    dplyr::mutate(merge_code = sum(statamergemaster,
                                   statamergeusing,
                                   na.rm = TRUE)) %>%
    dplyr::ungroup() %>%
    dplyr::select(!c(statamergemaster,statamergeusing))# drop intermediate statamergemaster statamergeusing vars

  # print results
  merged_df %>%
    dplyr::group_by(merge_code) %>%
    dplyr::summarize(n = dplyr::n()) %>%
    print()

  return(merged_df)
}

# define variables to be created
utils::globalVariables(c("statamergemaster",
                         "statamergeusing",
                         "merge_code",
                         "n",
                         "all_of",
                         "statamergemissing"))
