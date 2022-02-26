#' @title Get Grid of All Dimensions
#' @description Get cross join of all the dimensions for the analysis in the
#'   dataset.
#' @param dt Dataset
#' @param vars Key variables ie. the output from `get_key()`
#' @export
get_grid <- function(dt, vars){
  # vars - key variables
  indVars <- vars[vars != "GEO"]

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

  stdVars <- c(getOption("kh.demo.vars"), getOption("kh.kube.vars"))
  extVars <- setdiff(names(dt), stdVars)

  demoVars <- intersect(getOption("kh.demo.vars"), names(dt))
  keyVars <- c(demoVars, extVars)
  ## data.table::setkeyv(dt, keyVars)
}
