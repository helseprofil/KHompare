
find_outlier <- function(dt, var, ...){
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

do_outlier <- function(dt, var, ...){
  outVar <- paste0(var, c("_PCT", "_NUM"))
  for (i in outVar){
    dt <- mark_outlier(dt, var = i, ...)
  }

  invisible(dt)
}


mark_outlier <- function(dt, var, bound = 1.5){
  # bound - for outliner to equivalent to 3SD
  iqr <- IQR(dt[[var]], na.rm = TRUE)
  tab <- summary(dt[[var]])
  minVal <- tab[["1st Qu."]] - bound*iqr
  maxVal <- tab[["3rd Qu."]] + bound*iqr

  outVar <- paste0(var, "_OUT")
  dt[!is.na(get(var)), (outVar) := data.table::fcase(get(var) < minVal, 1L,  #lower
                                                     get(var) > maxVal, 2L)] #upper
  invisible(dt)
}
