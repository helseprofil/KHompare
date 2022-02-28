#' @title Check Raw File
#' @description Check raw kube files
#' @param file Raw `csv` file. Accept `KUBE` name if it's unique
#' @param ... Additional arguments
#' @examples
#' \dontrun{
#' dt <- check_cube("REGNFERD", dir = "current")
#' }
#' @export

check_cube <- function(file = NULL, ...){

  fileDir <- get_dir(...)
  allFiles <- fs::dir_ls(fileDir)
  kubeFile <- grep(file, allFiles, value = TRUE)

  if (length(kubeFile) > 1) {
    kbFiles <- unname(gsub(fileDir, "", kubeFile))
    for (i in kbFiles){
      fname <- sub("^/", "", i)
      message("Filename: ", fname)
    }
    stop("Found more than one files. Be specific!")
  }

  message("Processing: `", kubeFile, "`")
  dt <- data.table::fread(kubeFile)
  keyVars <- get_key(dt)
  data.table::setkeyv(dt, keyVars)
  dimVars <- get_grid(dt, vars = keyVars)
  dt <- add_pop_size(dt, ...)
  dt <- diff_change(dt, dim = dimVars, ...)
  sortKey <- keyVars[keyVars!="AAR"]
  data.table::setkeyv(dt, sortKey)
  dt[]
}

#' @export
#' @rdname check_cube
sjekk_kube <- check_cube


## HELPER -----------------
add_pop_size <- function(dt, dir = "current"){
  level <- NULL
  popFile <- pop_file_ref(dir = dir)
  fileExist <- fs::file_exists(path = popFile)

  if (isFALSE(fileExist)) {
    message("Creating population referece file ...")
    count_pop(dir = dir)
  }

  dd <- readRDS(popFile)
  dt[dd, on = "GEO", "level" := level]
  data.table::setcolorder(dt, c("GEO", "level"))
  dt[]
}
