## Development loop ----
devtools::load_all()
devtools::test()

roxygen2::roxygenise(clean = TRUE)
devtools::check()


## CREATE PKG -----------
available::available("KHompare")
devtools::session_info()
devtools::create("./dev/pkg/KHompare")

usethis::use_mit_license()
usethis::use_package_doc() #Pkg document roxygen style

## Ignore -------------
usethis::use_build_ignore("dev")
usethis::use_build_ignore("README.Rmd")


## Add packages ----------
usethis::use_package("covr", type = "Suggest")
usethis::use_package("data.table", min_version = TRUE)
usethis::use_package("fs", min_version = TRUE)
usethis::use_package("yaml", min_version = TRUE)
usethis::use_package("withr", min_version = TRUE)
usethis::use_package("stats")
usethis::use_package("listenv", min_version = TRUE)
usethis::use_package("lifecycle", min_version = TRUE)


## Testing ---------------
usethis::use_testthat()
usethis::use_test("utils")
usethis::use_test("directory")
usethis::use_test("file")
usethis::use_test("dimension")
usethis::use_test("view")

## CI ----------------
usethis::use_git_remote("origin", url = "https://github.com/helseprofil/KHompare.git", overwrite = T)
usethis::use_github_action_check_standard()
usethis::use_git_remote("origin", url = "git@work:helseprofil/KHompare.git", overwrite = TRUE)

usethis::use_coverage()
usethis::use_github_action("test-coverage")

## Save ---------------
saveRDS(b2, file = file.path(system.file(package = "KHompare"), "test-data/geo-levels-out.rds"))


## RUN -----------
devtools::load_all()
pop <- create_pop_ref(overwrite = T, type = "NH")

check_file("LESEFERD")

dt <- check_cube("LESEFERD")
dt <- check_cube("ALKOHOL")
dt <- check_cube("ALKOHOL", year = 2021)
dt <- check_cube("INNVAND_2")

dt <- sjekk_kube("TEST77")
dt <- sjekk_kube("BigSmall")
dt <- sjekk_kube("INNVAND", type = "NH")

view_outliers(dt, "MEIS", nrow = 2:5)
view_outliers(dt, "RATE")
