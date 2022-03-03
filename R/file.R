#' @title Check Raw File
#' @description Check raw kube files
#' @param name Filename of KUBE raw `csv` file.
#' @inheritParams get_dir
#' @param ... Additional arguments
#' @examples
#' \dontrun{
#' dt <- check_cube("REGNFERD", year = 2022)
#' }
#' @export
check_cube <- function(name = NULL, year = NULL, type = c("KH", "NH"), ...){

  fileDir <- get_dir(year = year, type = type, ...)
  allFiles <- fs::dir_ls(fileDir)
  kubeFiles <- grep(name, allFiles, value = TRUE)

  if (length(kubeFiles) < 1) {
    message("Folder: ", fileDir)
    stop("File not found!")
  }

  # select the most recent files
  fileKUBE <- find_filename(dir=fileDir, files=kubeFiles)

  message("Processing: `", fileKUBE, "`")
  dt <- data.table::fread(fileKUBE)
  keyVars <- get_key(dt)
  data.table::setkeyv(dt, keyVars)
  dimVars <- get_grid(dt, vars = keyVars)
  dt <- add_pop_size(dt, year = year)
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
    create_pop_ref(year = year)
  }

  dd <- readRDS(popFile)
  dt[dd, on = "GEO", "level" := level]
  data.table::setcolorder(dt, c("GEO", "level"))
  dt[]
}

## Select the most recent files
find_filename <- function(dir, files){

  # Keep filenames only
  files <- cube_filename(dir = dir, file = files)

  filenames <- gsub("_(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2})", "", files)
  filenames <- gsub(".csv$", "", filenames)
  filenames <- unique(filenames)

  if (length(filenames) > 1){
    for(i in filenames){ message("Filename: ", i)}
    stop("Found more than one unique filenames after deleting date suffix. Be specific!")
  }

  # Ensure only the most recent file is selected when there are multiple files due to different dates
  yrDate <- gsub(".*(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2}).csv$", "\\1\\2\\3\\4\\5", files)
  yrFile <- sort(as.numeric(yrDate), TRUE)[1] #keep only the most recent file
  fileExt <- gsub("^(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})", "\\1-\\2-\\3-\\4-\\5", yrFile)
  fileNM <- paste0(filenames, "_", fileExt, ".csv")
  file.path(dir, fileNM)
}

cube_filename <- function(dir, file){
  x <- unname(gsub(dir, "", file))
  sub("^/", "", x)
}
