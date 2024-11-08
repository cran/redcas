## $Id: 01-GetExe.R,v 1.3 2024/10/19 13:14:08 mg Exp $
## Purpose: Tests for functions getReduceExec in envir.R
## $Log: 01-GetExe.R,v $
## Revision 1.3  2024/10/19 13:14:08  mg
## 1. added normalizePath to expected values
## 2. in comments replace redcas_exec with reduce_exec (upper and lower)
## 3. save value of REDUCE_EXEC before relevant tests and restore afterwards
## 4. added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.2  2024/10/05 15:12:44  mg
## Moved to inst
##
## Revision 1.1  2024/03/05 15:41:19  mg
## replaces test-1-getReduceExec
##
## Revision 1.1  2024/02/27 14:25:32  mg
## Initial version
##

## TODO:
##    1: replace source with library(redcas)
##    2: possibly replace the dummy bin path
##    3: convert to testthat or some other test suite? run in batch stop will kill the tests...
library(redcas)
source("data/test-utils.R")

result <- vector()
expect <- vector("character")
actual <- vector("character")

## 001: dialect is missing
expect[1] <- "argument dialect is required."
actual[1] <- capture.output(redcas:::getReduceExec(), type="message")
result[1] <- expect[1] == actual[1]

## NOTE ##
## version with writing to file is in /home/mg/R/pkg.user.install

## 002: dialect invalid
expect[2] <- "argument 'dialect' must be 'csl' or 'psl'."
actual[2] <- sub("^ +", "",
                 capture.output(redcas:::getReduceExec('qsl'), type="message"))
result[2] <- expect[2] == actual[2]

## 003: dir supplied and dir/redcsl exists
expect[3] <- normalizePath("bin/redcsl")
actual[3] <- redcas:::getReduceExec('csl', 'bin')
result[3] <- expect[3] == actual[3]

## 004: dir supplied and dir/redcsl does not exist
expect[4] <- "tests-redcas/redcsl does not exist."
actual[4] <- sub("^ +", "",
                 capture.output(redcas:::getReduceExec('csl', 'tests-redcas'), type="message"))
result[4] <- expect[4] == actual[4]

## 005: dir supplied and dir/redpsl exists
expect[5] <- normalizePath("bin/redpsl")
actual[5] <- redcas:::getReduceExec('psl', 'bin')
result[5] <- expect[5] == actual[5]

## 006: dir supplied and dir/redpsl does not exist
expect[6] <- "tests-redcas/redpsl does not exist."
actual[6] <- sub("^ +", "",
                 capture.output(redcas:::getReduceExec('psl', 'tests-redcas'), type="message"))
result[6] <- expect[6] == actual[6]

## 007: no dir, env REDUCE_EXEC, opt reduce_exec, Sys.which missing must first remove
## /usr/local/bin and any directory with "reduce" in the name from PATH as they are likely
## to contain red[cp]sl. Must also remove REDUCE_EXEC but save so we can restore
env.path <- unlist(strsplit(Sys.getenv("PATH"), ":"))
no.path <- paste0(env.path[-grep("(/reduce|/usr/local/bin)", env.path)], collapse=":")
Sys.setenv(PATH=no.path)
reduce_exec.env <- Sys.getenv("REDUCE_EXEC")
if (reduce_exec.env != "") Sys.setenv(REDUCE_EXEC="REDUCE_EXEC")
expect[7] <- "no reduce executable found for dialect csl"
actual[7] <- sub("^ +", "", 
                 capture.output(redcas:::getReduceExec('csl'), type="message"))
result[7] <- expect[7] == actual[7]

## 008: no dir, env REDUCE_EXEC, opt reduce_exec  missing, Sys.which finds redcsl
Sys.setenv("PATH"=paste0(Sys.getenv("PATH"), ":", normalizePath("bin")))
#Sys.getenv("PATH")
expect[8] <- normalizePath("bin/redcsl")
actual[8] <- redcas:::getReduceExec('csl')
result[8] <- expect[8] == actual[8]
## remove dummy bin from current PATH otherwise 10 will fail
Sys.setenv("PATH"=sub(paste0(":", normalizePath("bin")),"", Sys.getenv("PATH")))

## 009: no dir, env REDUCE_EXEC missing, opt reduce_exec set, Sys.which does not find redcsl
options(reduce_exec=normalizePath("bin"))
getOption("reduce_exec")
expect[9] <- normalizePath("bin/redcsl")
actual[9] <- redcas:::getReduceExec('csl')
result[9] <- expect[9] == actual[9]

## 010: no dir, env REDUCE_EXEC missing, opt reduce_exec is "", Sys.which does not find redcsl
options(reduce_exec="")
getOption("reduce_exec")
expect[10] <- "no reduce executable found for dialect csl"
actual[10] <- sub("^ +", "", 
                  capture.output(redcas:::getReduceExec('csl'), type="message"))
result[10] <- expect[10] == actual[10]

## 011: no dir, env REDUCE_EXEC set, opt reduce_exec set "", Sys.which does not find redcsl
Sys.setenv("REDUCE_EXEC"=normalizePath("bin"))
Sys.getenv("REDUCE_EXEC")
expect[11] <- normalizePath("bin/redcsl")
actual[11] <- redcas:::getReduceExec('csl')
result[11] <- expect[11] == actual[11]
## restore PATH and REDUCE_EXEC
Sys.setenv(PATH=paste0(env.path, collapse=":"))
Sys.setenv("REDUCE_EXEC"=reduce_exec.env)

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('red1GetExe',expect,actual))
## ensure next R session has an empty .redcas.env
q("no")
