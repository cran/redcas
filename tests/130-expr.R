## $Id: 130-expr.R,v 1.2 2024/10/19 13:40:08 mg Exp $

## Purpose: Execute 130-expr.red for both CSL and PSL and compare results to expected

## $Log: 130-expr.R,v $
## Revision 1.2  2024/10/19 13:40:08  mg
## 1. added --nogui option for csl
## 2. added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/04 11:27:35  mg
## initial version
##
library(redcas)
writeLines(c(paste0("redCodeDir: ", redCodeDir()),
             paste0("   pkd dir: ", system.file(package="redcas")),
             paste0("REDCODEDIR: ", Sys.getenv("REDCODEDIR")))
           )

source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcsl <- redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redpsl <- redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping execution tests because neither redcsl nor redpsl was found.")
    q("no")
}

tlines <- c(8, 8, 9, 9)
ntests <- length(tlines)
expect <- list()
actual <- list()

if (do.csl) {
    cslopt <- "--nogui"         ## needed for Darwin, no harm for Linux
    csl.rc <- system2(redcsl, args=cslopt, stdin="data/130-expr.red",
                      stdout="130-expr.clg",
                      stderr="130-expr.clg")
    if (csl.rc != 0) {
        writeLines(paste0("CSL execution returned ", csl.rc,
                          "\nAll further csl tests will be skipped."))
    } else {
        clg <- readLines("130-expr.clg")
        tstart <- which(grepl("TEST [1-6]", clg))
        for (i in 1:ntests) {
            expect[[i]] <- readLines(paste0("data/130-", i, "-expect.txt"))
            actual[[i]] <- clg[(tstart[i]+2):(tstart[i]+tlines[i])]
        }
    }
}

if (do.psl) {
    psl.rc <- system2(redpsl, stdin="data/130-expr.red",
                      stdout="130-expr.plg",
                      stderr="130-expr.plg")
    if (psl.rc != 0) {
        writeLines(paste0("PSL execution returned ", psl.rc,
                          "All further psl tests will be skipped."))
    } else {
        plg <- readLines("130-expr.plg")
        tstart <- which(grepl("TEST [1-6]", plg))
        for (i in 1:ntests) {
            j <- ntests + i
            expect[[j]] <- readLines(paste0("data/130-", i, "-expect.txt"))
            actual[[j]] <- plg[(tstart[i]+2):(tstart[i]+tlines[i])]
        }
    }
}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redExpr',expect,actual))
q("no")
