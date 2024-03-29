#' @title Get Directory
#' @description Get the directory where the files will be read from.
#' @param year Which year of the `KHxxxxNESSTAR` folder to select where `xxxx`
#'   is the selected year. Default is NULL to select the current year as in
#'   options `kh.year`.
#' @param type Type of folder of either `KH` or `NH`. Default is `KH`.
#' @param os Operating system
#' @export
get_dir <- function(year = NULL, type = c("KH", "NH"), os = OS){

  if (is.null(year)) year = as.integer(getOption("kh.year"))

  type <- match.arg(type)
  if (length(type) > 1) type = "KH"

  dirTYP <- switch(type,
                   KH = "KOMMUNEHELSA/KH",
                   NH = "NORGESHELSA/NH")

  fileDir <- paste0(dirTYP, year, "NESSTAR")
  drive <- os_drive(os = os)
  file.path(drive, getOption("kh.kube.root"), fileDir)
}

#' @title Get Reference Directory
#' @description Get the directory where reference files will be kept. These
#'   files include population reference files and database files.
#' @param year Which year to refer to. Default is option \code{kh.year}
#' @inheritParams get_dir
#' @export
get_dir_ref <- function(year = NULL, os = OS){
  # type - Type of files
  drive <- os_drive(os = os)
  if (is.null(year)) year = as.integer(getOption("kh.year"))

  khDir <- file.path(drive, getOption("kh.khompare.root"), year)
  if(!fs::dir_exists(khDir)){
    fs::dir_create(khDir)
  }

  invisible(khDir)
}
