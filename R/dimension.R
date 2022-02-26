#' @title Get Grid of All Dimensions
#' @description Get cross join of all the dimensions for the analysis in the
#'   dataset.
#' @param dt Dataset
#' @param vars Key variables ie. the output from `get_key()`
#' @export
get_grid <- function(dt, vars){
  # vars - key variables
  indVars <- vars[!(vars %in% c("GEO", "AAR"))]

  for (i in indVars){
    indx <- unique(dt[[i]])
    .env_dim[[i]] <- indx
  }

  dd <- expand.grid(mget(indVars, envir = .env_dim), stringsAsFactors = FALSE)
  data.table::setDT(dd)
}

#' @title Get Key Variables
#' @description Get key variables to sort the dataset.
#' @inheritParams get_grid
#' @export
get_key <- function(dt){

  stdVars <- c(getOption("kh.demo.vars"), getOption("kh.kube.vars"), getOption("kh.misc.vars"))
  extVars <- setdiff(names(dt), stdVars)

  demoVars <- intersect(getOption("kh.demo.vars"), names(dt))
  c(demoVars, extVars)
  ## data.table::setkeyv(dt, keyVars)
}

get_measure <- function(dt, dim){
  dimVars <- intersect(getOption("kh.kube.vars"), names(dt))

  dtCols <- names(data.table::copy(dt))
  idvar = "khompareID" #ID to merge the data back
  dt[, (idvar) := 1:.N]
  data.table::setkeyv(dt, idvar)

  DTenv <- listenv::listenv()

  sumVars <- length(dimVars)
  for (i in seq_len(sumVars)){
    DTenv[[i]] <- do_compare(dt, dim = dim, var = dimVars[i])
  }

  DTenv[[sumVars + 1]] <- dt
  DT <- Reduce(function(...) merge(..., all = TRUE), as.list(DTenv))

  DT[, (idvar) := NULL]
  meaCols <- setdiff(names(DT), dtCols)
  data.table::setcolorder(DT, c(dtCols, meaCols))
  DT
}

do_compare <- function(dt, dim, var){
  # dim - dimension variables from get_grid()
  # var - selected dim variable
  dt <- data.table::copy(dt)
  idvar = "khompareID" #ID to merge the data back
  ind <- nrow(dim)
  indVars <- names(dim)

  dtEnv <- listenv::listenv()

  for (i in seq_len(ind)){
    dd <- dt[dim[i], on = indVars]
    dd[, khompareVAR := shift(x = get(var), type = "lag"), by = GEO]
    dd[, khomparePCT := ((get(var)/khompareVAR)-1)*100, by = GEO]

    varName <- paste0(var, "_CHG")
    data.table::setnames(dd, "khomparePCT", varName)
    delCols <- setdiff(names(dd), c(idvar, varName))
    dd[, (delCols) := NULL]
    data.table::setkeyv(dd, idvar)
    dtEnv[[i]] <- dd

  }

  DT <- data.table::rbindlist(as.list(dtEnv))
  DT
}
