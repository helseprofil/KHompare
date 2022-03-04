#' @title View Outliers
#' @description View outliers for selected variables
#' @param dt Dataset object from `check_cube()` function
#' @param var Measure variables eg. RATE, MEIS etc
#' @param nrows Number of rows or select rows to show eg. `nrows = 10` or `nrows = 5:15`
#' @param levels Level of geographical granularity. Accepted values are L, F, K, k and B
#' @examples
#' \dontrun{
#'  dt <- check_cube("ALKOHOL")
#'  view_outliers(dt, "RATE")
#' }
#' @export
view_outliers <- function(dt = NULL,
                          var = NULL,
                          nrows = NULL,
                          levels = NULL){

  level <- NULL

  levelVals <- c("L", "F", "K", "k", "B")
  if (is.null(levels)) {
    levels <- levelVals
  }

  if (isFALSE(any(levels %in% levelVals))){
    stop("Levels `arg` accepts only ", paste(levelVals, collapse = ", "))
  }

  if (isFALSE(any(var %in% names(dt)))){
    stop("Columname not found!")
  }

  vvars <- grep("_NUM", names(dt), value = TRUE)
  pvars <- grep("_PCT", names(dt), value = TRUE)

  cols <- setdiff(names(dt), c(vvars, pvars))

  svars <- paste0(var, c("_NUM_OUT", "_PCT_OUT"))
  scols <- c(cols, svars)

  DT <- dt[!is.na(get(svars[1])) | !is.na(get(svars[2])), mget(scols)][level %chin% levels]

  if (!is.null(nrows)){
    nrows <- row_num(nrows)
    DT <- DT[nrows]
  }

  DT[]
}

#' @export
#' @rdname view_outliers
vis_uteligger <- view_outliers

## Helper ------------
row_num <- function(x){
  if (length(x) == 1){
    x <- 1:x
  }

  return(x)
}
