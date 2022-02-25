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

  dt <- data.table::fread(kubeFile)
  dt <- add_geo_level(dt)

}

# HELPER -------------------
#' @keywords internal
#' @title Add Geo Level
#' @description Add geographical levels to the dataset. They are:
#'   - `L` for country (`Land`)
#'   - `F` for county (`Fylke`)
#'   - `k` for municipality (`Kommune`)
#'   - `B` for town (`Bydele`)
#' @import data.table
add_geo_level <- function(dt){
  GEO <- NULL
  dt[, "level" := data.table::fcase(nchar(GEO) %in% 1:2, "F",
                                    nchar(GEO) %in% 3:4, "k",
                                    nchar(GEO) %in% 5:6, "B")]
  dt[GEO == 0 , "level" := "L"]
  invisible(dt[])
}
