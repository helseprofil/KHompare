pkg <- c("data.table", "fs")
sapply(pkg, require, character.only = TRUE)

KBroot <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA"
KByr <- paste0("KH", as.integer(format(Sys.Date(), "%Y")) - 1, "NESSTAR") #temporarily to have 2021 folder
KBfile <- file.path(KBroot, KByr, "ALKOHOL_UNGD_2021-01-26-14-48.csv")
KBfile
dt <- fread(KBfile)
dt




minMEIS <- outlier(dt$MEIS, "min")
maxMEIS <- outlier(dt$MEIS, "max")
minMEIS
maxMEIS

outlier <- function(x, outlier = c("min", "max")){
  iqr <- IQR(x, na.rm = TRUE)

  val <- summary(x)

  if (outlier == "min"){
    val[["1st Qu."]]*1.5
  } else {
    val[["3rd Qu."]]*1.5
  }
}

str(dt)
