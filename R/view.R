#' @title View Outliers
#' @description View outliers for selected variables
#' @param dt Dataset object from `check_cube()` function
#' @param var Measure variables eg. RATE, MEIS etc
#' @param nrows Number of rows or select rows to show eg. `nrows = 10` or `nrows = 5:15`
#' @param levels Level of geographical granularity as in `getOption("kh.geo.levels")`
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
                          levels = NULL,
                          browser = TRUE){

  level <- NULL

  levelVals <- getOption("kh.geo.levels")
  if (is.null(levels)) {
    levels <- levelVals
  }

  if (isFALSE(any(levels %in% levelVals))){
    stop("Levels `arg` accepts only ", paste(levelVals, collapse = ", "))
  }

  vvars <- grep("_NUM", names(dt), value = TRUE)
  pvars <- grep("_PCT", names(dt), value = TRUE)

  if (isFALSE(any(var %in% names(dt)))){
    msrVars <- pvars[-grep("_OUT", pvars)]
    msrVars <- gsub("_PCT", " ", msrVars)
    stop("Columname not found! Available columnames: ", msrVars)
  }

  cols <- setdiff(names(dt), c(vvars, pvars))

  # outliers columns
  svars <- paste0(var, c("_NUM_OUT", "_PCT_OUT"))
  scols <- c(cols, svars)

  dd <- dt[!is.na(get(svars[1])) | !is.na(get(svars[2])), mget(scols)][level %chin% levels]

  if (!is.null(nrows)){
    nrows <- row_num(nrows)
    dd <- dd[nrows]
  }

  if (browser){
    use_browser(dd)
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


use_browser <- function(dd){

  DT::datatable(dd, options = list(
    pageLength = 50),
    filter = "top")
}
