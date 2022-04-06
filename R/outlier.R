#' @title View Outliers
#' @description View outliers for selected variables
#' @param dt Dataset object from `check_cube()` function
#' @param var Measure variables eg. RATE, MEIS etc
#' @param nrows Number of rows or select rows to show eg. `nrows = 10` or `nrows = 5:15`
#' @param geo.levels Level of geographical granularity as in `getOption("kh.geo.levels")`
#' @param browser Logical value. Show table in browser or not
#' @examples
#' \dontrun{
#'  dt <- check_cube("ALKOHOL")
#'  view_outliers(dt, "RATE")
#' }
#' @export
view_outliers <- function(dt = NULL,
                          var = NULL,
                          nrows = NULL,
                          geo.levels = NULL,
                          browser = TRUE){

  level <- NULL

  levelVals <- getOption("kh.geo.levels")
  if (is.null(geo.levels)) {
    geo.levels <- levelVals
  }

  if (isFALSE(any(geo.levels %in% levelVals))){
    stop("geo.Levels `arg` accepts only ", paste(levelVals, collapse = ", "))
  }

  vvars <- grep("_NUM", names(dt), value = TRUE)
  pvars <- grep("_PCT", names(dt), value = TRUE)

  var <- trimws(var)
  if (isFALSE(any(var %in% names(dt)))){
    msrVars <- pvars[-grep("_OUT", pvars)]
    msrVars <- gsub("_PCT", " ", msrVars)
    stop("Columname not found! Valid columnames: ", msrVars)
  }

  # standard columns
  allCols <- setdiff(names(dt), c(vvars, pvars))
  dimCols <- get_key_plot(dt, plot = TRUE)
  demoCols <- intersect(c(getOption("kh.demo.vars"), "level", dimCols), allCols)
  stdCols <- c(demoCols, var)

  # cube and outliers columns
  selCols <- paste0(var, c("_PCT", "_NUM"))
  outCols <- paste0(var, c("_PCT_OUT","_NUM_OUT"))
  cubeCols <- c(grep("PCT", c(selCols, outCols), value = T),
                grep("NUM", c(selCols, outCols), value = T))

  # reorder table columns
  geoCols <- c("GEO", "level")
  normCols <- setdiff(stdCols, geoCols)
  scols <- c(geoCols, normCols, cubeCols)

  dd <- dt[!is.na(get(outCols[1])) | !is.na(get(outCols[2])), mget(scols)][level %chin% geo.levels]

  if (!is.null(nrows)){
    nrows <- row_num(nrows)
    dd <- dd[nrows]
  }

  if (browser){
    use_browser(dd, grp = selCols)
  } else {
    dd[]
  }

}

#' @export
#' @rdname view_outliers
vis_uteligger <- view_outliers

#' @export
#' @rdname view_outliers
vo <- view_outliers


#' @title Find Outlier
#' @description Find outlier values which indicate change in the measured
#'   variables is abnormal. This is based on the value in `xxx_NUM` and
#'   `xxx_PCT` ie. numeric and percent change. New variables with `xxx_NUM_OUT`
#'   and `xxx_PCT_OUT` with value either: - NA not an outlier - 1 lower value
#'   outlier - 2 upper value outlier
#' @param dt Dataset
#' @param var Selected measured variables eg. MEIS, RATE etc
#' @param ... Additional agruments ie. coef = 1.5 (bound for outlier). Can accept
#'   all arguments for `boxplot.stats()`
#' @export
find_outlier <- function(dt, var, ...){
  level <- NULL
  dt <- data.table::copy(dt)
  splittVal <- getOption("kh.geo.levels")
  DT <- listenv::listenv()

  for (i in seq_len(length(splittVal))){
    dd <- dt[level == splittVal[i]]
    DT[[i]] <- do_outlier(dd, var = var, ...)
  }

  DD <- data.table::rbindlist(as.list(DT))
  invisible(DD)
}

## HELPER ----------------
row_num <- function(x){
  if (length(x) == 1){
    x <- 1:x
  }

  return(x)
}

use_browser <- function(dd, grp){

  x <- DT::datatable(dd, options = list(
    pageLength = 25),
    filter = "top")

  htmlFile <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(x, htmlFile, selfcontained = TRUE)
  utils::browseURL((htmlFile))
}

do_outlier <- function(dt, var, ...){
  outVar <- paste0(var, c("_NUM", "_PCT"))
  for (i in outVar){
    dt <- mark_outlier(dt, var = i, ...)
  }

  invisible(dt)
}

# Give it 1 for lower outliers and 2 for upper outliers
mark_outlier <- function(dt, var, ...){
  dimensionID <- minVal <- maxVal <- NULL

  outVar <- paste0(var, "_OUT")

  dimDT <- dt[,
              list(minVal = grDevices::boxplot.stats(get(var))$stats[1],
                   maxVal = grDevices::boxplot.stats(get(var))$stats[5]),
              by = dimensionID]

  vals <- c("minVal", "maxVal")
  dt[dimDT, on = "dimensionID", (vals) := mget(vals)]

  dt[!is.na(get(var)), (outVar) := data.table::fcase(get(var) < minVal, 1L,  #lower
                                                     get(var) > maxVal, 2L)] #upper

  invisible(dt)
}
