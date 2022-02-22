
OS <- Sys.info()["sysname"]
sysDrive <- switch(OS,
                   Linux = "/mnt/F",
                   Windows = "F:"
                   )
