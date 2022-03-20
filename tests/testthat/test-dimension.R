test_that("Key variables", {
  dt <- readRDS(system.file("test-data", "key-dt.rds", package = "KHompare"))
  output <- c("GEO","AAR", "KJONN", "ALDER", "ANTALL_GANGER", "SOES")

  expect_equal(get_key(dt), output)
})

test_that("Dimension variables", {
  dt <- readRDS(system.file("test-data", "key-dt.rds", package = "KHompare"))
  keyVars <- c("GEO","AAR", "KJONN", "ALDER", "ANTALL_GANGER", "SOES")
  dtout <- readRDS(system.file("test-data", "grid-out.rds", package = "KHompare"))

  expect_equal(get_grid(dt, keyVars), dtout)
})

test_that("Compare cube measure", {
  dt <- readRDS(system.file("test-data", "dim-change-dt.rds", package = "KHompare"))
  dim <- readRDS(system.file("test-data", "dim-dt.rds", package = "KHompare"))
  dtout <- readRDS(system.file("test-data", "dim-change-out.rds", package = "KHompare"))

  diffout <- readRDS(system.file("test-data", "diff-change-out.rds", package = "KHompare"))

  expect_equal(find_change(dt = dt, dim = dim, var = "MEIS"), dtout)

  dt[, khompareID := NULL]
  expect_equal(diff_change(dt = dt, dim = dim), diffout)

})
