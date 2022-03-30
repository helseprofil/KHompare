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
    stop("Columname not found! Available columnames: ", msrVars)
  }

  allCols <- setdiff(names(dt), c(vvars, pvars))
  stdCols <- intersect(c(getOption("kh.demo.vars"), "level"), allCols)

  selCols <- paste0(var, c("_PCT", "_NUM"))
  cols <- c(stdCols, var, selCols)

  # outliers columns
  svars <- paste0(var, c("_PCT_OUT","_NUM_OUT"))
  scols <- c(cols, svars)

  dd <- dt[!is.na(get(svars[1])) | !is.na(get(svars[2])), mget(scols)][level %chin% geo.levels]

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

## Helper ------------
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
