#' @title View Outliers
#' @description View outliers for selected variables
#' @param dt Dataset object from `check_cube()` function
#' @param var Measure variables eg. RATE, MEIS etc
#' @param nrow Number of rows to show
#' @examples
#' \dontrun{
#'  dt <- check_cube("ALKOHOL")
#'  view_outliers(dt, "RATE")
#' }
#' @export
view_outliers <- function(dt = NULL, var = NULL, nrow = NULL){

  if (isFALSE(any(var %in% names(dt)))){
    stop("Columname not found!")
  }

  vvars <- grep("_NUM", names(dt), value = TRUE)
  pvars <- grep("_PCT", names(dt), value = TRUE)

  cols <- setdiff(names(dt), c(vvars, pvars))

  svars <- paste0(var, c("_NUM_OUT", "_PCT_OUT"))
  scols <- c(cols, svars)

  DT <- dt[!is.na(get(svars[1])) | !is.na(get(svars[2])), mget(scols)]

  if (!is.null(nrow)){
    nrow <- row_num(nrow)
    DT <- DT[nrow]
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
