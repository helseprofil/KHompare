foldBF <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2021NESSTAR"
fileBF <- "BEFOLK_GK_2021-01-26-12-08.csv"

library(orgdata)
DT <- fread(file.path(foldBF, fileBF), nrows = 10000)

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
