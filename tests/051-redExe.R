## $Id: 051-redExe.R,v 1.2 2024/10/19 13:23:27 mg Exp $
## Purpose: show that:
##          1. prefixed ";" no longer appears in output
##          2. combined command number and first line of fancy output is correctly handled
##    Note: these tests require reduce to be installed.
## $Log: 051-redExe.R,v $
## Revision 1.2  2024/10/19 13:23:27  mg
## added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/04 11:12:15  mg
## initial version
##

## the current library is needed as well as the new functions
library(redcas)

source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping execution tests because neither redcsl nor redpsl was found.")
    q("no")
}

expect <- list()
actual <- list()

## expectations
expect[[1]] <- 1        ## start csl session s1
expect[[2]] <- readLines("data/051-expect-002.txt")
expect[[3]] <- readLines("data/051-expect-003.txt")
expect[[4]] <- readLines("data/051-expect-004.txt")
expect[[5]] <- readLines("data/051-expect-005.txt")
expect[[6]] <- readLines("data/051-expect-006.txt")
expect[[7]] <- readLines("data/051-expect-007.txt")
expect[[8]] <- readLines("data/051-expect-008.txt")
    
## define my user map
my.map <- list(
    index=c('g' = '__',
            'x' = '^')
)

## start the session
if (do.csl) {
    actual[[1]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {

        ## turn NERO on, ECHO off and call the test program which does the calculations
        calc <- redExec(s1, c("off echo;", "on nero;", "file:data/122-arrayltx-input.red"))
        ## show(calc, "out")

        ## 002 echo off and call arrayltx for the metric tensor
        o2echo.off <- redExec(s1, "arrayltx(g, \"\", \"\");")
        ## show(o2echo.off, c("raw", "out"))
        actual[[2]] <- o2echo.off[["out"]]

        ## 003 echo off and call arrayltx for the metric tensor, now with fancy on
        o3echo.off <- redExec(s1, "arrayltx(g, \"dmath\", \"fancy\");")
        ## show(o4echo.off, c("raw", "out", "cmd"))
        actual[[3]] <- o3echo.off[["out"]]
        
        ## echo off and call asltx for the metric tensor
        o4echo.off <- asltx(s1, "g", mathenv="dmath", usermap=my.map)
        ## show(o4echo.off, c("raw", "out", "tex", "cmd"))
        actual[[4]] <- o4echo.off[["tex"]]
        writeLines(actual[[4]], "data/051-actual-004.txt")

        ## turn echo on
        toggle.echo <- redExec(s1, c("on echo;","swget(echo);"))
        show(toggle.echo, "out")
        actual[[5]] <- toggle.echo[["out"]]

        ## echo on and call arrayltx for the metric tensor
        o6echo.on <- redExec(s1, "arrayltx(g, \"\", \"\");")
        ## show(o6echo.on, c("raw", "out"))
        actual[[6]] <- o6echo.on[["out"]]

        ## echo on and call arrayltx for the metric tensor, now with fancy on
        o7echo.on <- redExec(s1, "arrayltx(g, \"dmath\", \"fancy\");")
        ## show(o7echo.on, c("raw", "out", "cmd"))
        actual[[7]] <- o7echo.on[["out"]]

        ## echo on and call asltx for the metric tensor
        o8echo.on <- asltx(s1, "g", mathenv="dmath", usermap=my.map)
        ## show(o8echo.on, c("raw", "out", "tex", "cmd"))
        actual[[8]] <- o8echo.on[["tex"]]
        writeLines(actual[[8]], "data/051-actual-008.txt")

        redClose(s1, "data/051-redExe.clg")
    }

}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redExeSemiC',expect,actual))
## don't save environment
q("no")
