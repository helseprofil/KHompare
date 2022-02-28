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
dirAll <- fs::dir_ls(file.path(KBroot, KByr))

file01 <- grep("ALKOHOL", dirAll, value = TRUE)
file02 <- grep("REGNEFERD", dirAll, value = TRUE)
file02

DT <- fread(file02)
DT


DT[, level := fcase(nchar(GEO) %in% 1:2, "F",
                    nchar(GEO) %in% 3:4, "k",
                    nchar(GEO) %in% 5:6, "B")]

DT[GEO == 0 , level := "L"]

stdVars <- c("GEO", "AAR", "KJONN", "ALDER", "TELLER", "RATE", "SMR", "MEIS", "sumNEVNER", "sumTELLER", "SPVFLAGG", "level")
extVars <- setdiff(names(DT), stdVars)
extVars
stdVars <- intersect(c("GEO", "AAR", "level", "KJONN", "ALDER"), names(DT))
stdVars
keyVars <- c(stdVars, extVars)
setkeyv(DT, keyVars)
keyVars
DT

## INDEX -----------
indVars <- keyVars[!( keyVars %in% c( "GEO", "level" ) )]
indVars
indList <- listenv::listenv()
for (i in indVars){
  ind <- DT[, .N, by = get(i)][[1]]
  indList[[i]] <- ind
}

length(indList)
names(indList)
env2 <- new.env()
## AAR <- indList[["AAR"]]
assign(names(indList)[1], indList[["AAR"]])
assign(names(indList)[2], indList[["KJONN"]])
assign(names(indList)[3], indList[["TRINN"]])
assign(names(indList)[4], indList[["FERDNIVAA"]])


assign(names(indList)[1], indList[["AAR"]], envir = env2)
assign(names(indList)[2], indList[["KJONN"]], envir = env2)
assign(names(indList)[3], indList[["TRINN"]], envir = env2)
assign(names(indList)[4], indList[["FERDNIVAA"]], envir = env2)

indVars
inx <- CJ(AAR, KJONN, TRINN, FERDNIVAA, sorted = FALSE)
inx

inx2 <- expand.grid(mget(indVars, envir = env2))
inx2


( SOES <- DT[, .N, by = SOES][[1]] )
( KJONN <- DT[, .N, by = KJONN][[1]] )
( ALDER <- DT[, .N, by = ALDER][[1]] )

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
    val[["1st Qu."]] - 1.5*iqr
  } else {
    val[["3rd Qu."]] + 1.5*iqr
  }
}

DT <- copy(dt)
minMEIS <- outlier(DT$MEIS_PCT, "min")
maxMEIS <- outlier(DT$MEIS_PCT, "max")
minMEIS
maxMEIS

str(DT)


DT[GEO == 0 & SOES == 0]
