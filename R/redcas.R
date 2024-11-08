## $Id: redcas.R,v 1.10 2024/11/04 11:46:16 mg Exp $

## modifications for finding cause of ON/OFF echo hang


## Purpose: Define main redcas functions and environment
## Contents:
##   Function           export?         Test program
##   redCodeDir         yes             various
##   redStart           yes             *redEXEC.R
##   redClose           yes             *redEXEC.R
##   cleanAndCopy                       *redOut.R
##   sessionAdd                         session.R
##   sessionGet                         session.R
##   sessionSet                         session.R
##   sessionExists                      session.R
##   sessionRunning                     *redEXEC.R
##   showSessions       yes             *redEXEC.R
##   getReduceExec                      getReduceExec.R
##   define environment not a function
##   connActive                         *redEXEC.R
##   redExec            yes             *redEXEC.R
##   redRead                            *redEXEC.R
##   redExpand          yes             redOut.R
##   redSplitOut        yes             redOut.R
##   redDropOut                         redOut.R
## * not yet implemented

## $Log: redcas.R,v $
## Revision 1.10  2024/11/04 11:46:16  mg
## - redClose checks log file write permissions and writes to console if none
## - redKillSession writes log file to console
## - changed redExec:notify default to 0
## - diagnostic messages now all use message
## - removed commented debugging writeLines
##
## Revision 1.9  2024/10/26 16:43:45  mg
## redStart:
##  - move call to redCodeDir before opening pipe
##  - use env var REDCAS_CODE_PATH in redExec call
## showSessions: removed column spec when id is specified
## .redcas.env: add comment as to why redCodeDir not called here
##
## Revision 1.8  2024/10/19 12:59:24  mg
## 1. remove file connection to log and use last scan for a block to return output and
##    references. Affects redStart, redRead, sessionAdd, sessionSet, sessionGet, redClose
## 2. explicitly name the allowed columns in sessionGet, sesssionSet, sessionRunning
## 3. getReduceExec applies normalizePath to result to avoid file not found problems on MacOS
## 4. removed spurious lines in output cause when reading the log via connection, last line
##    in block (which is not the marker) was also read in the next block.
##
## Revision 1.7  2024/10/14 12:03:15  mg
## Added --nogui to redexec if running in MacOS to prevent xquartz being started
##
## Revision 1.6  2024/10/05 15:12:44  mg
## Moved to inst
##
## Revision 1.5  2024/09/07 13:08:36  mg
## redSplitOut now handles comment following a command on the same line: "command; %
## comment". REDUCE sends the comment to a new line without line number and following the
## output.
##
## Revision 1.4  2024/09/03 16:49:28  mg
## 1. redStart: added echo parameter
## 2. redExec: check input for final lines with missing terminator and exit the function \
##    with appropriate message. Implemented in a separate (internal) function
##    check.terminator
## 3. redSplitOut: treat comments as command rather than output
## 4. redDropOut: if NAT is on, output has the $ terminator so include this optionally
##    when looking for the marker.
##
## Revision 1.3  2024/07/10 16:42:57  mg
## Added function redCodeDir
## Load all reduce functions using redCodeDir() at start
## Corrected bug in sessionAdd which caused hang (count of lines was incorrect)
## Added timeout argument to redExec() which passes it to redRead()
## When writing the block markers, send explicit code to reduce - the mark_end_block function was causing problems
## Read Sys.time() as numeric
## In redSplitOut handle multiple command numbers on a single line
## In redSplitOut handle LaTeX output
## Added some comment explaining code I already found to be obscure
## Treat line with only ; as command
##
## Revision 1.2  2024/03/05 15:52:38  mg
## 1. redStart
##    - rename  argument dirctry to dirpath
##    - suppress printing of resMEB
## 2. getReduceExec: rename  argument dirctry to dirpath
## 3. redExec
##    - change split default to TRUE
##    - add notify argument
##    - call redKillSession if redExpand finds a file does not exist
##    - call redKillSession if redRead found a reason to do so
## 4. new function redKillSession
## 5. redRead
##    - add notify argument
##    - rework check for end of block to keep track of time and report still alive
##    - check for 'declare operator' prompt
## 6. redExpand
##    - identify files by prefix 'file:'
##    - report to redExec if files not found
##
## Revision 1.1  2024/02/27 14:25:31  mg
## Initial version
##

##  Function: redCodeDir
## Arguments: None
##     Value: path to the package reduce subdirectory and assigns environment variable
##            REDCODEDIR for use in reduce programs
redCodeDir <- function() {
    ppath <- system.file(package="redcas")
    redcd <- paste0(ppath, "/reduce")
    Sys.setenv("REDCODEDIR"=redcd)
    Sys.setenv("REDCAS_CODE_PATH"=paste0(redcd, "/redcas.red"))
    Sys.setenv("TMPRINT_PSL_PATH"=paste0(redcd, "/tmprint-psl.red"))
    return(redcd)
}

##  Function: redStart
## Arguments:
##   dialect:c('csl', 'psl')
##   dirpath: the directory containing the reduce executables
##   options: options for redcsl
##     Value: integer session identifier, 0 or FALSE is failure
redStart <- function(dialect="csl", dirpath, options, echo=FALSE) {
    if (dialect == "") stop("argument dialect is required.")
    if (!is.element(dialect, c('csl', 'psl'))) stop("argument 'dialect' must be 'csl' or 'psl'.")
    ## get a temporary file name for the reduce log
    logname <- tempfile(paste0(dialect, "out"))
    ## construct the command
    if (missing(dirpath)) redexec <- getReduceExec(dialect)
    else redexec <- getReduceExec(dialect,dirpath)
    if (is.logical(redexec)) return(FALSE)

    ## append user specified options
    if (!missing(options) && dialect == 'csl') redexec <- paste0(redexec, " ", options)
    ## redcsl opens a GUI session on MacOS if xquartz is installed which means redStart
    ## hangs, so add --nogui to options to avoid this.
    if (Sys.info()["sysname"] == "Darwin") { redexec <- paste0(redexec, " --nogui") }

    ## define the environment variables needed by REDUCE to find our REDUCE
    ## functions. This must be done before opening the pipe
    redCodeDir <- redCodeDir()

    ## open the pipe
    redpipe <- pipe(paste0(redexec, " >", logname), open="w")
    ## check pipe is open
    if (!isOpen(redpipe)) {
        stop("Connection to reduce failed to open")
    }
    ## wait for reduce to start
    Sys.sleep(0.05)
   
    ## assign sessionID, initialize counters, save output file path, save  pipe connection number
    sessionID <- sessionAdd(redexec, logname, redpipe)

    ## load the reduce functions
    funcs.red <- paste0("in \"", Sys.getenv("REDCAS_CODE_PATH"), "\" $")
    if (echo) funcs.red <- c(funcs.red, "on echo;")
    funcs.out <- redExec(sessionID, funcs.red, split=FALSE)
    return(sessionID)
}

##  Function: redClose
##   Purpose: close a reduce session, optionally copying the log file
## Arguments:           
##        id: session ID
##       log: target for copy
##     Value: logical
redClose <- function(id, log) {
    if (!is.element(id, .redcas.env[['session']][,'id'])) {
        warning("Session ", id, " does not exist.")
        return(FALSE)
    }
    
    if (pconn <- connActive(sessionGet(id, 'pcon'))) close(sessionGet(id, 'pcon'))

    if (!missing(log)) {
        redlog <- sessionGet(id, "logname")
        if (file.exists(redlog)) cleanAndCopy(redlog, log)
    }
    .redcas.env[['session']] <-
        .redcas.env[['session']][-which(.redcas.env[['session']][,'id'] == id),]
    return(TRUE)
}
    
##  Function: cleanAndcopy
##   Purpose: remove end of submit block markers from log and copy to destination
## Arguments:
##       src: the log file in tempdir()
##       tgt: where to copy src
##     Value: logical
cleanAndCopy <- function(src, tgt) {
    ## check for write access
    if (file.access(dirname(tgt), mode=2) == -1) {
        message(paste0("You don't have permission to write to ", dirname(tgt), "\n"),
                "Log contents are:\n\n",
                paste0(readLines(src, warn=FALSE), "\n"))
    } else {
        file.copy(src, tgt, overwrite=TRUE, copy.date=TRUE)
        file.remove(src)
    }
}
    
##  Function: sessionAdd
##   Purpose: add a record to the session dataset for a new session
## Arguments:
##       cmd: the command to start reduce
##       log: the path to the output file
##      pcon: the connection number of the pipe
##     Value: the session id (number)
sessionAdd <- function(cmd, log, pcon) {
    
    if (dim(.redcas.env[['session']])[1] == 0) newId <- 1
    else newId <- max(.redcas.env[['session']][,'id'])+1
    if ((newId) == 1) {
        .redcas.env[['session']] <- data.frame(id=newId, pcon=I(pcon),
                                               cmd=cmd, logname=log, blockn=0, lines.read=0)
    } else {
        .redcas.env[['session']] <- rbind(.redcas.env[['session']],
                                          list(id=newId, pcon=I(pcon),
                                               cmd=cmd, logname=log, blockn=0, lines.read=0))
    }
    return(newId)
}

##  Function: sessionGet
##   Purpose: return information about a session
## Arguments:
##        id: the session id
##      what: pipe, log, cmd, logname
##     Value: the value if session exists, FALSE otherwise
sessionGet <- function(id, what) {
    if ((idrow <- sessionExists(id)) == 0) return(FALSE)
        
    allowed <- c("pcon", "cmd", "logname", "blockn", "lines.read")
    if (is.element(what, allowed)) {
        whichcol <- which(what == allowed)+1
        if (is.element(what, c('pcon', 'lcon'))) {
            x <- getConnection(.redcas.env[['session']][idrow, whichcol])
        } else {
            x <- .redcas.env[['session']][idrow, whichcol]
        }
        ##print (class(x))
        return(I(x))
    } else {
        return(FALSE)
    }
}

##  Function: sessionSet
##   Purpose: update submit block or lines read counts
## Arguments:
##        id: session ID
##      what: c("blockn", "lines.read)
##         x: new value
##     Value: logical
sessionSet <- function(id, what, x) {
    if ((idrow <- sessionExists(id)) == 0) return(FALSE)
    allowed <- c("blockn", "lines.read")
    if (!is.element(what, allowed)) return(FALSE)
    .redcas.env[['session']][idrow, what] <- x
}

##  Function: sessionExists
##   Purpose: does a session exist?
## Arguments:
##        id:
##     Value: integer. 0=does not exist, >0 row number of existing session
sessionExists <- function(id) {
    idList <- .redcas.env[['session']][, 'id']
    if (!is.element(id, idList)) {return (0) }
    else {return(which(id == idList)) }
}

##  Function: sessionRunning
##   Purpose: is a session running, i.e. both connections are active
## Arguments:
##        id:
##     Value: logical
sessionRunning <- function(id) {
    if (sessionExists(id) == 0) {
        return(FALSE)
    } else {
        if (connActive(sessionGet(id, 'pcon'))) {
            return(TRUE)
        } else {
            return(FALSE)
        }
    }
}

##  Function: showSessions
##   Purpose: List session details
## Arguments:
##        id: session id. optional.
##     Value: data frame .redcas.env[['session']] if no id, otherwise only that id
showSessions <- function(id) {
    if (dim(.redcas.env[['session']])[1] == 0) {
        message("No sessions defined. ")
        return(invisible(FALSE))
    }
    if (missing(id)) {.redcas.env[['session']]}
    else {
        if ((idrow <- sessionExists(id)) == 0) {
            message("No such session: ", id)
            return(invisible(FALSE))
        } else {
            .redcas.env[['session']][idrow, ] # 'id']
        }
    }
}

##  Function: getReduceExec
##   Purpose: if dirpath is missing, find the reduce executable for dialect. Otherwise check
##            that the pat exists.
## Arguments:
##   dialect:
##   dirpath:
##     Value: directory containing the reduce executable or FALSE if not found
getReduceExec <- function(dialect, dirpath) {
    if (missing(dialect)) {
        message("argument dialect is required.")
        return(FALSE)
    }
    if (!is.element(dialect, c('csl', 'psl'))) {
        message("argument 'dialect' must be 'csl' or 'psl'.")
        return(FALSE)
    }
        
    if (!missing(dirpath)) {
        if (.Platform$OS.type == "windows") dirpath <- sub("/$", "", dirpath)
        if (file.exists(redexec <- paste0(dirpath, "/red", dialect))) return(normalizePath(redexec))
        else {
            message(redexec, " does not exist.")
            return(FALSE)
        }
    } else {
        redexec.env <- Sys.getenv("REDUCE_EXEC")
        if (.Platform$OS.type == "windows") redexec.env <- sub("/$", "", redexec.env)
        if (nchar(redexec.env) > 0 && file.exists(redexec.env)) {
            redexec <- paste0(redexec.env, "/red", dialect)
            if (file.exists(redexec)) return (redexec)
        }
        ## no REDUCE_EXEC or dialect not present there so try the reduce_exec option
        redexec.opt <- getOption("reduce_exec")
        if (.Platform$OS.type == "windows") redexec.opt <- sub("/$", "", redexec.opt)
        if (!is.null(redexec.opt) && nchar(redexec.opt) > 0 && file.exists(redexec.opt)) {
            redexec <- paste0(redexec.opt, "/red", dialect)
            if (file.exists(redexec)) return(normalizePath(redexec))
        }
        ## no reduce_exec option of dialect not present there so last option is PATH
        redexec.which <- Sys.which(paste0("red",dialect))
        if (.Platform$OS.type == "windows") redexec.which <- sub("/$", "", redexec.which)
        if (nchar(redexec.which) > 0) { ## already includes image
            return(redexec.which)
        } 
        ## dialect not found
        message("no reduce executable found for dialect ", dialect)
        return(FALSE)
    }
}

## initialize the private environment
if (!exists(".redcas.env")) {

    ## create the environment
    .redcas.env <- new.env(parent=emptyenv())

    ## Note: definition of the columns in the session register data frame is done in
    ## sessionAdd. Otherwise we have issues with the class of pcon - it must be (pipe,
    ## connection) but we need a connection to set it up. Here we just create an empty
    ## register so that a call to showSessions() prior to population can return a sensible
    ## message
    .redcas.env[['session']] <- data.frame()
    ## id=vector("integer"),
    ## pcon=vector("integer"),
    ## cmd=vector("character"),
    ## logname=vector("character"),
    ## blockn=vector("integer"),
    ## lines.read=vector("integer")

    ## .redcas.env[['session']][1,] <- list(0, NA, NA, "", "")
    ## find reduce executables
    .redcas.env[['cslexec']] <- getReduceExec('csl')
    .redcas.env[['pslexec']] <- getReduceExec('psl')
    ## Note that saving redcodedir causes the build process to fail with the message
    ## ERROR: hard-coded installation path: please report to the package maintainer and
    ##        use '--no-staged-install'
    ## so do NOT set this. Call redCodeDir in redStart BEFORE starting the REDUCE session
    ## .redcas.env[['redcodedir']] <- redCodeDir()
}

##  Function: connActive
##   Purpose: is a connection active?
## Arguments:
##      conn: connection number
##     Value: logical
connActive <- function(conn) {
    cmd <- showConnections()[conn[1] == rownames(showConnections()), 1]
    if (length(cmd) > 0) {return(TRUE)} else {return(FALSE)}
}


##  Function: redExec
##   Purpose: execute reduce code and return the output
## Arguments:
##        id: session id
##         x: code to execute
##     split: split output into commands and output?
##    notify: number seconds after which user is notified that reduce commands still running
##   timeout: number seconds after which redRead returns if reduce commands still
##            running. The default, Zero, is never.
## drop.blank.lines: remove completely blank lines from the output?
##     Value: ouput as either a vector (split=FALSE) or list of three vectors (split=TRUE)
redExec <- function(id, x, split=TRUE, drop.blank.lines=FALSE, notify=0, timeout=0) {
    ## start pipe if not open? if so what to return?
    if (!sessionRunning(id)) stop("There is no reduce session ", id)
    if (!is.character(x)) stop("x must be a character vector containing either ",
                               "reduce commands or the names of reduce program files.")
    
    ## Submit the commands. First get the submit block number:
    blockn <- sessionGet(id, "blockn")
    ## insert the contents of any files mentioned
    x <- redExpand(x)
    ## if a file referenced in x (file:filename) does not exist we terminate the session
    if (is.list(x)) {
        redKillSession(id, reason=x$reason)
        return(FALSE)   ## should this be stop?
    }

    ## refuse to run if the last entry of x, which is neither a comment nor empty, has no
    ## reduce terminator.
    term.ok <- check.terminator(x)
    if (!term.ok) return (FALSE)

    ## prepend a ; to force line number on first line and add the marker at the end. these
    ## must be done after we have determined that there is a final terminator because a)
    ## if there are only comments or blank lines, the prepended ; causes the "no
    ## substantial statements" message not be issued as the "last" statement has a
    ## terminator; b) the marker statement has a terminator and would always return true.
    x <- c(";", x, paste0('write "=====> submit number ", ', blockn, ', " done <=====" ;'))

    ## send to reduce 
    writeLines(x, sessionGet(id, "pcon"))

    ## get the output. Notify and timeout are converted from seconds to number of iterations
    redout <- redRead(id, blockn, notify*20, timeout*20)

    ## if redRead found a reason to terminate
    if (is.list(redout)) {
        redKillSession(id, reason=redout$reason)
        return(FALSE)   ## should this be stop?
    }

    redout <- redDropOut(redout, "marker")
    if (drop.blank.lines) redout <- redDropOut(redout, "blank")
    if (split) redout <- redSplitOut(redout)
    sessionSet(id, "blockn", blockn + 1) ## must be after the call to redRead
    return(redout)
}

## Function: redKillSession
##  Purpose: Kill a session when something has gone wrong
##           
## Arguments:
##        id: session ID
##    reason: a vector to be written as part of the termination message
##     Value: logical
redKillSession <- function(id, reason) {
    the.log <- paste0(readLines(sessionGet(id,"logname"), warn=FALSE), "\n")
    message(reason, "\nREDUCE session log:\n\n", the.log)
    message("\nThe session will now be terminated.\n")
    redClose(id)
}

## Function: redRead
##  Purpose: read from the log file
##           
## Arguments:
##        id: session ID
##    blockn: submit block number
##    notify: number of iterations after which to notify reduce command still running
##   timeout: number of iterations after which to timeout if reduce command still running
##     Value: character vector containing the output
redRead <- function(id, blockn, notify, timeout) {
    flush.connection(sessionGet(id, "pcon"))
    the.log <- sessionGet(id,"logname")
    lines.read <- sessionGet(id,"lines.read")

    ## debugging
    ## message("redRead: block: ", blockn, " lines.read: ", sessionGet(id,"lines.read"))
    ## debugging

    ## read the output file using scan with an implicit connection, skipping lines read in
    ## previous calls, until the end of block marker is found.
    have.marker <- FALSE
    loop.steps <- 1
    now <- as.numeric(Sys.time())
    while (!have.marker) {
        Sys.sleep(0.05)
        ## read any output generated by this submit block directly from the file
        out.block <- scan(the.log, character(),
                          skip=lines.read,
                          sep="\n",
                          quiet=TRUE,
                          blank.lines.skip=FALSE)
        ## check whether we have the end of block marker
        line.marker <- which(grepl(paste0("^=====> submit number ", blockn, " done <=====\\$?$"),
                                   out.block))
        have.marker <- length(line.marker)>0

        ## check for any prompts in the log which might be causing REDUCE to wait
        ## "*** x declared operator" is ok because it means INT is off
        promptRE <- c("Declare [a-zA-Z!][0-9a-zA-Z_!*$-]* operator \\?  \\(Y or N\\)")
        prompts <- vector("numeric")
        for (i in 1L:length(promptRE)) {
            prompts <- c(prompts, which(grepl(promptRE[i],out.block)))
        }
        if (length(prompts) > 0) {
            return(list("KILL",
                        reason=c("REDUCE is waiting for a prompt:\n",
                                 paste0(out.block[prompts],"\n"))))
        }
        
        ## let user know we are still alive but taking a long time
        if (notify != 0 && loop.steps %% notify == 0) {
            message(paste0(round(as.numeric(Sys.time() - now), 1),
                           " seconds elapsed, reduce commands still executing."))
        }

        loop.steps <- loop.steps+1

        ## give up if we have passed timeout
        if (timeout != 0 & loop.steps > timeout) {
            message(paste0("redRead: stopping loop after ", loop.steps/20, 
                           "seconds, only output written so far will be returned."))
            break
        }
    }

    ## increment the lines read
    lines.read <- lines.read + length(out.block)
    sessionSet(id,"lines.read", lines.read)

    return(out.block)    
}

##  Function: redExpand
##   Purpose: replace file names in x with their contents
## Arguments:
##         x: character vector containing reduce commands or files of such
##     Value: copy of x with contents of files inserted in place of the file names
redExpand <- function(x) {
    fileRE <- "^[\t ]*file[\t ]*:[\t ]*"
    if (length(fidx <- which(grepl(fileRE, x))) == 0) return(x)
    ## x contains file names
    job <- vector("character")
    for (j in 1:length(x)) {
        if (is.element(j,fidx)) {
            fname <- gsub(paste0("(", fileRE, "|[[\t ;]*$)"), "", x[j])
            if (file.exists(fname)) {job <- c(job, readLines(fname, warn=FALSE))}
            else {
                return(list(action="KILL",
                            reason=c(paste0("Input file not found: ", fname, "\n"),
                                     "Could not insert its contents into the command vector.\n")))
            }
        } else {job <- c(job, x[j])}
    }
    return(job)
}

##  Function: redSplitOut
##   Purpose: separate reduce output into commands and command output
## Arguments:
##         x: character vector containing reduce output
##     Value: list with 3 character vectors: out, cmd, raw
## NOTE: 1. both csl psl can write output on the same line as a command, e.g.:
##          4: a:=sqrt(b^2 + c^2) ;\begin{displaymath}
##          so we need a loop rather than using grep(value=FALSE) so we can split these
##          lines and insert the output in the correct order. It's possible that this is
##          only true for RLFI but that doesn't really help
##       2. If NAT is off, fancy_tex has no effect!
##       3. commands written to files other than stdout (using OUT file) do not have a
##          command number. However, unless we parse the reduce code, we will not read
##          such files...
redSplitOut <- function(x) {
    raw <- x
    cmd <- vector("character")
    out <- vector("character")
    ## can only remove blank lines if we know that NAT is off. We would have to parse the
    ## submitted code, but perhaps packages can toggle this? Perhaps we should rely on the
    ## user to tell us to remove them.
    for (i in 1L:length(x)) {
        if (grepl("^ *%.*$", x[i])) { ## line is a comment (comments trailing cmds are on new line)
            cmd <- c(cmd, x[i])
        } else if (grepl("^([0-9]+: )+", x[i])) { ## line is a command
            if (grepl("^([0-9]+: )+ *%", x[i])) { ## line is a comment
                cmd <- c(cmd, x[i])
            } else if (grepl(";[^;]+$", x[i])) { ##  line has a trailing output
                out.new <- sub("^.*;", "", x[i])
                ## if the command was lisp, output may also appear on the next line
                if ((i<length(x) && out.new != x[i+1]) || (i == length(x))) {
                    out <- c(out, out.new)}
                cmd.new <- sub(";[^;]+$", ";", x[i])                
                cmd <- c(cmd, cmd.new)
            } else if (grepl("^([0-9]+: )+latex:\\\\black", x[i])) { ## fancy with echo off
                ## in this case there is no repetition
                out.new <- sub("^([0-9]+: )+", "", x[i])
                out <- c(out, out.new)
                cmd.new <- sub("latex:\\\\black.*$", "", x[i])
                cmd <- c(cmd, cmd.new)
            } else { ## command only
                cmd <- c(cmd, x[i])
            }
        } else if (grepl("^ *; *$", x[i])) { ## line with only ; is a command
                cmd <- c(cmd, x[i])
        } else { ## line is an output line 
            out <- c(out, x[i])
        }
    }
    return(list(out=out, cmd=cmd, raw=raw))
}

##  Function: redDropOut
##   Purpose: drop blank lines or end submit markers from outut
## Arguments:
##         x: output vector
##      what: c('blank', 'marker')
##     Value: input vector with corresponding elements removed
redDropOut <- function(x, what) {
    if (what == "blank") {
        return(x[-grep("^$", x)])
    } else if (what == "marker") {
        ## remove the command
        x <- sub('write "=====> submit number ", [0-9]+, " done <=====" ;', "", x)
        ## find the marker
        meb <- which(grepl("^=====> submit number [0-9]+ done <=====\\$?$", x))
        if (length(meb) > 0) return(x[-meb]) else return(x)
    } else {
        message("redDropOut: what must be 'blank' or 'marker'.")
        return (x)
    }
        
}

##  Function: check.terminator
##   Purpose: refuse to run if the last entry of x, which is neither a comment nor empty,
##            has no semi-colon. Note The last element cannot be a file: because we have
##            just run redExpand. First remove any comment and all spaces from the last
##            line. If this is not blank, check for semi-colon, if not repeat backwards
##            until such is found or we reach the top.
## Arguments:
##         x: input vector after redExpand was run
##     Value: Logical. If TRUE we can continue
check.terminator <- function(x) {
    last.idx <- length(x)
    sc.found <- FALSE
    while (! sc.found) {
        last.el <- gsub(" ", "", x[last.idx])
        last.el <- sub("%.*$", "", last.el)
        if (last.el == "") {
            if (last.idx == 1) {
                message("note: x has only comment statements.")
                return(TRUE) 
            } else {last.idx <- last.idx -1}
        } else {
            if (grepl("(;|\\$)$", last.el)) {
                return(TRUE) 
            } else {
                message("error: last non-comment statement:\n       ", x[last.idx],
                        "\n       has no terminator. Stopping.")
                return(FALSE)
            }
        }
    }
}

