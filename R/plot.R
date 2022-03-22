#' @title Plot Data
#' @description Plot cube dataset for selected geo code and cube measurement
#'   variable
#' @param data Cube dataset from `check_cube()` function
#' @param geo Geographical code
#' @param var Cube measure variable
#' @examples
#' \dontrun{
#' plot_cube(dt, geo = 3, var = "TELLER")
#' }
#' @export

plot_cube <- function(data, geo, var){

  GEO <- AAR <- .data <- NULL
  KJONN <- label_both <- NULL

  data <- data[GEO == geo]
  vvars <- grep("_NUM", names(data), value = TRUE)
  pvars <- grep("_PCT", names(data), value = TRUE)

  if (isFALSE(any(var %in% names(data)))){
    msrVars <- pvars[-grep("_OUT", pvars)]
    msrVars <- gsub("_PCT", " ", msrVars)
    stop("Columname not found! Available columnames: ", msrVars)
  }

  # for y-axis
  varTitle <- var
  var <- paste0(var, "_PCT")
  # Outliers will be darkred points
  varOut <- paste0(var, "_OUT")

  varDim <- get_key_plot(data, plot = TRUE)
  varGrp <- demo_grp(data)

  title <- paste0("GEO: ", geo, " for ", varTitle)

  if (varGrp == "KJONN"){
    grp <- "KJONN"
  } else {
    grp <- "ALDER"
    varDim <- var_dim(data, varDim)
  }

  khplot <- ggplot2::ggplot(data, ggplot2::aes(x = AAR, y = .data[[var]], group = factor(.data[[grp]]))) +
    ggplot2::geom_line(ggplot2::aes( color = factor(.data[[grp]]) )) +
    ggplot2::geom_point(ggplot2::aes( color = factor(.data[[grp]]) )) +
    ggplot2::geom_point(data = data[get(varOut) %in% 1:2], color = "#8b0000", size = 2.5) +
    ggplot2::facet_wrap(varDim, labeller = ggplot2::label_both, nrow = 2) +
    ggplot2::labs(title = title, subtitle = "M\u00F8rker\u00F8dt prikker er outliers") +
    ggplot2::scale_color_discrete(grp) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90),
                   legend.position = "bottom")

  x11()
  khplot

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
  if(any(names(data) == "KJONN")){
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
