library(haven)
library(data.table)
folder <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/VALIDERING/NESSTAR_KUBER/2021/KH/z_Data/dtakopierPreppet"
dt <- read_dta(file.path(folder, "ARBLEDIGE_2020-12-03-16-22.dta"))
setDT(dt)

names(dt)
dt[, .N, by=ekstradims]
dt[, .N, by=ekstradim_levels]
dt[, .N, by=edl_txt]
dt[, .N, by=storkommune]
dim(dt)

library(ggplot2)

pp <- ggplot(dt[geonivaa!="k"], aes(RATE, geonivaa)) + geom_boxplot()
pp


folk <- "_Folketall.dta"
dfolk <- read_dta(file.path(folder, folk))
setDT(dfolk)
dfolk


### KUBE files ----------

kubeRoot <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER"
kubeFD <- "KOMMUNEHELSA/KH2020NESSTAR"
kubeFile <- "ARBLEDIGE_2020-11-06-10-36.csv"

df <- fread(file.path(kubeRoot, kubeFD, kubeFile))
df
