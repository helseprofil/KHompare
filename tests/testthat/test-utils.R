test_that("Config options", {

  op1 <- list(var1 = "F:", var2 = TRUE)
  op2 <- list(kh.var1 = "F:", kh.var2 = TRUE)

  expect_equal(opt_rename(op1), op2)
})
