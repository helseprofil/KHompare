
test_that("Get directory", {
  dirLinux <- "/mnt/F/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR"
  dirWin <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2021NESSTAR"

  withr::with_options(list(kh.year = 2022),
                      expect_equal(get_dir(os="Linux"), dirLinux))

  withr::with_options(list(kh.year = 2022),
                      expect_equal(get_dir(year = 2021, os="Windows"), dirWin))
})
