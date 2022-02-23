library(yaml)

yy <- yaml.load_file("dev/config.yml")
yy

yy[["kube-vars"]]
isTRUE(yy$verbose)
