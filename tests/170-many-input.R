## $Id: 170-many-input.R,v 1.2 2024/10/19 13:48:31 mg Exp $
## Purpose: check if more that 5 calls to redExec causes redRead to go into infinite loop
## $Log: 170-many-input.R,v $
## Revision 1.2  2024/10/19 13:48:31  mg
## 1. streamlined creation of expected values and ensured that, if only one of csl,psl is
##    present, expect and actual have only the expected and actual values for the present
##    executable
## 2. in execution loop, changed break to next to ensure second set of tests, if any, are
##    executed.
## 3. added aelen function to compare lengths of expect and actual and their elements
## 4. improved method of identifying the redcascodepath lines to remove from actual (these
##    depend on where redcas is installed)
##
## Revision 1.1  2024/09/04 11:36:12  mg
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
for (i in c(2:8)) exptmpl[[i]] <- readLines(paste0("data/170-expect-", sprintf("%03d", i),".txt"))

## Note: we assign expect only if the corresponding tests are executed, i.e. in the loop below
expect <- list()
actual <- list()

for (dial in c("csl", "psl")) {
    if (dial == "csl") {if (!do.csl) {next} else {idx <- 1}}
    else {if (!do.psl) {next} else {idx <- 9}}
    writeLines(paste0("dialect: ", dial, "  idx: ", idx))
    ## start the session
    expect[[idx]] <- exptmpl[[1]]
    actual[[idx]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines(paste0("failed to start ", dial, " session\n. All further ", dial,
                          " tests will be skipped."))
    } else {
        ## populate expect for this dialect
        expect <- c(expect, exptmpl[2:8])

        ## turn on ECHO
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, c("on echo;", "swget(echo);"), split=TRUE)[["out"]]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        ## call the test program which does the calculations
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, "file:data/122-arrayltx-input.red")[["out"]]
        ## remove the redcascodepath from the output as it depends on where redcas is
        ## installed. This can span multiple lines so remove up to the line preceeding
        ## "lisp_dialect"
        rcp.line <- 1:(grep("^lisp_dialect$", actual[[idx]])-1)
        actual[[idx]] <- actual[[idx]][-rcp.line]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        ## turn on NERO
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, c("on nero;","swget(nero);"), split=TRUE)[["out"]]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        ## use arrayltx to print metric tensor
        idx <- idx + 1
        actual[[idx]] <- redExec(s1, "arrayltx(g, \"\", \"\");")[["out"]]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        ## use a loop to print metric tensor
        idx <- idx + 1
        x <- c("off nero;", "write \"NERO: \", lisp(!*nero);",
               readLines("data/171-many-input.red"))
        ## print(x) ;
        actual[[idx]] <- redExec(s1, x, split=TRUE)[["out"]]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        ## create LaTeX output of metric tensor
        idx <- idx + 1
        x <- c("on nero;", "write \"NERO: \", lisp(!*nero);",
               "arrayltx(g, \"\", \"\");")
        actual[[idx]] <- redExec(s1, x, split=TRUE)[["out"]]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        ## use a loop to print diagonal of cs1
        idx <- idx + 1; writeLines(paste0("last idx: ", idx))
        x <- c("off nero;", "write \"NERO: \", lisp(!*nero);", 
               "for i:=0:3 do write \"mt(\", i, \",\", i, \",\", i, \")=\", cs1(i,i,i);")
        actual[[idx]] <- redExec(s1, x, split=TRUE)[["out"]]
        writeLines(actual[[idx]], paste0("data/170-actual-", sprintf("%03d", idx),".txt"))

        redClose(s1, paste0("170-many-input.", substring(dial, 1, 1), "lg"))
    }
}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redMany',expect,actual))
## don't save environment
q("no")
