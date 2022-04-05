#' @title Create Population Reference
#' @description Create a dataset separating big and small municipalities based
#'   on their number of population. The cutoff is 10,000 population. Capital
#'   letter `K` denotes big municipalities while `km` for small
#'   municipalities. The created file will be called
#'   `BigSmall-Kommuner-REF-xxxx.rds` where `xxxx` represent the selected year.
#' @description The categories for geographical levels are:
#'   - `L` for country (`Land`)
#'   - `F` for counties (`Fylker`)
#'   - `K` for bigger municipalities (`Kommuner`)
#'   - `km` for smaller municipalities (`Kommuner`)
#'   - `B` for towns (`Bydeler`)
#' @param name Population filename with standard name starts with `BEFOLK_GK`
#' @inheritParams get_dir
#' @param overwrite Overwrite existing `BigSmall-Kommuner-REF-xxxx.rds` file
#' @inheritParams check_cube
#' @export
create_pop_ref <- function(name = NULL,
                           year = NULL,
                           type = c("KH", "NH"),
                           overwrite = FALSE){
  GEO <- NULL

  if (length(type) > 1) type = "KH"
  if (is.null(name)){
    name <- switch(type,
                   KH = "BEFOLK_GK",
                   NH = "BEFOLK_GK_NH")
  }

  if (is.null(year)) year = getOption("kh.year")
  fileDir <- get_dir(year = year, type = type)
  befolkDT <- pop_file_ref(year = year)
  fileExist <- fs::file_exists(path = befolkDT)

  if (isFALSE(overwrite) && isTRUE(fileExist)){
    message("File exists: ", befolkDT)
    message("Use argument `overwrite = TRUE` to create a new file")
    return()
  }

  allFiles <- fs::dir_ls(fileDir)

  bf <- paste0(name, "_\\d{4}") #file must be followed by year ie. 4 digits
  befolkFiles <- grep(bf, allFiles, value = TRUE)

  if (length(befolkFiles) != 0) {
    dt <- pop_file(dir = fileDir, files = befolkFiles)
    dt[, c("AAR", "KJONN", "ALDER") := NULL]
    dt <- dt[!duplicated(GEO)]

    saveRDS(object = dt, file = befolkDT)
    message("Save file: ", befolkDT)
  } else {
    message("Population reference file ", year, " not found!")
    dt <- 0
  }

  invisible(dt)
}

# HELPER -------------------
# Categorise municipalities with big and small municipalities
# dir - Directory where the population file is
# files - All files with the same name but different date
pop_file <- function(dir = NULL, files = NULL){
  ALDER <- KJONN <- TELLER <- level <- NULL

  pathBEF <- find_filename(dir = dir, files = files)
  dt <- data.table::fread(pathBEF)

  # Select only total to find bigger and small kommuner
  dt <- dt[KJONN == 0 & ALDER == "0_120"]
  dt <- add_geo_level(dt)

  # Big and small kommuner with cutoff 10000
  # Big kommune with capital K
  dt[level == "K", level := fifelse(TELLER >= 10000, "K", "km")]
  varKube <- c(getOption("kh.kube.vars"), "SPVFLAGG")
  varDel <- intersect(names(dt), varKube)
  dt[, (varDel) := NULL]
}

#' @keywords internal
#' @title Add Geo Level
#' @description Add geographical levels to the dataset. They are:
#'   - `L` for country (`Land`)
#'   - `F` for county (`Fylke`)
#'   - `K` for bigger municipality (`Kommune`) ie. population > 10,000
#'   - `km` for smaller municipality (`Kommune`) ie. population < 10,000
#'   - `B` for town (`Bydele`)
#' @import data.table
add_geo_level <- function(dt){
  GEO <- NULL
  dt[, "level" := data.table::fcase(nchar(GEO) %in% 1:2, "F",
                                    nchar(GEO) %in% 3:4, "K",
                                    nchar(GEO) %in% 5:6, "B")]
  dt[GEO == 0 , "level" := "L"]
  invisible(dt[])
}

# File for reference to big and small municipalities based on number of population
pop_file_ref <- function(name = "BigSmall-Kommuner-REF-", year = NULL){
  if (is.null(year)) year = as.integer(getOption("kh.year"))
  fileDir <- get_dir_ref(year)
  fileName <- paste0(name, year, ".rds")
  file.path(fileDir, fileName)
}
