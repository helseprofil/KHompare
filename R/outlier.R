#' @title Find Outlier
#' @description Find outlier values which indicate change in the measured
#'   variables is abnormal. This is based on the value in `xxx_NUM` and `_PCT`
#'   ie. numeric and percent change. New variables with `xxx_NUM_OUT` and
#'   `xxx_PCT_OUT` with value either:
#'     - NA not an outlier
#'     - 1 lower value outlier
#'     - 2 upper value outlier
#' @param dt Dataset
#' @param var Selected measured variables eg. MEIS, RATE etc
#' @param ... Additional agrument ie. bount = 2 (bound for outlier)
#' @export
find_outlier <- function(dt, var, ...){
  level <- NULL
  dt <- data.table::copy(dt)
  splittVal <- c("L","F","K","k","B")
  DT <- listenv::listenv()

  for (i in seq_len(length(splittVal))){
    dd <- dt[level == splittVal[i]]
    DT[[i]] <- do_outlier(dd, var = var, ...)
  }

  DD <- data.table::rbindlist(as.list(DT))
  invisible(DD)
}

## HELPER ----------------
do_outlier <- function(dt, var, ...){
  outVar <- paste0(var, c("_NUM", "_PCT"))
  for (i in outVar){
    dt <- mark_outlier(dt, var = i, ...)
  }

  invisible(dt)
}


mark_outlier <- function(dt, var, bound = 1.5){
  # bound - for outliner to equivalent to 3SD
  iqr <- stats::IQR(dt[[var]], na.rm = TRUE)
  tab <- summary(dt[[var]])
  minVal <- tab[["1st Qu."]] - bound*iqr
  maxVal <- tab[["3rd Qu."]] + bound*iqr

  outVar <- paste0(var, "_OUT")
  dt[!is.na(get(var)), (outVar) := data.table::fcase(get(var) < minVal, 1L,  #lower
                                                     get(var) > maxVal, 2L)] #upper
  invisible(dt)
}
