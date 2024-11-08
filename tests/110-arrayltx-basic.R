## $Id: 110-arrayltx-basic.R,v 1.2 2024/10/19 13:40:08 mg Exp $

## Purpose: Execute 110-array-basic.red for both CSL and PSL and compare results to expected

## $Log: 110-arrayltx-basic.R,v $
## Revision 1.2  2024/10/19 13:40:08  mg
## 1. added --nogui option for csl
## 2. added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/04 11:22:56  mg
## initial version
##
library(redcas)
writeLines(c(paste0("redCodeDir: ", redCodeDir()),
             paste0("   pkd dir: ", system.file(package="redcas")),
             paste0("REDCODEDIR: ", Sys.getenv("REDCODEDIR")))
           )
sessionInfo()
           
source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcsl <- redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redpsl <- redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping execution tests because neither redcsl nor redpsl was found.")
    q("no")
}

tests <- c("tm01", "tma", "tmb", "tmc", "tmd", "tme", "tmf", "tmg", "tmh", "tmi", "tmj")
ntests <- length(tests)
expect <- list()
actual <- list()

if (do.csl) {
    cslopt <- "--nogui"         ## needed for Darwin, no harm for Linux
    csl.rc <- system2(redcsl, args=cslopt, stdin="data/110-arrayltx-basic.red",
                      stdout="data/110-arrayltx-basic.clg",
                      stderr="data/110-arrayltx-basic.clg")
    if (csl.rc != 0) {
        writeLines(paste0("CSL execution returned ", csl.rc,
                          "\nAll further csl tests will be skipped."))
    } else {
        for (i in 1:ntests) {
            expect[[i]] <- readLines(paste0("data/110-", tests[i], "-expect.txt"))
            actual[[i]] <- readLines(paste0("data/110-", tests[i], "-actual-csl.txt"))
        }
    }

}

if (do.psl) {
    psl.rc <- system2(redpsl, stdin="data/110-arrayltx-basic.red",
                      stdout="data/110-arrayltx-basic.plg",
                      stderr="data/110-arrayltx-basic.plg")
    if (psl.rc != 0) {
        writeLines(paste0("PSL execution returned ", psl.rc,
                          "All further psl tests will be skipped."))
    } else {
        for (i in 1:ntests) {
            j <- i+ntests
            expect[[j]] <- readLines(paste0("data/110-", tests[i], "-expect.txt"))
            actual[[j]] <- readLines(paste0("data/110-", tests[i], "-actual-psl.txt"))
        }
    }

}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redArrayBasic',expect,actual))
q("no")
