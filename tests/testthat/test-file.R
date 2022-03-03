test_that("Add geo levels", {
  dt <- readRDS(system.file("test-data", "geo-levels-raw.rds", package = "KHompare"))
  dtout <- readRDS(system.file("test-data", "geo-levels-out.rds", package = "KHompare"))
  expect_equal(add_geo_level(dt), dtout)
})

test_that("Select files", {
  ddir <- "C:/Test/Dir"
  dfil <- paste0(ddir, c("/File_2022-01-01-18-17.csv", "/File_2022-01-02-20-01.csv"))
  dfilErr <- paste0(ddir, c("/File01_2022-01-01-18-17.csv", "/File02_2022-01-02-20-01.csv"))

  expect_equal(cube_filename(dir = ddir, file = file.path(ddir, "Test-file.csv")), "Test-file.csv")
  expect_equal(find_filename(dir = ddir, files = dfil), "C:/Test/Dir/File_2022-01-02-20-01.csv")
  expect_error(find_filename(dir = ddir, files = dfilErr))
})
