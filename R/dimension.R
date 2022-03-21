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
#' @param plot Logical value to select key variables for plot or not
#' @export
get_key <- function(dt, plot = FALSE){

  stdVars <- c(getOption("kh.demo.vars"), getOption("kh.kube.vars"), getOption("kh.misc.vars"))
  extVars <- setdiff(names(dt), stdVars)

  demoVars <- intersect(getOption("kh.demo.vars"), names(dt))

  if (plot){
    extVars
  } else {
    c(demoVars, extVars)
  }
  ## data.table::setkeyv(dt, keyVars)
}


get_key_plot <- function(...){

  var <- get_key(...)
  varpc <- grep("_PCT", var)
  varnm <- grep("_NUM", var)
  var <- var[-c(varpc, varnm)]

  return(var)
}
