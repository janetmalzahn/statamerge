
<!-- README.md is generated from README.Rmd. Please edit that file -->

# statamerge

<!-- badges: start -->
<!-- badges: end -->

statamerge is a dplyr wrapper designed to add the functionality from
statamerges to dplyr merges. Specifically, it checks for uniqueness,
adds a source “merge code” to show whether an observation was matched or
not, and coalesces variables from the master and using with the same
name (keeping master if there is a conflict).

## Installation

You can install the development version of statamerge from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("janetmalzahn/statamerge")
```

## Why use statamerge?

Statamerge is particularly useful for those learning R with a background
in Stata. However, Stata’s merges have plenty of useful features for
those frequently working with merged datasets: 1. `statamerge` checks
for uniqueness to ensure the dataset matches expectations. A 1:1 merge
checks for uniqueness in each dataset to ensure that each observation in
the master can will only be matched to a (maximum) of one observation in
using. A 1:m or m:1 checks for uniqueness in either the master (m:1) or
the using (1:m) datasets. This ensures that the merged dataset will have
no more observations than the non-unique dataset. 2. `statamerge`
includes a code for whether an observation was matched, unmatched from
the master dataset, or unmatched from the using. With current dplyr
merges, there is no simple way to distinguish items that were matched
from items that were not, or which dataset unamtched observations came
from. `statamerge` outputs a dataset with a merge code that is 1 if the
observation was unmatched from the master, 2 if the observation was
unmatched from using, or 3 if the observation was merged.

## Example

statamerge uses language from stata to refer to datasets. The first
dataset input to statamerge is the “master” dataset and the second is
the “using” dataset.

``` r
library(statamerge)
# make datasets
merge1 <- dplyr::tibble(band = c("Big Thief", "Los Campesinos!", "Spoon", "Remi Wolf"),
                       type = c("band", "band", "band", "singer"),
                       genre = c("folk", "twee", "indie", "funk"))
merge2 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc"), band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco"), type = c("banger", "jam", "banger", "jam"))

merge3 <- dplyr::tibble(song = c("Songs About Your Girlfriend", "Do You", "Michael", "Jesus Etc", "The Underdog"),
                       band = c("Los Campesinos!", "Spoon", "Remi Wolf", "Wilco", "Spoon"),
                       type = c("banger", "jam", "banger", "jam", "banger"))

# one to one merge
statamerge(merge1, merge2, mergetype = "1:1", merge_vars = "band")
#> [1] "Performing 1:1 merge"
#> # A tibble: 3 × 2
#>   merge_code     n
#>        <dbl> <int>
#> 1          1     1
#> 2          2     1
#> 3          3     3
#> # A tibble: 5 × 5
#>   band            genre song                        type   merge_code
#>   <chr>           <chr> <chr>                       <chr>       <dbl>
#> 1 Big Thief       folk  <NA>                        band            1
#> 2 Los Campesinos! twee  Songs About Your Girlfriend band            3
#> 3 Spoon           indie Do You                      band            3
#> 4 Remi Wolf       funk  Michael                     singer          3
#> 5 Wilco           <NA>  Jesus Etc                   jam             2
```

``` r
# stata merge 1:m
statamerge(merge1, merge3, mergetype = "1:m", merge_vars = "band")
#> [1] "Performing 1:m merge"
#> # A tibble: 3 × 2
#>   merge_code     n
#>        <dbl> <int>
#> 1          1     1
#> 2          2     1
#> 3          3     4
#> # A tibble: 6 × 5
#>   band            genre song                        type   merge_code
#>   <chr>           <chr> <chr>                       <chr>       <dbl>
#> 1 Big Thief       folk  <NA>                        band            1
#> 2 Los Campesinos! twee  Songs About Your Girlfriend band            3
#> 3 Spoon           indie Do You                      band            3
#> 4 Spoon           indie The Underdog                band            3
#> 5 Remi Wolf       funk  Michael                     singer          3
#> 6 Wilco           <NA>  Jesus Etc                   jam             2
```

``` r
# stata merge 1:m
statamerge(merge3, merge1, mergetype = "m:1", merge_vars = "band")
#> [1] "Performing m:1 merge"
#> # A tibble: 3 × 2
#>   merge_code     n
#>        <dbl> <int>
#> 1          1     1
#> 2          2     1
#> 3          3     4
#> # A tibble: 6 × 5
#>   song                        band            genre type   merge_code
#>   <chr>                       <chr>           <chr> <chr>       <dbl>
#> 1 Songs About Your Girlfriend Los Campesinos! twee  banger          3
#> 2 Do You                      Spoon           indie jam             3
#> 3 Michael                     Remi Wolf       funk  banger          3
#> 4 Jesus Etc                   Wilco           <NA>  jam             1
#> 5 The Underdog                Spoon           indie banger          3
#> 6 <NA>                        Big Thief       folk  band            2
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
