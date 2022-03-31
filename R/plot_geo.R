#' @title Plot Outliers For Geo

plot_geo <- function(data, var,
                     geo.levels = "all",
                     nrow = 1:10
                     ){

  GEO <- AAR <- .data <- NULL
  KJONN <- label_both <- NULL

  vvars <- grep("_NUM", names(data), value = TRUE)
  pvars <- grep("_PCT", names(data), value = TRUE)

  if (isFALSE(any(var %in% names(data)))){
    msrVars <- pvars[-grep("_OUT", pvars)]
    msrVars <- gsub("_PCT", " ", msrVars)
    stop("Columname not found! Available columnames: ", msrVars)
  }

  stdDim <- get_key_plot(data)
  tblDim <- setdiff(stdDim, "AAR")

  # Groupping by dimensions
  .GRP <- data.table::.GRP
  data[, "dimensionID" := .GRP , by = tblDim]

  if (geo.levels != "all"){
    geo_args(geo.levels)
    data <- data[level %in% geo.levels, ]
  }
  ##:ess-bp-start::browser@nil:##
  browser(expr=is.null(.ESSBP.[["@8@"]]));##:ess-bp-end:##

  pctVar <- paste0(var, "_PCT")
  numVar <- paste0(var, "_NUM")
  delCC <- unique(gsub("_PCT.*", "", pvars))
  delCols1 <- setdiff(c(vvars, pvars), c(pctVar, numVar))
  delCols2 <- intersect(names(data), delCC)
  delCols <- setdiff(c(delCols1, delCols2), var)
  data[, (delCols) := NULL]
  data[, PCT := sparkline::spk_chr(get(pctVar)), by = dimensionID]
  data[, NUM := sparkline::spk_chr(get(numVar)), by = dimensionID]
  data[, RAW := sparkline::spk_chr(get(var)), by = dimensionID]
  data <- data[!duplicated(dimensionID)][1:10]
  data[, c("AAR", "dimensionID") := NULL]

  DT::datatable(data, escape = FALSE, filter = "top",
                options = list(paging = FALSE, fnDrawCallback = htmlwidgets::JS(
                  '
                   function(){
                   HTMLWidgets.staticRender();
                   }
                  '
                )
                )) |>
    sparkline::spk_add_deps()
}


## HELPER ----------------

geo_args <- function(x){

  g <- all(x %in% getOption("kh.geo.levels"))
  if (!g){
    stop("Accepted geo.levels are ", getOption("kh.geo.levels"))
  }
  invisible()
}
