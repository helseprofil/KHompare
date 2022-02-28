[![R build
status](https://github.com/helseprofil/KHompare/workflows/R-CMD-check/badge.svg)](https://github.com/helseprofil/KHompare/actions)
[![](https://codecov.io/gh/helseprofil/KHompare/branch/main/graph/badge.svg)](https://codecov.io/gh/helseprofil/KHompare)
[![](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![](https://img.shields.io/badge/devel%20version-0.0.0.9000-blue.svg)](https://github.com/helseprofil/KHompare)

# KHompare

Compare KHelse data to check for any abnormal changes.

# Installation

To install the package run

``` r
if(!requirenamespace("remotes")) install.packages("remotes")
remotes::install_github("helseprofil/KHompare")
```

# Usage

To check a cube file for *ALKOHOL* with `check_cube()` function. If
there are more than one file that starts with *ALKOHOL*, a more specific
name should be add.

``` r
library("KHompare")
dt <- check_cube("ALKOHOL")
```

Comparison will be made on the measurement variables created by
`LagKUBE()` function in **KHfunction** such as:

-   MEIS
-   RATE
-   TELLER
-   SMR
-   etc ..

New columns comparing the change of these measurement variables will be
created when running the function `check_cube()` and they are:

-   *xxx*\_NUM
-   *xxx*\_PCT

The *xxx* is the name of the measurement variables that are checked for
the difference in change numerically and percent. They are denoted by
\*\*\_NUM\*\* and \*\*\_PCT\*\* respectively.
