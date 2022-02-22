## Development loop ----
roxygen2::roxygenise(clean = TRUE)
devtools::load_all()
devtools::check()

## CREATE PKG -----------
available::available("KHompare")
devtools::session_info()
devtools::create("./dev/pkg/KHompare")

usethis::use_mit_license()
usethis::use_build_ignore("dev")
usethis::use_package_doc() #Pkg document roxygen style

## Add packages ----------
usethis::use_package("data.table", min_version = TRUE)
usethis::use_package("fs", min_version = TRUE)
