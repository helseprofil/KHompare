test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("View outliers", {

  dt <- readRDS(file.path(system.file("test-data", "view-DT-file.rds", package = "KHompare")))
  dtout <- readRDS(file.path(system.file("test-data", "view-dt.rds", package = "KHompare")))
  dd <- dtout[1:2]

  expect_equal(row_num(4), 1:4)
  expect_equal(view_outliers(dt, "MEIS", browser = FALSE), dtout)
  expect_equal(view_outliers(dt, "MEIS", 2, browser = FALSE), dd)
  expect_error(view_outliers(dt, "NOTHING", browser = FALSE))
  expect_error(view_outliers(dt, "MEIS", geo.levels = "T", browser = FALSE))
})
