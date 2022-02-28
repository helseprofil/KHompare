    #> ✖ The 'origin' remote is configured, but we can't determine its default branch.
    #>   Possible reasons:
    #>   - The remote repo no longer exists, suggesting the local remote should
    #>     be deleted.
    #>   - We are offline or that specific Git server is down.
    #>   - You don't have the necessary permission or something is wrong with
    #>     your credentials.

[![R build
status](https://github.com/helseprofil/KHompare/workflows/R-CMD-check/badge.svg)](https://github.com/helseprofil/KHompare/actions)
[![](https://codecov.io/gh/helseprofil/KHompare/branch/main/graph/badge.svg)](https://codecov.io/gh/helseprofil/KHompare)
[![](https://img.shields.io/badge/lifecycle-experimental-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![](https://img.shields.io/badge/devel%20version-0.0.0.9000-blue.svg)](https://github.com/helseprofil/KHompare)

# KHompare

Compare KHelse data to check for any abnormal changes.

# Installation

To install the package run

``` r
if(!requirenamespace("remotes")) install.packages("remotes")
remotes::install_github("helseprofil/orgdata")
```

# Usage

To check a cube file for *ALKOHOL*

``` r
library("KHompare")
dt <- check_cube("ALKOHOL")
```

Comparison will be made on the measurements created by `LagKUBE()`
function in **KHfunction** such as:

-   MEIS
-   RATE
-   TELLER
-   SMR
-   etc ..

New columns of these measurement variables will be created when running
the function `check_cube()` and they are:

-   *xxx*\_NUM
-   *xxx*\_PCT

The *xxx* is the name of the measurement variables that are checked for
the difference in change numerically and percent. They are denoted by
*NUM* and *PCT* respectively.
