
test_that("Get directory", {
  dirLinux <- "/mnt/F/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR"
  dirLinux2 <- "/mnt/F/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2021NESSTAR"

  withr::with_options(list(kh.year = 2022),
                      expect_equal(get_dir("current", "Linux"), dirLinux))

  withr::with_options(list(kh.year = 2022),
                      expect_equal(get_dir("previous", "Linux"), dirLinux2))
})
