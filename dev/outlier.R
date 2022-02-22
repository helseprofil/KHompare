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


DT[, level := fcase(nchar(GEO) %in% 1:2, "F",
                    nchar(GEO) %in% 3:4, "k",
                    nchar(GEO) %in% 5:6, "B")]

DT[GEO == 0 , level := "L"]

stdVars <- c("GEO", "AAR", "KJONN", "ALDER", "TELLER", "RATE", "SMR", "MEIS", "sumNEVNER", "sumTELLER", "SPVFLAGG", "level")
extVars <- setdiff(names(DT), stdVars)
extVars
keyVars <- c("GEO", "AAR", "level", "KJONN", "ALDER", extVars)
setkeyv(DT, keyVars)
DT

## INDEX -----------
SOES <- DT[, .N, by = SOES][[1]]
KJONN <- DT[, .N, by = KJONN][[1]]
ALDER <- DT[, .N, by = ALDER][[1]]

## kjonn <- c(0,1,2)
ind <- CJ(SOES, KJONN, ALDER, sorted = FALSE)

ind
ind[1]
dt01 <- DT[ind[2], on = names(ind)]
dt01[, .N, by=SOES]
dt01

dt01[, meis2 := shift(MEIS, type = "lag"), by = GEO]
dt01[, meis_pct := (MEIS-meis2)/meis2*100, by = GEO]
dt01



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


