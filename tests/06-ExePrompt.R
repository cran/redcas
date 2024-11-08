## $Id: 06-ExePrompt.R,v 1.4 2024/11/04 16:13:32 mg Exp $
## Purpose: Test redExec on reduce program with undeclared operator
## $Log: 06-ExePrompt.R,v $
## Revision 1.4  2024/11/04 16:13:32  mg
## replace CSL version number and build date with XXXX and dd-Mon-yyyy, respectively
##
## Revision 1.3  2024/10/05 15:12:44  mg
## Moved to inst
##
## Revision 1.2  2024/09/04 11:15:28  mg
## Added code to check that the length of individual expected items matches the actual
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
    "j:=sqrt(k(2)^2 + l^2) ;")

expect <- list()
actual <- list()

expect[[1]] <- 1
expect[[2]] <- FALSE
expect[[3]] <- readLines("data/redExec-ex-prompt-3")    ## message from redRead

if (do.csl) {
    ## start the session
    actual[[1]] <- s1 <- redStart()
    if (s1 == 0) {
        writeLines("failed to start initial csl session. All further csl tests will be skipped.")
    } else {
        msg <- capture.output(actual[[2]] <- redExec(s1, commands, split=FALSE), type="message")
        msg <- sub("rev [0-9]+), .*$", "rev XXXX), dd-Mon-yyyy ...", msg)
        actual[[3]] <- msg
    }
}

for (i in 1:length(expect)) {
    if (length(expect[[i]]) != length(actual[[i]])) {
        writeLines(paste0("Test ", i, " has different lengths"))
        show(expect[[i]])
        show(actual[[i]])
    }
}

print(save.results('red6ExePrompt',expect,actual))
## don't save environment
q("no")
