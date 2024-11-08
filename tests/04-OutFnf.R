## $Id: 04-OutFnf.R,v 1.4 2024/11/04 16:12:33 mg Exp $
## Purpose: Test redExpand handles missing input file correctly
## $Log: 04-OutFnf.R,v $
## Revision 1.4  2024/11/04 16:12:33  mg
## 1. replace CSL version number and build date with XXXX and dd-Mon-yyyy, respectively
## 2. use the new data/redOut-ex-Fnf-6 as expected result for PSL (CSL and PSL log headers
##    differ)
## 3. replace PSL version number and build date with XXXX and dd-Mon-yyyy, respectively
##
## Revision 1.3  2024/10/19 13:23:26  mg
## added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.2  2024/10/05 15:12:44  mg
## Moved to inst
##
## Revision 1.1  2024/03/05 15:43:20  mg
## Initial version
##
library(redcas)
source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping execution tests because neither redcsl nor redpsl was found.")
    q("no")
}

commands <- c(
    "operator a, b, c, d ;",
    "let c^2=a^2+b^2 ;",
    "let d=a*b/2 ;",
    "q1:=y^2 - x^3 + d^2*x ;",
    "solve(y^2=x^3 - d^2*x, {x,y}) ;",
    "file:redOut.fnf.not.there",
    "j:=sqrt(k^2 + l^2) ;"
)

expect <- list()
actual <- list()

expect[[1]] <- 1
expect[[2]] <- FALSE
expect[[3]] <- readLines("data/redOut-ex-Fnf-3")    ## message from redRead

## CSL
if (do.csl) {
    ## start the session
    actual[[1]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        msg <- capture.output(actual[[2]] <- redExec(s1, commands, split=FALSE), type="message")
        ## replace version number and build date
        msg <- sub("rev [0-9]+), .*$", "rev XXXX), dd-Mon-yyyy ...", msg)
        actual[[3]] <- msg
    }
}

## PSL
if (do.psl) {
    lexp <- length(expect)
    for (i in 1:lexp) expect[[i+lexp]] <- expect[[i]]
    expect[[6]] <- readLines("data/redOut-ex-Fnf-6")
    ## start the session
    actual[[4]] <- s1 <- redStart(dialect="psl")
    if (s1 == 0) {
        writeLines("failed to start initial psl session. All further psl tests will be skipped.")
    } else {
        msg <- capture.output(actual[[5]] <- redExec(s1, commands, split=FALSE), type="message")
        ## replace version number and build date
        msg <- sub("revision [0-9]+), .*$", "revision XXXX), build date dd-Mon-yyyy ...", msg)
        ## remove lines with variable paths
        msg <- msg[-grep("^(Loading image file:|Running in)", msg)]
        actual[[6]] <- msg
    }
}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('red4OutFnf',expect,actual))
## don't save environment
q("no")
