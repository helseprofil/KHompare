#' @title Read Raw File
#' @description Read raw kube files
#' @param file Raw `csv` file. Accept `KUBE` name if it's unique
#' @param ... Additional arguments
#' @examples
#' \dontrun{
#' dt <- read_file("REGNFERD", dir = "current")
#' }
#' @export

read_file <- function(file = NULL, ...){

  fileDir <- get_dir(...)
  allFiles <- fs::dir_ls(fileDir)
  kubeFile <- grep(file, allFiles, value = TRUE)

  if (length(kubeFile) > 1) stop("Found more than one files. Be specific!")

  data.table::fread(kubeFile)

}
