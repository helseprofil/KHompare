#' @title Plot Data
#' @description Plot cube dataset for selected geo code and cube measurement
#'   variable
#' @param data Cube dataset from `check_cube()` function
#' @param geo Geographical code
#' @param var Cube measure variable
#' @param value Percentage or numeric change. Select either `pct` or `num`
#' @param interactive Logical value. Interactive plot or static
#' @examples
#' \dontrun{
#' plot_outliers(dt, geo = 3, var = "TELLER")
#' }
#' @export

plot_outliers <- function(data, geo, var, value = c("pct", "num", "raw"), interactive = TRUE){

  GEO <- AAR <- .data <- NULL
  KJONN <- label_both <- NULL

  value <- match.arg(value)
  if (length(value) > 2) value = "pct"

  data <- data[GEO == geo]
  vvars <- grep("_NUM", names(data), value = TRUE)
  pvars <- grep("_PCT", names(data), value = TRUE)

  if (isFALSE(any(var %in% names(data)))){
    msrVars <- pvars[-grep("_OUT", pvars)]
    msrVars <- gsub("_PCT", " ", msrVars)
    stop("Columname not found! Valid columnames: ", msrVars)
  }


  if (value != "raw"){
    var <- paste0(var, "_", toupper( value ))
    # Outliers will be darkred points
    varOut <- paste0(var, "_OUT")
  }

  varDim <- get_key_plot(data, plot = TRUE)
  varGrp <- demo_grp(data)

  if (varGrp == "KJONN"){
    grp <- "KJONN"
  } else {
    grp <- "ALDER"
    varDim <- var_dim(data, varDim)
  }

  # for y-axis
  yvar <- switch(value,
                 pct = ": Prosent endring \u00E5rlig",
                 num = ": Numerisk endring \u00E5rlig",
                 raw = ": Raw data")
  varTitle <- paste0(var, yvar)

  title <- paste0("GEO = ", geo, " for ", varTitle)

  khplot <- ggplot2::ggplot(data,
                            ggplot2::aes(x = AAR, y = .data[[var]], group = factor(.data[[grp]]))) +
    ggplot2::geom_line(ggplot2::aes( color = factor(.data[[grp]]) )) +
    ggplot2::geom_point(ggplot2::aes( color = factor(.data[[grp]]) ))

  if (value != "raw"){
    khplot <- khplot +
      ggplot2::geom_point(data = data[get(varOut) %in% 1:2], color = "#8b0000", size = 2.5)
  }

  khplot <- khplot +
    ggplot2::facet_wrap(varDim, labeller = ggplot2::label_both, nrow = 2) +
    ggplot2::labs(title = title, subtitle = "M\u00F8rker\u00F8dt prikker er outliers") +
    ggplot2::scale_color_discrete(grp) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.3),
                   legend.position = "bottom")

  if (interactive){
    x <- plotly::ggplotly(khplot)
    htmlFile <- tempfile(fileext = ".html")
    htmlwidgets::saveWidget(x, htmlFile, selfcontained = TRUE)
    utils::browseURL((htmlFile))
  } else {
    grDevices::x11()
    khplot
  }
}


#' @export
#' @rdname plot_outliers
po <- plot_outliers

#' @title Plot Data
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Make funcion name standardize
#' @examples
#' \dontrun{
#' plot_cube(dt, geo = 3, var = "TELLER")
#' # ->
#' plot_outliers(dt, geo = 3, var = "TELLER")
#' }
#' @keywords internal
#' @export

plot_cube <- function(data, geo, var, value = c("pct", "num", "raw"), interactive = TRUE){

  lifecycle::deprecate_warn("0.3.6", "plot_cube()", "plot_outliers()")

  plot_outliers(data, geo, var, value, interactive)
}

#' @export
#' @rdname plot_cube
pc <- plot_cube

## HELPER -------------
demo_grp <- function(data){
  var <- get_key_plot(data, plot = TRUE)
  demoVar <- intersect(names(data), c("KJONN", "ALDER"))

  if (length(demoVar) > 1){
    age <- any(names(data) == "ALDER")
    grp <- is_grp(age)
  } else {
    grp <- demoVar
  }
  grp
}

var_dim <- function(data, vars){
  # vars - dimensions variables
  if(isTRUE( any(names(data) == "KJONN") )){
    c(vars, "KJONN")
  } else {
    vars
  }
}

is_grp <- function(x){
  # x - logical
  if (x){
    "ALDER"
  } else {
    "KJONN"
  }
}
