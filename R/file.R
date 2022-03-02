#' @title Check Raw File
#' @description Check raw kube files
#' @param file Raw `csv` file. Accept `KUBE` name if it's unique
#' @inheritParams get_dir
#' @param ... Additional arguments
#' @examples
#' \dontrun{
#' dt <- check_cube("REGNFERD", year = 2022)
#' }
#' @export
check_cube <- function(file = NULL, year = NULL, ...){

  fileDir <- get_dir(year = year, ...)
  allFiles <- fs::dir_ls(fileDir)
  kubeFile <- grep(file, allFiles, value = TRUE)

  if (length(kubeFile) < 1) {
    message("Folder: ", fileDir)
    stop("File not found!")
  }

  if (length(kubeFile) > 1) {
    for (i in kubeFile){
      fname <- cube_file(fileDir, i)
      message("Filename: ", fname)
    }
    stop("Found more than one files. Be specific!")
  }

  message("Processing: `", kubeFile, "`")
  dt <- data.table::fread(kubeFile)
  keyVars <- get_key(dt)
  data.table::setkeyv(dt, keyVars)
  dimVars <- get_grid(dt, vars = keyVars)
  dt <- add_pop_size(dt, year = year, ...)
  dt <- diff_change(dt, dim = dimVars, ...)
  sortKey <- keyVars[keyVars!="AAR"]
  data.table::setkeyv(dt, sortKey)
  dt[]
}

#' @export
#' @rdname check_cube
sjekk_kube <- check_cube


## HELPER -----------------
add_pop_size <- function(dt, year = NULL){
  level <- NULL
  popFile <- pop_file_ref(year = year)
  fileExist <- fs::file_exists(path = popFile)

  if (isFALSE(fileExist)) {
    message("Creating population reference file ...")
    count_pop(year = year)
  }

  dd <- readRDS(popFile)
  dt[dd, on = "GEO", "level" := level]
  data.table::setcolorder(dt, c("GEO", "level"))
  dt[]
}

cube_file <- function(dir, file){
  x <- unname(sub(dir, "", file))
  sub("^/", "", x)
}
