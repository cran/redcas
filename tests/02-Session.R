## $Id: 02-Session.R,v 1.2 2024/10/19 13:19:16 mg Exp $
## Purpose: tests for sessionAdd, sessionGet, sessionSet, sessionExists
## $Log: 02-Session.R,v $
## Revision 1.2  2024/10/19 13:19:16  mg
## changed log connection tests to obsolete
##
## Revision 1.1  2024/03/05 15:41:39  mg
## replaces test-2-session
##
## Revision 1.1  2024/02/27 14:25:32  mg
## Initial version
##
library(redcas)
source("data/test-utils.R")

expect <- vector("character")
actual <- vector("character")

## 001 Add a session and check values set as expected
expect[1] <- "1"
## need a connections but can be file connection as we don't do any io
pcon1 <- file("data/session-dummy-pipe1", open="r")
actual[1] <- redcas:::sessionAdd("/usr/local/bin/redcsl", "~/tmp/mys1.log", pcon1)
print(redcas:::.redcas.env[["session"]])
expect[2] <- "3"
actual[2] <- p1 <- redcas:::sessionGet(1, 'pcon')
expect[3] <- "OBSOLETE"
actual[3] <- "OBSOLETE"
expect[4] <- "~/tmp/mys1.log"
actual[4] <- redcas:::sessionGet(1, 'logname')
expect[5] <- "/usr/local/bin/redcsl"
actual[5] <- redcas:::sessionGet(1, 'cmd')

expect[6] <- "2"
pcon2 <- file("data/session-dummy-pipe2", open="r")
actual[6] <- redcas:::sessionAdd("/usr/local/bin/redpsl", "~/tmp/mys2.log", pcon2)
print(redcas:::.redcas.env[["session"]])
expect[7] <- "4"
actual[7] <- p2 <- redcas:::sessionGet(2, 'pcon')
expect[8] <- "OBSOLETE"
actual[8] <- "OBSOLETE"
expect[9] <- "~/tmp/mys2.log"
actual[9] <- redcas:::sessionGet(2, 'logname')
expect[10] <- "/usr/local/bin/redpsl"
actual[10] <- redcas:::sessionGet(2, 'cmd')
      
## sessionGet: Non-existent session: 3
expect[11] <- FALSE
actual[11] <- redcas:::sessionGet(3, 'logname')

## sessionGet: 'what' must be one of pcon lcon cmd logname
expect[12] <- FALSE
actual[12] <- redcas:::sessionGet(2, 'gname')

## sessionExists: non-existent session
expect[13] <- 0
actual[13] <- redcas:::sessionExists(0)
## sessionExists: existent session
expect[14] <- 1
actual[14] <- redcas:::sessionExists(1)

## sessionSet
expect[15] <- "1"
actual[15] <- redcas:::sessionSet(1, 'blockn', 1)
expect[16] <- "8"
actual[16] <- redcas:::sessionSet(2, 'lines.read', 8)
expect[17] <- "12"
actual[17] <- redcas:::sessionSet(1, 'lines.read', 12)

for (conn in c(pcon1, pcon2)) {close(getConnection(conn))}

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('red2Session',expect,actual))

## ensure next R session has an empty .redcas.env

q("no")
