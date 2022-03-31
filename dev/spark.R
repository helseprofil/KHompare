library(tibble)
library(data.table)
library(sparkline)

dt <- as.data.table(iris)[1:10]
dt[, ID := rep(1:2, 5)]
dt[, chart := sparkline::spk_chr(Sepal.Length), by = ID]
dt[, chart2 := sparkline::spk_chr(Sepal.Width, type = "box"), by = ID]
dt
gg <- gt(dt)
gg <- gt::fmt_markdown(gg, columns = c(chart, chart2))
ggHtml <- gt:::as.tags.gt_tbl(gg)
ggHtml <- htmltools::attachDependencies(ggHtml, htmlwidgets::getDependency("sparkline"))
print(ggHtml, browse = interactive())

## With DT package
## ref https://www.infoworld.com/article/3318222/how-to-add-sparklines-to-r-tables.html
library(DT)
DT::datatable(dt, escape = FALSE, filter = "top",
              options = list(paging = FALSE, fnDrawCallback = htmlwidgets::JS(
                '
function(){
  HTMLWidgets.staticRender();
}
'
)
)) |>
  sparkline::spk_add_deps()
