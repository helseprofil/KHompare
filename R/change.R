#' @title Get the Difference
#' @description Get the difference for change in the cube measure variables ie.
#'   the varibles that are created when running the function `LagKUBE()` from
#'   `KHfunctions`.
#' @param dt Dataset
#' @param dim Dimension dataset produced by `get_grid()`
#' @inheritParams check_cube
#' @export

diff_change <- function(dt, dim, ...){
  # dim - dimension dataset from get_grid()
  cubeCols <- intersect(getOption("kh.kube.vars"), names(dt))
  dtCols <- names(data.table::copy(dt))

  #Dummy ID to be used for merging the data back
  #when splitting the data by its dimensions
  idvar = "khompareID"
  dt[, (idvar) := 1:.N]
  data.table::setkeyv(dt, idvar)

  DTenv <- listenv::listenv()
  sumVars <- length(cubeCols)
  for (i in seq_len(sumVars)){
    DTenv[[i]] <- find_change(dt, dim = dim, var = cubeCols[i], ...)
  }

  DTenv[[sumVars + 1]] <- dt
  DT <- Reduce(function(...) merge(..., all = TRUE), as.list(DTenv))
  DT[, (idvar) := NULL]
  meaCols <- setdiff(names(DT), dtCols)
  data.table::setcolorder(DT, c(dtCols, meaCols))
  DT
}

#' @title Find Change Over Time
#' @description Find the change over time. It could be change from previous year
#'   or a specific time period.
#' @inheritParams diff_change
#' @param var Selected dimension ie. \code{dim}, variable from \code{get_grid()}
#'   function
#' @param ... Other extended arguments
#' @export

find_change <- function(dt, dim, var, ...){
  GEO <- khompareNUM <- khomparePCT <- khompareVAR <- NULL

  dt <- data.table::copy(dt)
  idvar = "khompareID" #ID to merge the data back
  ind <- nrow(dim)
  indVars <- names(dim)

  dtEnv <- listenv::listenv()
  for (i in seq_len(ind)){
    dd <- dt[dim[i], on = indVars]
    dd[, khompareVAR := shift(x = get(var), type = "lag"), by = GEO]
    # Get change on numeric value
    dd[, khompareNUM := get(var) - khompareVAR, by = GEO]
    # Get percentage change
    dd[, khomparePCT := ((get(var)- khompareVAR)/khompareVAR)*100, by = GEO]

    oldName <- paste0("khompare", c("NUM", "PCT"))
    varName <- paste0(var, c("_NUM", "_PCT"))
    data.table::setnames(dd, oldName, varName)
    ## level is needed to cehck for outlier by level
    delCols <- setdiff(names(dd), c(idvar, varName, "level"))
    dd[, (delCols) := NULL]
    data.table::setkeyv(dd, idvar)
    dtEnv[[i]] <- dd
  }

  DT <- data.table::rbindlist(as.list(dtEnv))
  DT <- find_outlier(DT, var, ...)
  DT[, "level" := NULL]
}
