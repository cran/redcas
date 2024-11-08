## $Id: 190-redSolve-mk-tests.R,v 1.3 2024/10/05 15:12:43 mg Exp $

## Purpose: 1. Create ../190-redSolve.R to run tests for the redSolve function.
##          2. Create 190-redSolve-tests.red to run tests directly from REDUCE
##
##          Data for building the tests is located in 190-redSolve-test.txt and
##          190-redSolve-test-print.txt. Expected values in 190-redSolve-expect.R are
##          manually extracted from output of 190-redSolve-tests.red

tests.df <- read.table("190-redSolve-test.txt", header=TRUE, sep="\t", quote="")
ntests <- dim(tests.df)[1]
testno <- 1:ntests
closepar <- ifelse(tests.df$call == "", ")", "), type=\"message\")")
tests <- with(tests.df,
              sprintf("%sactual[[%d]] <- %sredSolve(id=r0, %s%s %s%s %s %s",
                      prefix, testno, call,
                      ifelse(eqns != "", paste0("eqns=c(", eqns, ")"), ""),
                      ifelse(eqns != "" & unknowns != "", ",", ""),
                      ifelse(unknowns != "", paste0("unknowns=c(", unknowns, ")"), ""),
                      ifelse((eqns != "" | unknowns != "") & switch != "", ",", ""),
                      ifelse(switch != "", paste0("switch=c(", switch, ")"), ""),
                      closepar))

## for reduce-based tests need only from test 7. The print tests are pure R
redtests.df <- tests.df[6:dim(tests.df)[1],]

## print tests
tests.pr.df <- read.table("190-redSolve-test-print.txt", header=TRUE, sep="\t", quote="")
prtestno <- 1:dim(tests.pr.df)[1] + ntests
tests.pr <- with(tests.pr.df, sprintf("%sactual[[%d]] <- %s", prefix, prtestno, call))
tests.df <- rbind(tests.df, tests.pr.df)
tests <- c(tests, tests.pr)
ntests <- dim(tests.df)[1]
testno <- 1:ntests

## tests for CSL
test.csl <- vector("character",3*ntests)
test.csl[seq(1,3*ntests,3)] <- sprintf("## Test No.:%02d %s", testno, tests.df$description)
test.csl[seq(2,3*ntests,3)] <- tests
test.csl[seq(3,3*ntests,3)] <- ""

## tests for PSL with list indices 22:42
test.psl <- test.csl
test.psl[seq(1,3*ntests,3)] <- sprintf("## Test No.:%02d %s", testno+ntests, tests.df$description)
test.psl[seq(2,3*ntests,3)] <- sub("actual\\[\\[([0-9]+)", "actual[[\\1+ntests", tests)
    
writeLines(c(readLines("190-redSolve-header.txt"),
             "",
             "library(redcas)",
             "source(\"data/test-utils.R\")",
             
             "\n## it does not make sense to run these tests  if there is neither redcsl nor redpsl",
             "do.csl <- class(redcas:::getReduceExec(\"csl\")) != \"logical\"",
             "do.psl <- class(redcas:::getReduceExec(\"psl\")) != \"logical\"",
             "if (do.csl == FALSE && do.psl == FALSE) {",
             "    writeLines(\"Skipping test execution because neither redcsl nor redpsl was found.\")",
             "    q(\"no\")",
             "}\n",

             "actual <- list()",
             "source(\"data/190-redSolve-expect.R\")",
             paste0("ntests <- ", ntests, "\n"),

             "if (do.csl) {",
             "    r0 <- redStart()",
             "    if (r0 == 0) {",
             "        writeLines(\"failed to start csl session. All csl tests will be skipped.\")",
             "    } else {",
             "        r1 <- redExec(r0, c(\"on echo; off nat;\"))\n",
             paste0("        ", test.csl),
             "        redClose(r0, \"190-redSolve.clg\")",
             "    } ## r0 == 0",
             "} ## do.csl\n",
             
             "if (do.psl) {",
             "    r0 <- redStart()",
             "    if (r0 == 0) {",
             "        writeLines(\"failed to start psl session. All psl tests will be skipped.\")",
             "    } else {",
             "        r1 <- redExec(r0, c(\"on echo; off nat;\"))\n",
             "        expect <- c(expect, expect)",
             paste0("        ", test.psl),
             "        redClose(r0, \"190-redSolve.plg\")",
             "    } ## r0 == 0",
             "} ## do.psl\n",
             
             "\nprint(save.results('redSolve',expect,actual))\n",
             "## don't save environment",
             "q(\"no\")"),
           con="../190-redSolve.R")

## 190-redSolve-tests.red

tests <- with(redtests.df,
              sprintf("%ssolve({%s},{%s});",
                      ifelse(switch != "", paste0(switch,"\n"), ""), eqns, unknowns))
ntests <- length(tests)
testno <- 6:(5+ntests)

red.calls <- vector("character",3*ntests)
red.calls[seq(1,3*ntests,3)] <- sprintf("%% Test No.:%02d %s",
                                        testno, tests.df$description[testno])
red.calls[seq(2,3*ntests,3)] <- tests
red.calls[seq(3,3*ntests,3)] <- ""
writeLines(c("%% $Id: 190-redSolve-mk-tests.R,v 1.3 2024/10/05 15:12:43 mg Exp $",
             "%% Purpose: Expected results for redSove tests, created by REDUCE.",
             "%%",
             "off nat; on echo ;",
             red.calls),
           "190-redSolve-tests.red")

## avoid saving .RData
q("no")
