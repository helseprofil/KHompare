#' @title Check Outliers Raw File
#' @description Check outliers in raw kube files
#' @param name Filename of KUBE raw `csv` file.
#' @inheritParams get_dir
#' @param km Logical value. To include or exclude small municipalities. Default
#'   is to exclude them ie. `km = FALSE`
#' @param ... Additional arguments
#' @examples
#' \dontrun{
#' dt <- check_outliers("TRIVSEL", year = 2022)
#' }
#' @export
check_outliers <- function(name = NULL,
                           year = NULL,
                           type = c("KH", "NH"),
                           km = FALSE, ...){

  level <- NULL
  fileDir <- get_dir(year = year, type = type, ...)
  allFiles <- fs::dir_ls(fileDir)
  nameFirst <- paste0("/", name) #make sure it's the first word
  kubeFiles <- grep(nameFirst, allFiles, value = TRUE)

  if (length(kubeFiles) < 1) {
    message("Folder: ", fileDir)
    stop("File not found!")
  }

  # select the most recent files
  fileKUBE <- find_filename(dir=fileDir, files=kubeFiles)

  message("Processing: `", fileKUBE, "`")
  dt <- data.table::fread(fileKUBE)

  keyVars <- get_key(dt)
  .env_key[["keys"]] <- keyVars

  data.table::setkeyv(dt, keyVars)
  dimVars <- get_grid(dt, vars = keyVars)
  dt <- add_pop_size(dt, year = year, type = type)

  # Default is to exclude smal municiplities
  if (!km){
    dt <- dt[level != "km"]
  }

  message("Star finding outliers ... ")
  dt <- diff_change(dt, dim = dimVars, ...)
  sortKey <- keyVars[keyVars!="AAR"]
  data.table::setkeyv(dt, sortKey)

  cat("\n")
  if (requireNamespace("orgdata", quietly = TRUE)){
    orgdata:::is_color_txt(x = "",
                           msg = "Done!",
                           type = "note", emoji = TRUE)
  } else {
    message("Done!")
  }

  dt[]
}

#' @export
#' @rdname check_outliers
sjekk_outlier <- check_outliers

#' @export
#' @rdname check_outliers
co <- check_outliers

#' @title Check Outliers Raw File
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Make funcion name standardize
#' @examples
#' \dontrun{
#' check_cube("TRIVSEL")
#' # ->
#' check_outliers("TRIVSEL")
#' }
#' @keywords internal
#' @export
check_cube <- function(name = NULL,
                       year = NULL,
                       type = c("KH", "NH"),
                       km = FALSE, ...){
  lifecycle::deprecate_warn("0.3.6", "check_cube()", "check_outliers()")

  check_outliers(name, year, type, km, ...)
}

#' @export
#' @rdname check_cube
sjekk_kube <- check_cube

#' @export
#' @rdname check_cube
cc <- check_cube


#' @title Check File
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `check_file()` was renamed to `check_cube()` to be more explicit
#' @keywords internal
#' @export
check_file <- function(name = NULL, year = NULL, type = c("KH", "NH"), ...){
  lifecycle::deprecate_warn("0.0.1", "check_file()", "check_outliers()")
}


## HELPER -----------------
add_pop_size <- function(dt, year = NULL, type = NULL){
  level <- NULL
  popFile <- pop_file_ref(year = year)
  fileExist <- fs::file_exists(path = popFile)

  # Delete empty file if exist
  if (fileExist){
    pp <- readRDS(popFile)
    if (nrow(pp) == 0) fs::file_delete(popFile)
  }

  if (isFALSE(fileExist)) {
    create_pop_ref(year = year)
  }

  fileExist <- fs::file_exists(path = popFile)
  if (isFALSE(fileExist)) {
    message("Use population file for ", year - 1, " to find small and big municipalities")
    popFile <- pop_file_ref(year = year - 1)
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
    msg <- paste0("Filename is not unique after deleting date suffix. Be specific! eg.`", filenames[1],"_", getOption("kh.year"), "`")
    stop(msg)
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
