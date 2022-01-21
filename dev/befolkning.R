library(fs)
foldBF <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR"
## fileBF <- "BEFOLK_GK_2021-01-26-12-08.csv"

## Find the recent BEFOLKNING file, provided it's always called "BEFOLK_GK_*"
dirFile <- fs::dir_ls(foldBF)
fileBEF <- grep("BEFOLK_GK", dirFile, value = TRUE)
yr <- gsub(".*(\\d{4})-(\\d{2})-(\\d{2})-(\\d{2})-(\\d{2}).csv$", "\\1\\2\\3\\4\\5", fileBEF)
yrFile <- sort(as.numeric(yr), TRUE)
dupFile <- any(yrFile[1], yrFile[-1])

year <- yrFile[1]
fileExt <- gsub("^(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})", "\\1_\\2-\\3-\\4-\\5", year)
fileBEF <- paste0("BEFOLK_GK_", fileExt, ".csv")
fileBEF

library(data.table)
DT <- fread(file.path(foldBF, fileBF))
str(DT)
dt <- DT[KJONN == 0 & ALDER == "0_120"]

dt
dt[, level := fcase(nchar(GEO) %in% 1:2, "F",
                    nchar(GEO) %in% 3:4, "K",
                    nchar(GEO) %in% 5:6, "B")]

dt[GEO == 0 , level := "L"]
dt[, stor := fifelse(TELLER >= 10000, 1, 0) ]
dt[, .N, by = level]
dt[, .N, by = stor]



## ## Koder som brukes i do fil for storkommunne
## ---------------------------------------------
## drop _merge
## gen storkommune=(folketall>=10000 & folketall<.)
## gen geonivaa="L"
## replace geonivaa="F" if GEO>0 & GEO<=80 // 2020
## replace geonivaa="H" if GEO>=81 & GEO<=84 //
## replace geonivaa="K" if GEO>=100
## replace geonivaa="B" if GEO>30000
## replace geonivaa="k" if storkommune==0 & GEO>=100 & GEO<8099
