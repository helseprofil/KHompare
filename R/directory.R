#' @title Get Directory
#' @description Get the directory where the files will be read from.
#' @param year Which year of the `KHxxxxNESSTAR` folder to select where `xxxx`
#'   is the selected year. Default is NULL to select the current year as in
#'   options `kh.year`.
#' @param os Operating system
#' @export
get_dir <- function(year = NULL, os = OS){

  if (is.null(year)) year = as.integer(getOption("kh.year"))

  fileDir <- paste0("KH", year, "NESSTAR")
  drive <- os_drive(os = os)
  file.path(drive, getOption("kh.kube.root"), fileDir)
}
