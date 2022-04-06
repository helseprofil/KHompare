# System OS
OS <- Sys.info()["sysname"]

# file config.yml should be somewhere and if not found
# use the one in inst folder
## opts <- yaml::yaml.load_file(system.file("config.yml", package = "KHompare"))
opts <- yaml::yaml.load_file("https://raw.githubusercontent.com/helseprofil/config/main/config-khompare.yml")
opt.khompare <- opt_rename(opts)

.onLoad <- function(libname, pkgname){
  op <- options()
  optDiff <- !(names(opt.khompare) %in% names(op))
  if (any(optDiff)) options(opt.khompare[optDiff])
  invisible()
}

.onAttach <- function(libname, pkgname){
  packageStartupMessage("KHompare version 0.3.5")
}
