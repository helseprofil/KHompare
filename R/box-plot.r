# Box box

box_outliers <- function(data, var, value = c("pct", "num", "raw"), interactive = TRUE){

  value <- match.arg(value)
  if (length(value) > 2) value = "pct"

  vvars <- grep("_NUM", names(data), value = TRUE)
  pvars <- grep("_PCT", names(data), value = TRUE)

  if (isFALSE(any(var %in% names(data)))){
    msrVars <- pvars[-grep("_OUT", pvars)]
    msrVars <- gsub("_PCT", " ", msrVars)
    stop("Columname not found! Valid columnames: ", msrVars)
  }

  # for y-axis
  yvar <- switch(value,
                 pct = ": Prosent endring \u00E5rlig",
                 num = ": Numerisk endring \u00E5rlig",
                 raw = ": Raw data")
  varTitle <- paste0(var, yvar)

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

  khplot <- ggplot2::ggplot(data,
                            ggplot2::aes(x = level, y = .data[[var]],
                                         group = factor(.data[[grp]]),
                                         )) +
    ggplot2::geom_boxplot() +
    ggplot2::facet_wrap(varDim, labeller = ggplot2::label_both) +
    ggplot2::labs(title = varTitle, subtitle = "M\u00F8rker\u00F8dt prikker er outliers") +
    ggplot2::coord_flip()

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
