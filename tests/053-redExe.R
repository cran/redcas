## $Id: 053-redExe.R,v 1.2 2024/10/19 13:23:27 mg Exp $
## Purpose: Test fix to prevent hanging, essentially check.terminator function
##          1. unit tests which do not require reduce
##          2. same tests for CSL
##          3. same tests for PSL
##    Note: these tests require reduce to be installed.
## $Log: 053-redExe.R,v $
## Revision 1.2  2024/10/19 13:23:27  mg
## added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/03 16:54:28  mg
## Initial version
##

## the current library is needed as well as the new functions
library(redcas)

source("data/test-utils.R")

expect <- list()
actual <- list()

cmds <- list(
    c("h1:=x+y;",    "h2:=2*h1;", "h3:=h2^2$",   "write h3"),     ## fourth has no term
    c("g1:=x+y;",    "g2:=2*g1;", "g3:=g2^2$",   "xomment;"),     ## invalid termed stmt
    c("% a comment", " ",         " % comment ;"),                ## blank or comment only
    c("j1:=x+y;",    "j2:=2*j1;", "j3:=j2^2",    " %% comment"),  ## last is comment, 3rd no term
    c("k1:=x+y;",    "k2:=2*k1;", "k3:=k2^2$",   "write h3; % comment;") ## ok, trailing comment
)
## expectations Unit tests. Odd numbered are captures (0 == empty), even return
expect[[1]] <- readLines("data/053-expect-001.txt")
expect[[2]] <- FALSE
expect[[3]] <- 0
expect[[4]] <- TRUE
expect[[5]] <- readLines("data/053-expect-005.txt")
expect[[6]] <- TRUE
expect[[7]] <- readLines("data/053-expect-007.txt")
expect[[8]] <- FALSE
expect[[9]] <- 0
expect[[10]] <- TRUE

## Unit tests do not require REDUCE
## TODO: actual[[1]] <- capture.output(actual[[2]] <- check.terminator(cmds[[1]]), type="message")
for (i in seq(1,10,2)) {
    actual[[i]] <- capture.output(actual[[i+1]] <- redcas:::check.terminator(cmds[[(i+1)/2]]),
                                  type="message")
    if (length(actual[[i]]) == 0) actual[[i]] <- 0
}
all.equal(expect, actual)

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping execution tests because neither redcsl nor redpsl was found.")
    q("no")
}

## CSL
if (do.csl) {
    ## start the session
    s1 <- redStart(echo=TRUE)
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        ## expectations redExec CSL. Odd numbered are captures (0 == no capture), even return
        expect[[11]] <- expect[[1]]
        expect[[12]] <- FALSE
        expect[[13]] <- 0
        expect[[14]] <- readLines("data/053-expect-014.out")
        expect[[15]] <- expect[[5]]
        expect[[16]] <- readLines("data/053-expect-016.out")
        expect[[17]] <- expect[[7]]
        expect[[18]] <- FALSE
        expect[[19]] <- 0
        expect[[20]] <- readLines("data/053-expect-020.out")

        for (i in seq(1,10,2)) {
            ## writeLines(c(sprintf("finder: i: %d; (i+1)/2: %d", i, (i+1)/2),cmds[[(i+1)/2]]))
            actual[[i+10]] <- capture.output(res <- redExec(s1, cmds[[(i+1)/2]]),
                                             type="message")
            if (length(actual[[i+10]]) == 0) actual[[i+10]] <- 0
            if (class(res) == 'list') { actual[[i+11]] <- res$out
                } else { actual[[i+11]] <- res }
      }

        redClose(s1, "data/053-redExe.clg")
    }

}

## PSL
if (do.psl) {
    ## start the session
    s2 <- redStart(dialect="psl", echo=TRUE)
    if (s2 == 0) {
        writeLines("failed to start initial psl session. All further csl tests will be skipped.")
    } else {
        ## expectations redExec PSL are the same as for CSL
        for (i in 11:20) expect[[i+10]] <- expect[[i]]
        for (i in seq(1,10,2)) {
            ## writeLines(c(sprintf("finder: i: %d; (i+1)/2: %d", i, (i+1)/2),cmds[[(i+1)/2]]))
            actual[[i+20]] <- capture.output(res <- redExec(s2, cmds[[(i+1)/2]]),
                                             type="message")
            if (length(actual[[i+20]]) == 0) actual[[i+20]] <- 0
            if (class(res) == 'list') { actual[[i+21]] <- res$out
            } else { actual[[i+21]] <- res }
            ## writeLines(c(sprintf("FIND: i: %d; (i+1)/2: %d", i+20, (i+1)/2),
            ##              "cmds:", cmds[[(i+1)/2]],
            ##              "res:", res$out,
            ##              sprintf("FIND: i: %d; ", i+21), actual[[i+21]]))
            ## print(actual[[i+20]])
            ## print(actual[[i+21]])
                  
        }
        

        redClose(s2, "data/053-redExe.plg")
    }

}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redExeChkTerm',expect,actual))
## don't save environment
q("no")
