## $Id: 160-asltx.R,v 1.2 2024/10/19 13:46:36 mg Exp $
## Purpose: test functions in redcasltx.R
## $Log: 160-asltx.R,v $
## Revision 1.2  2024/10/19 13:46:36  mg
## 1. streamlined creation of expected values and ensured that, if only one of csl,psl is
##    present, expect and actual have only the expected and actual values for the present
##    executable
## 2. in execution loop, changed break to next to ensure second set of tests, if any, are
##    executed.
## 3. added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/04 11:33:20  mg
## initial version
##

## the current library is needed as well as the new functions
library(redcas)
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

exptmpl <- list()
exptmpl[[1]] <- 1        ## start session s1
for (i in c(2:9)) exptmpl[[i]] <- readLines(paste0("data/160-expect-", sprintf("%03d", i),".tex"))

## Note: we assign expect only if the corresponding tests are executed, i.e. in the loop below
expect <- list()
actual <- list()

## define my user map
my.map <- list(
    ident=c(
        'cs1'='\\\\Gamma',  ## Christoffel symbol first kind
        'x' = 'x',           ## coordinates
        'g'='g',           ## metric tensor
        'kplus'='K^+',       ## exterior second form (K+)
        'kminus'='K^-',       ## interior second form (K-)
        's'='\\\\Sigma'    ## surface energy tensor
    ),
    index=c(
        '\\\\Gamma' = '__^',
        'x' = '_',
        'g' = '__',
        'K\\^\\+' = '__',
        'K\\^-' = '__',
        '\\\\Sigma' = '_^'
    )
)

## define list of reduce objects to render
redobj <- c("g", "echo", "g", "cs1", "kplus", "xe", "ye", "ze")
for (dial in c("csl", "psl")) {
    if (dial == "csl") {if (!do.csl) {next} else {idx <- 1}}
    else {if (!do.psl) {next} else {idx <- 10}}
    writeLines(paste0("dialect: ", dial, "  idx: ", idx))
    ## start the session
    expect[[idx]] <- exptmpl[[1]]
    actual[[idx]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        ## populate expect for this dialect
        expect <- c(expect, exptmpl[2:9])
        
        ## call the test program which does the calculations
        ## turn NERO on, ECHO off and call the test program which does the calculations
        def.array <- redExec(s1, c("off echo;", "on nero;", "file:data/122-arrayltx-input.red"))
        ## show(calc, "out")
        def.expr <- redExec(s1, c("file:data/132-expr-input.red"))

        for (i in 1:length(redobj)) {
            idx <- idx + 1
            if (redobj[i] != "echo") {
                
                ## create output
                actual[[idx]] <- asltx(s1, redobj[i], usermap=my.map, mathenv="dmath")[["tex"]]
                writeLines(actual[[idx]], paste0("data/160-actual-", sprintf("%03d", idx),".tex"))
            } else {
                ## turn on ECHO
                actual[[idx]] <- redExec(s1, c("on echo;","swget(echo);"))[["out"]]
                writeLines(actual[[idx]], paste0("data/160-actual-", sprintf("%03d", idx),".tex"))
            }
        }
    }
    redClose(s1, paste0("160-asltx.", substr(dial, 1, 1), "lg"))
}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redAsLtxR',expect,actual))
## don't save environment
q("no")
