## $Id: 131-expr-expect.R,v 1.1 2024/09/04 11:27:35 mg Exp $

## Purpose: Generate expected results for 130-expr by executing data/131-expr-expect.red
##          for both CSL and PSL

##   Notes: 1. this is not run as part of the tests, only prior to building the package
##          2. only needs to be run for CSL 

## $Log: 131-expr-expect.R,v $
## Revision 1.1  2024/09/04 11:27:35  mg
## initial version
##
library(redcas)

source("test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
if (do.csl == FALSE) {
    writeLines("Skipping execution tests because redcsl was not found.")
    q("no")
}

tlines <- c(8, 8, 9, 9)
ntests <- length(tlines)
expect <- list()

if (do.csl) {
    csl.rc <- system2(redcsl, stdin="131-expr-expect.red",
                      stdout="131-expr-expect.clg",
                      stderr="131-expr-expect.clg")
    if (csl.rc != 0) {
        writeLines(paste0("CSL execution returned ", csl.rc,
                          "All further csl tests will be skipped."))
    } else {
        clg <- readLines("131-expr-expect.clg")
        tstart <- which(grepl("TEST [1-4]", clg))
        for (i in 1:ntests) {
            expect[[i]] <- clg[(tstart[i]+2):(tstart[i]+tlines[i])]
            ## note that we write to 130-n-expect.txt
            writeLines(expect[[i]], paste0("130-", i, "-expect.txt"))
        }
    }
}

q("no")
