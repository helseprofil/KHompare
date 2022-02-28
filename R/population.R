#' @title Count Municipalities Population
#' @description Create a dataset separating big and small municipalities based
#'   on their number of population. The cutoff is 10,000 population. Capital
#'   letter `K` denotes big municipalities while small letter `k` for small
#'   municipalities. The created file will be called `BEF-Kommune-xxxx` where
#'   `xxxx` represent the selected year.
#' @param name Population filename with standard name starts with `BEFOLK_GK`
#' @inheritParams get_dir
#' @param year Year for selection of population. Default is using global options
#'   `kh.year`
#' @param overwrite Overwrite existing `BEF-Kommune-xxxx.rds` file
#' @export
count_pop <- function(name = "BEFOLK_GK", dir = "current", year = getOption("kh.year"), overwrite = FALSE){
  GEO <- NULL
  fileDir <- get_dir(dir)
  befolkDT <- pop_file_ref()
  fileExist <- fs::file_exists(path = befolkDT)

  if (isFALSE(overwrite) && isTRUE(fileExist)){
    message("File exists: ", befolkDT)
    message("Use argument `overwrite = TRUE` to create a new file")
    return()
  }

  allFiles <- fs::dir_ls(fileDir)

  bf <- paste0(name, "_\\d{4}") #file must be followed by year ie. 4 digits
  befolkFiles <- grep(bf, allFiles, value = TRUE)
  dt <- pop_file(dir = fileDir, files = befolkFiles, name = name)
  dt[, c("AAR", "KJONN", "ALDER") := NULL]
  dt <- dt[!duplicated(GEO)]

  saveRDS(object = dt, file = befolkDT)
  message("Save file: ", befolkDT)
  invisible(dt)
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

# dir - Directory where the population file is
# files - All files with the same name but different date
# name - Filename ie. BEFOLK_GK
pop_file <- function(dir = NULL, files = NULL, name = NULL){
  ALDER <- KJONN <- TELLER <- level <- NULL

  # Ensure only the most recent file is selected when there are multiple files
  yrDate <- gsub(".*(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2}).csv$", "\\1\\2\\3\\4\\5", files)
  yrFile <- sort(as.numeric(yrDate), TRUE)[1] #keep only the most recent file
  fileExt <- gsub("^(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})", "\\1-\\2-\\3-\\4-\\5", yrFile)
  fileBEF <- paste0(name, "_", fileExt, ".csv")
  pathBEF <- file.path(dir, fileBEF)
  dt <- data.table::fread(pathBEF)

  # Select only total to find bigger and small kommuner
  dt <- dt[KJONN == 0 & ALDER == "0_120"]
  dt <- add_geo_level(dt)

  # Big and small kommuner with cutoff 10000
  # Big kommune with capital K
  dt[level == "k", level := fifelse(TELLER >= 10000, "K", "k")]
  varKube <- c(getOption("kh.kube.vars"), "SPVFLAGG")
  varDel <- intersect(names(dt), varKube)
  dt[, (varDel) := NULL]
}

# File for reference to big and small municipalities based on number of population
pop_file_ref <- function(name = "BEF-Kommune-", dir = "current", year = getOption("kh.year")){
  fileDir <- get_dir(dir)
  file.path(fileDir, paste0(name, year, ".rds") )
}
