source("dev/settings.R")
pkg <- c("data.table", "fs")
sapply(pkg, require, character.only = TRUE)

## OS <- Sys.info()["sysname"]
## sysDrive <- switch(OS,
##                    Linux = "/mnt/F",
##                    Windows = "F:"
##                    )

KBroot <- file.path(sysDrive, "Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA" )
KByr <- paste0("KH", as.integer(format(Sys.Date(), "%Y")) - 1, "NESSTAR") #temporarily to have 2021 folder
KBfile <- file.path(KBroot, KByr, "ALKOHOL_UNGD_2021-01-26-14-48.csv")
KBfile
DT <- fread(KBfile)
DT





outlier <- function(x, outlier = c("min", "max")){
  iqr <- IQR(x, na.rm = TRUE)

  val <- summary(x)

  if (outlier == "min"){
    val[["1st Qu."]]*1.5
  } else {
    val[["3rd Qu."]]*1.5
  }
}

minMEIS <- outlier(DT$MEIS, "min")
maxMEIS <- outlier(DT$MEIS, "max")
minMEIS
maxMEIS

str(DT)


DT[GEO == 0 & SOES == 0]
