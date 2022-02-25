test_that("Add geo levels", {
  dt <- readRDS(system.file("test-data", "geo-levels-raw.rds", package = "KHompare"))
  dtout <- readRDS(system.file("test-data", "geo-levels-out.rds", package = "KHompare"))
  expect_equal(add_geo_level(dt), dtout)
})
