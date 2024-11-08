## $Id: 121-arrayltx-expect.R,v 1.1 2024/09/04 11:25:32 mg Exp $

## Purpose: Generate expected results for 120-arrayltx-fancy.R by executing
##          121-arrayltx-expect.red for both CSL and PSL

##   Notes: 1. this is not run as part of the tests, only prior to building the package
##          2. only needs to be run for CSL 

## $Log: 121-arrayltx-expect.R,v $
## Revision 1.1  2024/09/04 11:25:32  mg
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

tlines <- c(14, 13, 5, 14, 10, 3)
tskips <- c( 3,  5, 3, 3,  3, 3)
ntests <- length(tlines)
expect <- list()

if (do.csl) {
    csl.rc <- system2(redcsl, stdin="121-arrayltx-expect.red",
                      stdout="121-arrayltx-expect.clg",
                      stderr="121-arrayltx-expect.clg")
    if (csl.rc != 0) {
        writeLines(paste0("CSL execution returned ", csl.rc,
                          "All further csl tests will be skipped."))
    } else {
        clg <- readLines("121-arrayltx-expect.clg")
        tstart <- which(grepl("TEST [1-6]", clg))
        for (i in 1:ntests) {
            expect[[i]] <- clg[(tstart[i]+tskips[i]+1):(tstart[i]+tskips[i]+tlines[i]-1)]
            ## note that we write to 120-n-expect.txt
            writeLines(expect[[i]], paste0("120-", i, "-expect.txt"))
        }
    }
}

q("no")
