## $Id: 150-asltx.R,v 1.2 2024/10/05 15:12:44 mg Exp $
## Purpose: test reduce functions in redcas.red directly in a batch reduce call
## $Log: 150-asltx.R,v $
## Revision 1.2  2024/10/05 15:12:44  mg
## Moved to inst
##
## Revision 1.1  2024/09/04 11:28:51  mg
## initial version
##

## the current library is needed as well as the new functions
library(redcas)
## assign environment vars needed for batch reduce to be able to load reduce.red
writeLines(c(paste0("redCodeDir: ", redCodeDir()),
             paste0("   pkd dir: ", system.file(package="redcas")),
             paste0("REDCODEDIR: ", Sys.getenv("REDCODEDIR")))
           )

source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping execution tests because neither redcsl nor redpsl was found.")
    q("no")
}

## redcas.test.batch only runs for the dialects which are present
res <- redcas.test.batch("data/150-asltx.red", 3)

print(save.results('redAsLtx', res[["expect"]], res[["actual"]]))

for (i in 1:length(res[["actual"]])) {
    al <- res[["actual"]][[i]]
    el <- res[["expect"]][[i]]
    if (length(el)!= length(al)) {
        writeLines(sprintf("i: %02d\t len(e): %d\t len(a): %d", i, length(el), length(al)))
    }
    writeLines(al, sprintf("data/150-asltx-actual-%03d.txt", i))
}

## don't save environment
q("no")
