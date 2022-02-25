# Driver on different OS
os_drive <- function(os = OS){
  switch(os,
         Linux = getOption("kh.linux.drive"),
         Windows = getOption("kh.win.drive"))
}

# add prefix "kh" to options
opt_rename <- function(x){
  x2 <- paste("kh", names(x), sep = ".")
  x <- stats::setNames(x, x2)
}
