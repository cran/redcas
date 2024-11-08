## $Id: 05-Exe.R,v 1.3 2024/10/19 13:34:59 mg Exp $
## Purpose: Tests for redStart, redClose, sessionRunning, connActive, redExec, redRead
## $Log: 05-Exe.R,v $
## Revision 1.3  2024/10/19 13:34:59  mg
## 1. changed log connection tests to obsolete
## 2. changed expected dim() of the session data frame (lcon is no longer present)
## 3. added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.2  2024/09/04 11:09:31  mg
## Some input files had been incorrectly numbered causing confusion when check. These have
## been adjusted and some typos fixed
##
## Revision 1.1  2024/03/05 15:42:55  mg
## replaces test-4-redEXEC
##
## Revision 1.1  2024/02/27 14:25:32  mg
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

expect <- list()
actual <- list()

## expectations
expect[[1]] <- FALSE    ## no sessions defined
expect[[2]] <- 1        ## start csl session s1
expect[[3]] <- TRUE     ## is pipe connection active
expect[[4]] <- "OBSOLETE"     ## is log connection active
expect[[5]] <- TRUE     ## is the session Running
expect[[6]] <- readLines("data/redEXEC-ex-006")     ## contents of log file less banner
expect[[7]] <- TRUE     ## close session s1
expect[[8]] <- 1        ## start csl session s2
expect[[9]] <- readLines("data/redEXEC-ex-009")         ## execute code block 1
expect[[10]] <- readLines("data/redEXEC-ex-010")        ## execute code block 2
expect[[11]] <- readLines("data/redEXEC-ex-011")        ## execute code block 3 output
expect[[12]] <- readLines("data/redEXEC-ex-012")        ## execute code block 3 commands
expect[[13]] <- "data.frame"  ## showSession() returns a data frame
expect[[14]] <- c(1, 6)       ## data frame has a single session (row)
expect[[15]] <- TRUE    ## close session s2
if (do.csl) {
    actual[[1]] <- showSessions()
    ## 001c: start a session using default csl
    actual[[2]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        ## 002 input connection is active
        actual[[3]] <- redcas:::connActive(redcas:::sessionGet(s1, 'pcon'))
        ## 003 output connection is active
        actual[[4]] <- "OBSOLETE"
        ## 004 session is running
        actual[[5]] <- redcas:::sessionRunning(s1)
        ## 006 read the log and compare: should contain mark_end_block definition. Drop
        ## first line as it contains the date
        logname <- redcas:::sessionGet(actual[[2]], 'logname')
        print(logname);print(s1)
        actual[[6]] <- readLines(logname)[-1]
        writeLines(actual[[6]])
        actual[[7]] <- redClose(actual[[2]], strftime(Sys.time(),"redExec-csl-s1-%Y%m%d-T-%H%M%S.log"))

        ## 
        actual[[8]] <- s2 <- redStart()
        if (s2 == 0) {
            writeLines("failed to start csl session 2. All further csl tests will be skipped.")
        } else {
            actual[[9]] <- redExec(s2, readLines("data/redEXEC-009.red"), split = FALSE)
            writeLines(actual[[9]], "data/redEXEC-actual-009.txt")
            actual[[10]] <- redExec(s2, readLines("data/redEXEC-010.red"), split = FALSE)
            writeLines(actual[[10]], "data/redEXEC-actual-010.txt")
            res11 <- redExec(s2, readLines("data/redEXEC-011-and-012.red"))
            actual[[11]] <- res11$out
            writeLines(actual[[11]], "data/redEXEC-actual-011.txt")
            actual[[12]] <- res11$cmd
            writeLines(actual[[12]], "data/redEXEC-actual-012.txt")
            s2.sess <- showSessions()   ## returns a data frame
            actual[[13]] <- class(s2.sess)
            actual[[14]] <- dim(s2.sess)
            actual[[15]] <- redClose(s2, strftime(Sys.time(),"redExec-csl-s2-%Y%m%d-T-%H%M%S.log"))
        }
   }
    
}

if (do.psl) {
    nexpect <- length(expect)
    for (i in 1:nexpect) {expect[[i+nexpect]] <- expect[[i]]}
    expect[[21]] <- readLines("data/redEXEC-ex-021")
    ## need to remove the "Running in" line as it references an arbitrary path 
    expect[[21]] <- expect[[21]][-which(grepl("^Running in ",expect[[21]]))]
    expect[[24]] <- readLines("data/redEXEC-ex-024")
    expect[[25]] <- readLines("data/redEXEC-ex-025")
    expect[[26]] <- readLines("data/redEXEC-ex-026")
    expect[[27]] <- readLines("data/redEXEC-ex-027")

    actual[[16]] <- showSessions()
    ## 001c: start a session using default csl
    actual[[17]] <- s1 <- redStart(dialect='psl')
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        ## 002 input connection is active
        actual[[18]] <- redcas:::connActive(redcas:::sessionGet(s1, 'pcon'))
        ## 003 output connection is active
        actual[[19]] <- "OBSOLETE"
        ## 004 session is running
        actual[[20]] <- redcas:::sessionRunning(s1)
        ## 006 read the log and compare: should contain mark_end_block definition. Drop
        ## first line as it contains the date
        logname <- redcas:::sessionGet(actual[[17]], 'logname')
        print(logname);print(s1)
        actual[[21]] <- readLines(logname)[-c(1,2)]
        ## need to remove the "Running in" line as it references an arbitrary path 
        actual[[21]] <- actual[[21]][-which(grepl("^Running in ",actual[[21]]))]
        writeLines(actual[[21]])
        actual[[22]] <- redClose(actual[[17]], strftime(Sys.time(),"redExec-psl-s1-%Y%m%d-T-%H%M%S.log"))

        ## 
        actual[[23]] <- s2 <- redStart(dialect='psl')
        if (s2 == 0) {
            writeLines("failed to start csl session 2. All further csl tests will be skipped.")
        } else {
            actual[[24]] <- redExec(s2, readLines("data/redEXEC-009.red"), split = FALSE)
            writeLines(actual[[24]], "data/redEXEC-actual-024.txt")
            actual[[25]] <- redExec(s2, readLines("data/redEXEC-010.red"), split = FALSE)
            writeLines(actual[[25]], "data/redEXEC-actual-025.txt")
            res25 <- redExec(s2, readLines("data/redEXEC-011-and-012.red"))
            actual[[26]] <- res25$out
            writeLines(actual[[26]], "data/redEXEC-actual-026.txt")
            actual[[27]] <- res25$cmd
            writeLines(actual[[27]], "data/redEXEC-actual-027.txt")
            s2.sess <- showSessions()   ## returns a data frame
            actual[[28]] <- class(s2.sess)
            actual[[29]] <- dim(s2.sess)
            actual[[30]] <- redClose(s2, strftime(Sys.time(),"redExec-psl-s2-%Y%m%d-T-%H%M%S.log"))
        }
   }

}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('red5Exe',expect,actual))

q("no")
