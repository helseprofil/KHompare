#' @title Get Directory
#' @description Get the directory where the files will be read from.
#' @param dir Select directory between `current` or `previous` year
#' @param os Operating system
#' @export
get_dir <- function(dir = c("current", "previous"), os = OS){
  status <- match.arg(dir)

  yr <- switch(dir,
               current = as.integer(getOption("kh.year")),
               previous = as.integer(getOption("kh.year")) - 1)
  fileDir <- paste0("KH", yr, "NESSTAR")
  drive <- os_drive(os = os)
  file.path(drive, getOption("kh.kube.root"), fileDir)
}
