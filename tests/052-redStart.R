## $Id: 052-redStart.R,v 1.2 2024/10/19 13:37:41 mg Exp $
## Purpose: Additional tests for redStart
##          1. echo=FALSE returns only command line numbers
##          2. echo=TRUE returns command line numbers and commands

##    Note: these tests require reduce to be installed.
## $Log: 052-redStart.R,v $
## Revision 1.2  2024/10/19 13:37:41  mg
## removed spurious first element from expected values for tests 008 and 010
## added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.1  2024/09/04 11:14:00  mg
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
expect[[1]] <- 1        ## start REDUCE session s1
expect[[2]] <- c("OFF")
expect[[3]] <- c("5: ",  "6: ",  "7: ")
expect[[4]] <- c("z := x**2 + 2*x*y + y**2$", "2*(x + y)$", "2*(x + y)$")
expect[[5]] <- c("8: ",  "9: ",  "10: ", "11: ", "12: ", "13: ", "14: ")
expect[[6]] <- 1        ## start REDUCE session s2
expect[[7]] <- c("ON")
expect[[8]] <- c("6: write if swget(echo) then \"ON\" else \"OFF\" ;",
                 "7: ",
                 "8: ")
expect[[9]] <- c("z := x**2 + 2*x*y + y**2$", "2*(x + y)$", "2*(x + y)$")
expect[[10]] <- c("9: off nat;",
                  "10: z:=(x+y)**2;",
                  "11: df(z,x);",
                  "12: df(z,y);",
                  "13: on nat;",
                  "14: ",
                  "15: ")
    
## tests in a csl session
if (do.csl) {
    actual[[1]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {

        ## check the  ECHO setting using swget
        res <- redExec(s1, "write if swget(echo) then \"ON\" else \"OFF\" ;", drop.blank.lines=TRUE)
        actual[[2]] <- res[["out"]]
        actual[[3]] <- res[["cmd"]]

        ## check the out/cmd elements using several commands
        res <- redExec(s1, c("off nat;", "z:=(x+y)**2;", "df(z,x);", "df(z,y);", "on nat;"),
                       drop.blank.lines=TRUE)
        actual[[4]] <- res$out
        actual[[5]] <- res$cmd

        ## close s1
        redClose(s1, "data/052-redExe.clg")
    }
    actual[[6]] <- s1 <- redStart(echo=TRUE)
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {

        ## check the  ECHO setting using swget
        res <- redExec(s1, "write if swget(echo) then \"ON\" else \"OFF\" ;", drop.blank.lines=TRUE)
        actual[[7]] <- res[["out"]]
        actual[[8]] <- res[["cmd"]]

        ## check the out/cmd elements using several commands
        res <- redExec(s1, c("off nat;", "z:=(x+y)**2;", "df(z,x);", "df(z,y);", "on nat;"),
                       drop.blank.lines=TRUE)
        actual[[9]] <- res$out
        actual[[10]] <- res$cmd

        ## close s1
        redClose(s1, "data/052-redExe.clg")
    }
}

## tests in a psl session
if (do.psl) {
    lenexp <- length(expect)
    for (i in 1:lenexp) expect[[i+lenexp]] <- expect[[i]]
    actual[[11]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial psl session. All further psl tests will be skipped.")
    } else {

        ## check the  ECHO setting using swget
        res <- redExec(s1, "write if swget(echo) then \"ON\" else \"OFF\" ;", drop.blank.lines=TRUE)
        actual[[12]] <- res[["out"]]
        actual[[13]] <- res[["cmd"]]

        ## check the out/cmd elements using several commands
        res <- redExec(s1, c("off nat;", "z:=(x+y)**2;", "df(z,x);", "df(z,y);", "on nat;"),
                       drop.blank.lines=TRUE)
        actual[[14]] <- res$out
        actual[[15]] <- res$cmd

        ## close s1
        redClose(s1, "data/052-redExe.clg")
    }
    actual[[16]] <- s1 <- redStart(echo=TRUE)
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {

        ## check the  ECHO setting using swget
        res <- redExec(s1, "write if swget(echo) then \"ON\" else \"OFF\" ;", drop.blank.lines=TRUE)
        actual[[17]] <- res[["out"]]
        actual[[18]] <- res[["cmd"]]

        ## check the out/cmd elements using several commands
        res <- redExec(s1, c("off nat;", "z:=(x+y)**2;", "df(z,x);", "df(z,y);", "on nat;"),
                       drop.blank.lines=TRUE)
        actual[[19]] <- res$out
        actual[[20]] <- res$cmd

        ## close s1
        redClose(s1, "data/052-redExe.clg")
    }
}

## check lengths
aelen(what=c("out", "cmd"))
      
print(save.results('redStart',expect,actual))
## don't save environment
q("no")
