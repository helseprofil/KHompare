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
  var <- paste0(var, "_PCT")
  varOut <- paste0(var, "_OUT")

  varDim <- get_key_plot(data, plot = TRUE)

  ggplot2::ggplot(data, ggplot2::aes(x = AAR, y = .data[[var]], group = factor(KJONN))) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::geom_point(data = data[get(varOut) %in% 1:2], color = "red", size = 2.5) +
    ggplot2::facet_wrap(varDim, labeller = ggplot2::label_both, nrow = 2) +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90))

}


#' @export
#' @rdname plot_cube
pc <- plot_cube
