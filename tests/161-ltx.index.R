## $Id: 161-ltx.index.R,v 1.3 2024/10/19 13:23:27 mg Exp $
## Purpose: testing changes to avoid double superscripts when an indexed item with
##          covariant indices is raised to a power
##    Note: These tests do NOT require a reduce session
## $Log: 161-ltx.index.R,v $
## Revision 1.3  2024/10/19 13:23:27  mg
## added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.2  2024/10/04 09:54:06  mg
## 1. load the library rather than the development version of the function
## 2. use redcas::: as prefix for calling
##
## Revision 1.1  2024/10/03 13:05:36  mg
## Initial version
##

library(redcas)
source("data/test-utils.R")

expect <- list()
actual <- list()
idx.map=c(g="__", "x"="^", "h"="^_", "\\\\sigma"="_", "\\\\phi"="^^_", "\\\\Gamma"="__^^")

for (i in 1:3) {
    expect[[i]] <- readLines(paste0("data/161-expect-00", i, ".tex"))
    actual[[i]] <- redcas:::ltx.index(readLines(paste0("data/161-input-00", i, ".tex")),
                  idx.map) ##, debug=TRUE)
    writeLines(actual[[i]])
}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redLtxIdx',expect,actual))
## don't save environment
q("no")
