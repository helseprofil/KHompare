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
