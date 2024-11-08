## $Id: 180-num-and-out.R,v 1.2 2024/10/19 13:46:36 mg Exp $
## Purpose: check if the bug in redSplitOut: off echo produces line with
##             "^[0-9]+: output..."
##           when called for non-LaTeX output.
## $Log: 180-num-and-out.R,v $
## Revision 1.2  2024/10/19 13:46:36  mg
## 1. streamlined creation of expected values and ensured that, if only one of csl,psl is
##    present, expect and actual have only the expected and actual values for the present
##    executable
## 2. in execution loop, changed break to next to ensure second set of tests, if any, are
##    executed.
## 3. added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/04 11:40:13  mg
## initial version
##

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
exptmpl[[1]] <- 1       ## start session s1
for (i in c(2:7)) exptmpl[[i]] <- readLines(paste0("data/180-expect-", sprintf("%03d", i),".txt"))

## Note: we assign expect only if the corresponding tests are executed, i.e. in the loop below
expect <- list()
actual <- list()

for (dial in c("csl", "psl")) {
    if (dial == "csl") {if (!do.csl) {next} else {idx <- 1}}
    else {if (!do.psl) {next} else {idx <- 8}}
    writeLines(paste0("dialect: ", dial, "  idx: ", idx))
    ## start the session
    expect[[idx]] <- exptmpl[[1]]
    actual[[idx]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines(paste0("failed to start ", dial, " session\n. All further ", dial,
                          " tests will be skipped."))
    } else {
        ## populate expect for this dialect
        expect <- c(expect, exptmpl[2:7])

        ## show linelength (the declare op d_block comes from an LF in submit_end_block
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, c("on echo;",
                                       "lisp linelength nil ;",
                                       "lisp linelength 30000 ;",
                                       "lisp linelength nil ;"))[["out"]]
        writeLines(actual[[idx]], paste0("data/180-actual-", sprintf("%03d", idx),".txt"))

        ## call the test program which does the calculations
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, "file:data/122-arrayltx-input.red")[["out"]]
        ## remove the redcascodepath from the output as it depends on where redcas is
        ## installed. furthermore, if the path may be on the second line following the
        ## "redcascodepath := " if it is too long
        rcp.line <- which(grepl("^redcascodepath := ",actual[[idx]]))
        if (actual[[idx]][rcp.line] == "redcascodepath := ") {
            rcp.line <- rcp.line:(rcp.line + 2)
        }
        actual[[idx]] <- actual[[idx]][-rcp.line]
        writeLines(actual[[idx]], paste0("data/180-actual-", sprintf("%03d", idx),".txt"))
        
        ## turn on NERO
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, "on nero;")[["out"]]
        writeLines(actual[[idx]], paste0("data/180-actual-", sprintf("%03d", idx),".txt"))
        
        ## create Non-LaTeX output of metric tensor
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, "arrayltx(g, \"\", \"\");")[["out"]]
        writeLines(actual[[idx]], paste0("data/180-actual-", sprintf("%03d", idx),".txt"))
        
        ## check ECHO setting
        idx <- idx + 1
        actual[[idx]] <- redExec(s1,
                                 c("write \"ECHO: \", lisp(!*echo);",
                                   "if lisp(!*echo) then <<write \"turning echo off\";off echo>>",
                                   "else <<write \"turning echo on\";on echo>>;"
                                   ))[["out"]]
        writeLines(actual[[idx]], paste0("data/180-actual-", sprintf("%03d", idx),".txt"))
        
        ## create Non-LaTeX output of metric tensor
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, "arrayltx(g, \"\", \"\");")[["out"]]
        writeLines(actual[[idx]], paste0("data/180-actual-", sprintf("%03d", idx),".txt"))
        
        redClose(s1, paste0("180-num-and-out.", substr(dial, 1, 1), "lg"))
    }
}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redNumOut',expect,actual))

## don't save environment
q("no")
