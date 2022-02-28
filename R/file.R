#' @title Read Raw File
#' @description Read raw kube files
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

  dt <- data.table::fread(kubeFile)
  keyVars <- get_key(dt)
  data.table::setkeyv(dt, keyVars)
  dimVars <- get_grid(dt, vars = keyVars)
  DT <- diff_change(dt, dim = dimVars)
  sortKey <- keyVars[keyVars!="AAR"]
  data.table::setkeyv(DT, sortKey)
  DT[]
}

#' @export
#' @rdname check_cube
sjekk_kube <- check_cube


