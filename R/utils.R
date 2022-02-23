# add prefix "kh" to options
opt_rename <- function(x){
  x2 <- paste("kh", names(x), sep = ".")
  x <- setNames(x, x2)
}
