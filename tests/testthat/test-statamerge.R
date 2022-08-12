test_that("1:1 works", {
  merge1 <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf"),
                       type = c("band", "band", "band", "singer"),
                       genre = c("folk", "twee", "indie", "funk"))
  merge2 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc"),
                       band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco"),
                       type = c("banger", "jam", "banger", "jam"))
  df <- statamerge(merge1, merge2, mergetype = "1:1", merge_vars = "band")
  correct_df <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf", "Wilco"),
                           genre = c("folk", "twee", "indie", "funk", NA),
                           song = c(NA, "Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc"),
                           type = c("band", "band", "band", "singer", "jam"),
                           merge_code = c(1,3,3,3,2))
  expect_equal(df,correct_df)
})

test_that("m:1 works", {
  merge1 <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf"),
                       type = c("band", "band", "band", "singer"),
                       genre = c("folk", "twee", "indie", "funk"))
  merge2 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc", "The Underdog"),
                       band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco", "Spoon"),
                       type = c("banger", "jam", "banger", "jam", "banger"))
  df <- statamerge(merge2, merge1, mergetype = "m:1", merge_vars = "band")
  correct_df <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc", "The Underdog", "NA"),
                           band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco", "Spoon", "Big Thief"),
                           genre = c("twee", "indie", "funk", NA, "indie", "folk"),
                           type = c("banger", "jam", "banger", "jam", "banger", "band"),
                           merge_code = c(3,3,3,1,3,2))
  expect_equal(df,correct_df)
  expect_error
})

test_that("1:m works", {
  merge1 <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf"),
                       type = c("band", "band", "band", "singer"),
                       genre = c("folk", "twee", "indie", "funk"))
  merge2 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc", "The Underdog"),
                       band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco", "Spoon"),
                       type = c("banger", "jam", "banger", "jam", "banger"))
  df <- statamerge(merge1, merge2, mergetype = "1:m", merge_vars = "band")
  correct_df <- dplyr::tibble(band = c("Big Thief","Los Campesinos!","Spoon","Spoon","Remi Wolf","Wilco"),
                           genre = c("folk", "twee", "indie", "indie", "funk", NA),
                           song = c(NA, "Songs About Your Girlfriend", "Do You", "The Underdog","Michael", "Jesus Etc"),
                           type = c("band","band","band","band", "singer","jam"),
                           merge_code = c(1,3,3,3,3,2))
  expect_equal(df,correct_df)
})

test_that("Uniqueness of master check works", {
  merge1 <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf"),
                          type = c("band", "band", "band", "singer"),
                          genre = c("folk", "twee", "indie", "funk"))
  merge2 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc", "The Underdog"),
                          band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco", "Spoon"),
                          type = c("banger", "jam", "banger", "jam", "banger"))
  expect_error(statamerge(merge2, merge1, mergetype = "1:1", merge_vars = "band"),
               "Master is not unique on merge variables")
  expect_error(statamerge(merge2, merge1, mergetype = "1:m", merge_vars = "band"),
               "Master is not unique on merge variables")
})

test_that("Uniqueness of using check works", {
  merge1 <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf"),
                          type = c("band", "band", "band", "singer"),
                          genre = c("folk", "twee", "indie", "funk"))
  merge2 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc", "The Underdog"),
                          band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco", "Spoon"),
                          type = c("banger", "jam", "banger", "jam", "banger"))
  expect_error(statamerge(merge1, merge2, mergetype = "1:1", merge_vars = "band"),
               "Using is not unique on merge variables")
  expect_error(statamerge(merge1, merge2, mergetype = "m:1", merge_vars = "band"),
               "Using is not unique on merge variables")
})




