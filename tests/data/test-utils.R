## $Id: test-utils.R,v 1.8 2024/10/19 14:13:22 mg Exp $
## Purpose: functions for summarizing test results
## $Log: test-utils.R,v $
## Revision 1.8  2024/10/19 14:13:22  mg
## 1. save.results:
##    - added a Comment column to results.df data frame to identify cases where the test
##      passes because there are only white space differences
##    - exclude rows with expect==OBSOLETE from results
## 2. added white.space.only function to change fail to pass if failure is due to white space
##    differences
## 3. updated number of tests
## 4. added aelen function to ensure that expect and actual have the same length and that the
##    corresponding elements have the same length
## 5. in redcas.batch, added --nogui as argument to csl call
##
## Revision 1.7  2024/10/08 20:26:14  mg
## Corrected number of tests: 04 and 07 had numbers swapped
##
## Revision 1.6  2024/10/05 15:12:43  mg
## Moved to inst
##
## Revision 1.5  2024/10/03 14:17:34  mg
## Added configuration for redLtxIdx to headings dataset
##
## Revision 1.4  2024/09/09 12:21:03  mg
## updated number of tests for redSolve
##
## Revision 1.3  2024/09/04 11:52:24  mg
## 1. show convenience function for displaying redExec output
## 2. save.results handles redcas.solve objects
## 3. save.results writes expect/actual to .RData for easier debugging
## 4. summarize.results now contains grouping info and number of tests per group
## 5. report data-driven using data frame from summarize.results
## 6. new redcas.batch function runs reduce code and extracts output using approprite
##    markers.
##
## Revision 1.2  2024/03/05 15:49:25  mg
## added new tests and re-ordered
##
## Revision 1.1  2024/02/27 14:25:33  mg
## Initial version
##

## display results from a call
##    x: the object to display. This must be the result from a call to redExec or asltx
## what: c("out", "raw", "cmd", "tex") 
show <- function(x,what=c("out", "raw")) {
    x.name <- deparse(substitute(x))
    if (is.list(x)) {
        allowed <- c("out", "raw", "cmd", "tex")
        if (all(is.element(what, allowed))) {
            for (el in what) {
                if (is.element(el, names(x))) {
                    writeLines(c(paste0(strrep("-",5), x.name, "$", el, strrep("-",50)), x[[el]]))
                } else {
                    writeLines(paste0(x.name, " has no element ", el))
                }
            }
            writeLines(strrep("-",70))
        } else {
            writeLines("what must be a subset of c(\"out\", \"raw\", \"cmd\", \"tex\")")
            writeLines(strrep("-",70))
        }
    } else if (is.character(x)) {
        writeLines(c(paste0(strrep("-",5), x.name, strrep("-",50)), x, strrep("-",70)))
    } else {
        writeLines("x must be a list of character vectors or a character vector")
    }
}

## save results from a test
save.results <- function(prefix, expect, actual) {
    results.df <- data.frame(Test=sprintf("%s-%03d", prefix, 1:length(expect)),
                             Result=vector("logical",length(expect)),
                             Expect=I(expect),
                             Actual=I(actual),
                             Comment=vector("character",length(expect)))
    if (is.element("redcas.solve", class(expect))) {
        results.df$Result <-
            unlist(lapply(1:length(expect), function(x){all.equal(expect[[x]],actual[[x]])}))
    } else if (is.list(expect)) {
        results.df$Result <-
            unlist(lapply(1:length(expect), function(x){all(expect[[x]] == actual[[x]])}))
    } else if (is.vector(expect)) results.df$Result <- expect == actual
    ## remove obsolete tests
    if (any(results.df$Expect == "OBSOLETE")) {
        results.df <- results.df[-which(results.df$Expect == "OBSOLETE"),]
    }
    ## there may be diffs which are whitespace only - I've seen "- 1" on Mac vs "-1" on
    ## Linux or possibly version-related.
    results.df <- white.space.only(results.df)
    saveRDS(results.df, file=paste0(prefix,".RDS"))
    ## for debugging
    save(expect, actual, file=paste0(prefix,".RData"))
    return(results.df)
}

white.space.only <- function(adf) {
    failed <- which(!adf[, "Result"])
    char <- which(unlist(lapply(adf[, "Expect"], is.character)))
    fail.char <- intersect(failed, char)
    for (j in fail.char) {
        if (all(gsub(" ", "", unlist(adf[j,"Expect"])) == gsub(" ", "", unlist(adf[j,"Actual"])))) {
            adf[j, "Result"] <- TRUE
            adf[j, "Comment"] <- "Whitespace diff"
        }
    }
    return(adf)
}

## combine and summarise tests
summarize.results <- function() {
    headings <- data.frame(

        name=c("red1GetExe",     "red2Session", "red3Output",
               "red4OutFnf",     "red5Exe",     "red6ExePrompt",
               "red7ExeLong",    "redMany",     "redArrayBasic",
               "redArrayFancy",  "redExpr",     "redAsLtx",
               "redAsLtxR",      "redExeSemiC", "redNumOut",
               "redSolve",       "redStart",    "redExeChkTerm",
               "redLtxIdx"),	 
        
        
        label=c("01 Finding Reduce executables", "02 Session handling", "03 Output handling",
                "04 Output: file not found",     "05 Execution",        "06 Execution: prompts",
                "07 Execution: long-running",    "08 Execution: Many redExec calls", "09 Arrays",
                "09 Arrays",                     "10 Expressions",      "11 asltx from REDUCE",
                "12 asltx from R",               "13 Bug fixes",        "13 Bug fixes",
                "14 redSolve",                   "05 Execution",        "05 Execution",
                "12 asltx from R"),

        ntests=c(11, 15, 17,
                 6,  28,  3,
                 3,  16, 22,
                 12,  8, 40,
                 18,  8, 14,
                 54, 20, 30,
                  3))
    dfnames <- vector("character")
    for (fdf in list.files(".", pattern="red.*RDS$", ignore.case=TRUE)) {
        fdf.name <- sub(".RDS", "", fdf)
        dfnames <- c(dfnames, fdf.name)
        assign(fdf.name, readRDS(fdf))
        if (!exists("redcas.results")) redcas.results <- get(fdf.name)
        else redcas.results <- rbind(redcas.results, get(fdf.name))
    }
    redcas.results$Group <- unlist(lapply(sub("-[0-9]+", "", redcas.results$Test),
                                          function(x){headings[headings$name == x,"label"]}))
    redcas.results <- redcas.results[order(redcas.results$Group), ]
    ## Individual groups
    for (Group in unique(redcas.results$Group)) {
        report(redcas.results[redcas.results$Group == Group,], Group,
               sum(headings[headings$label == Group, "ntests"]))
    }
    ## all groups
    report(df=redcas.results, heading="All Groups", sum(headings$ntests))
    writeLines("----------------------------------------------------------------------")
}

## report on test results
report <- function(df, heading, ntests) {
    passed <- which(df[,'Result']); npassed <- length(passed)
    failed <- which(!df[,'Result']); nfailed <- length(failed)
    nskipped <- ntests - npassed - nfailed
    writeLines(c("----------------------------------------------------------------------",
                 paste0(c("  Group: ", "  Tests: ", " Passed: ", " Failed: ", "Skipped: "),
                        c(heading, ntests, npassed, nfailed, nskipped))))
              
    if (nfailed > 0 && heading != "All") {
        writeLines(sprintf("%11s expect: %s\n%11s actual: %s",
                           df[failed, "Test"], df[failed, "Expect"], "", df[failed, "Actual"]))
    }
}

## Function: aelen
##  Purpose: report on differences in length for expected and actual
aelen <- function(what=c("out", "raw")){
    if (length(expect) != length(actual)) {
        lub <- min(length(expect), length(actual))
        writeLines(c(paste0("Lengths of expect and actual differ, ",
                            length(expect), "!=",  length(actual)),
                     "Comparisons might not be valid"))
        
    } else {
        lub <- length(expect)
    }
    difflen <- 0
    for (i in 1:lub) {
        if (length(expect[[i]]) != length(actual[[i]])) {
            writeLines(sprintf("length expect[[%3d]]: %3d  actual[[%3d]]: %3d",
                               i, length(expect[[i]]), i, length(actual[[i]])))
            show(expect[[i]],what)
            show(actual[[i]],what)
            difflen <- difflen + 1
        }
    }
    if (difflen == 0) writeLines("all lengths match.")
}

## Function: redcas.batch
##  Purpose: execute reduce tests directly in batch without the interface, extract the
##           output sections, compare to expected and save results. Lines to extract start
##           with the string "##TEST n START" and end with "##TEST n END" where n is the
##           zero-filled test number.
## Args:
##      pgm: name of reduce program to execute
##    width: number of digits for zero filling the test numbers
##
##    Value: list with expect and actual entries
##
##     Note: extracting the relevant output this is based on redcas:::redSplitOut and
##           redltx::ltx.extract. This could be the basis for an exported redBatch
##           function

redcas.test.batch <- function(pgm, width) {
    pgmpath <- dirname(pgm)
    pgmname <- basename(pgm)
    pgmstem <- sub("\\.red$", "", pgmname)
    actroot <- paste0(pgmpath, "/data/", pgmstem, "-actual-")
    exproot <- paste0(pgmpath, "/data/", pgmstem, "-expect-")
    expfiles <- list.files("data", paste0(pgmstem, "-expect-"), full.names=TRUE)
    ls.csl <- list()
    ls.psl <- list()
    for (dialect in c("csl", "psl")) {
        redexec <- redcas:::getReduceExec(dialect)
        if (class(redexec) != "logical") {
            writeLines(paste0("executing with reduce ", dialect))
            if (Sys.info()["sysname"] == "Darwin" && dialect == "csl") { opt <- " --nogui" }
            else { opt <- "" }
            log.raw <- system2(redexec, args=opt, stdin=pgm, stdout=TRUE, stderr=TRUE)
        } else {
            writeLines(paste0("No ", toupper(dialect), " executable found. Skipping tests"))
            next
        }

        ## first extract the output
        log <- redcas:::redSplitOut(log.raw)[["out"]]
        ## writeLines(log)
        
        ## now extract the marked output and count the tests
        marked <- redGetMarked(log, startRE="^##START ", endRE="^##END ", name="")
        if (dialect == "csl") { ls.csl <- marked
        } else if (dialect == "psl") {
            ls.psl <- marked
            names(marked) <- sprintf(paste0("%0", width, "d"),
                                     as.integer(names(marked))+length(marked))
        }
    }

    ## construct the actual and  expectd lists
    len.csl <- length(ls.csl)
    len.psl <- length(ls.psl)
        if (len.csl+len.psl == 0) {
        return()
    } else {
        actual <- list()
        expect <- lapply(expfiles, readLines)
        if (len.csl > 0 && len.psl == 0) {
            actual <- ls.csl
        } else if (len.csl == 0 && len.psl > 0) {
             actual <- ls.psl
        } else {
            actual <- c(ls.csl, ls.psl)
            expect <- c(expect, expect)
        }
    }
    return(list(expect=expect, actual=actual))
}

## Function: redGetMarked
##  Purpose:
redGetMarked <- function(redlog, startRE="^##START ", endRE="^##END ", name="", debug=FALSE) {
        red.start <- grep(startRE, redlog)
        red.end <- grep(endRE, redlog)
        if (debug) {writeLines(c("start:",red.start,"end:",red.end))}

        ## check consistency of start and end markers
        ## 0. there is at least one block
        if (length(red.end)  == 0 || length(red.start) == 0) {
            writeLines("No ##START/##END blocks found.")
            return(FALSE)
        }
        
        ## 1. same number of STARTs as ENDs
        if (length(red.start) < length(red.end)) {
            message(log, " has fewer ##STARTs than ##ENDs.")
            return(FALSE)
        } else if (length(red.start) > length(red.end)) {
            message(log, " has more ##STARTs than ##ENDs.")
            return(FALSE)
        }

        ## 2. No end before start
        eb4s <- red.end - red.start <= 0
        if (debug) {print(eb4s)}
        if (any(eb4s)) {
            writeLines(c("Some ##ENDs before corresponding ##START:",
                         paste(red.start[which(eb4s)],red.end[which(eb4s)],sep = " > ")))
            return(FALSE)
        }

        ## 3. end after "subsequent" start
        if (length(red.end)>1 && length(red.start)>1) {
            eass <- red.end[1:(length(red.end)-1)] > red.start[2:length(red.start)]
            if (debug) {print(eb4s)}
            if (any(eass)) {
                writeLines(c("Some ##ENDs before following ##START:",
                             paste0('red.end[',which(eass),'] (',red.end[which(eass)],')',
                                    ' after red.start[',which(eass)+1,'] (',red.start[which(eass)+1], ')')))
                return(FALSE)
            }
        }

        ## Extract the marked pieces to a list of vectors. 
        marked <- lapply(1:length(red.start),
                          function(x){return(redlog[(red.start[x]+1):(red.end[x]-1)])})
        names(marked) <- sub(startRE, name, redlog[red.start])

        return(marked)
        
}
