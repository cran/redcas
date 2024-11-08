## $Id: 07-redExeLong.R,v 1.4 2024/11/04 11:54:26 mg Exp $

## Purpose: Long-running test to check notification. 

## $Log: 07-redExeLong.R,v $
## Revision 1.4  2024/11/04 11:54:26  mg
## add type="message" to capture.output as all diagnostic messages now use message
##
## Revision 1.3  2024/10/05 15:12:44  mg
## Moved to inst
##
## Revision 1.2  2024/09/04 11:20:04  mg
## Added a test for the timeout parameter
##

library(redcas)
source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
if (do.csl == FALSE) {
    writeLines("Skipping execution tests because redcsl was not found.")
    q("no")
}

cmd <- readLines("data/07-lastprime.red")

if (do.csl) {
    ## start the session
    s1 <- redStart()

    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        ## Because the test will run on different hardware, we first have to determine how long
        ## the test program takes as otherwise we might not have a notification. So we want
        ## notify=elapsed/3 iterations to get at least one message Additionally we test that no
        ## message is written and that timeout works
        elapsed <- system.time(msg1 <- capture.output(out1 <- redExec(s1, cmd, notify=0),
                                                      type="message"))[3]
        notify.n <- round(elapsed/3, 0)
        writeLines(c(paste0("Factorize took: ", elapsed, " seconds"),
                     paste0("  length(msg1): ", length(msg1)),
                     paste0("  Using notify: ", notify.n)))

        ## now test with notification
        msg2 <- capture.output(out2 <- redExec(s1, cmd, notify=notify.n), type="message")
        writeLines(msg2)

        ## test with timeout
        msg3 <- capture.output(out3 <- redExec(s1, cmd, notify=round(elapsed/4,0), timeout=5),
                               type="message")
        writeLines(msg3)

        redClose(s1, strftime(Sys.time(),"test-7-%Y%m%d-T-%H%M%S.log"))

        writeLines(out2$out[which(grepl("^10E", out2$out))])

        expect <- c(TRUE, TRUE, TRUE)
        actual <- c(length(msg1) == 0, length(msg2)>0, grepl("^redRead: stopping loop", msg3))
    }
}

print(save.results('red7ExeLong',expect,actual))
## don't save environment
q("no")
