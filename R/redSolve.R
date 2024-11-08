## $Id: redSolve.R,v 1.4 2024/11/04 11:42:52 mg Exp $

## Purpose: Functions to execute the REDUCE solve operator and parse the result

## $Log: redSolve.R,v $
## Revision 1.4  2024/11/04 11:42:52  mg
## removed commented debugging writeLines
##
## Revision 1.3  2024/09/09 11:23:08  mg
## print.redcas.solve now handles solutions which are too long for the available width
##
## Revision 1.2  2024/09/05 17:31:48  mg
## bug fix: print method was using a fixed value (16) instead of varlen
##
## Revision 1.1  2024/09/03 16:40:26  mg
## Initial version
##


## create the redcas.solve S4 class
redcas.solve <- setClass("redcas.solve",
                         slots=c(solutions="list",
                                 rsolutions="list",
                                 nsolutions="numeric",
                                 rc="numeric",
                                 root_of="complex",
                                 eqns="character",
                                 unknowns="character",
                                 switches="character")
                        ,contains="list")

## print method for redcas.solve
setMethod("print",
    signature(x = "redcas.solve"),
    function (x, ...) {
        out <- vector("character")
        nx <- length(x@unknowns)
        out <- c(out, "Equations:", paste0("  ", x@eqns))
        out <- c(out, sprintf("\nNumber of solutions: %d", x@nsolutions))
        if (x@nsolutions > 0) {
            varlen <- soln.max.len(x@solutions, x@unknowns) + 2
            avail.width <- trunc(0.95*getOption("width"))
            if (sum(varlen) <= avail.width) { ## all unknowns fit on one line
                lsol <- list(names(x@solutions[[1]]))
                for (i in 1:x@nsolutions) lsol[[i+1]] <- x@solutions[[i]]
                                        #print(lsol);
                out <- c(out, "\nSolutions:")
                for (i in 1:length(lsol)) {
                    w <- vector("character")
                    for (j in 1:nx) {
                        w <- paste0(w,sprintf("%*s", varlen[j], lsol[[i]][j]))
                    }
                    out <- c(out, w)
                }
                out <- c(out, "")
            } else { ## print as one column
                namelen <- max(nchar(x@unknowns))
                w <- vector("character")
                for (i in 1:x@nsolutions) {
                    w <- c(w, sprintf("\nSolution %d:", i))
                    for (j in 1:nx) {
                        if (max(varlen) <= avail.width) { ## no wrap is needed
                            w <- c(w,sprintf("%*s: %*s",
                                             namelen, x@unknowns[j],
                                             varlen[j], x@solutions[[i]][j]))
                        } else { ## wrap is needed.
                            ## prefix is inserted on all split elements so insert only blanks
                            wrapped <- strwrap(x@solutions[[i]][j], width=avail.width,
                                               prefix=strrep(" ", namelen+2))
                            ## convert to a single string and insert the unknown's name
                            wrapped <- paste0(wrapped, collapse="\n")
                            substr(wrapped,1,namelen+1) <- paste0(x@unknowns[j],":")
                            w <- c(w, wrapped)
                        }
                    }
                }
                out <- c(out, w, "")

            }
        }
        out <- c(out, sprintf("Unknowns: %s", paste0(x@unknowns, collapse=",")))
        if (length(x@switches)>0)
            out <- c(out, paste0("Switches: ",  x@switches))
        writeLines(out)
}
)

##  Function: soln.max.len
##   Purpose: determine the maximum solution length for each unknown
## Arguments:
##         x: character vector of solutions
##         u: character vector of unknowns
##     Value: character vector with max length of each unknown
soln.max.len <- function(x,u){
    res <- list()
    for (i in 1:length(u)) res[[u[i]]] <- unlist(lapply(x,function (y){y[i]}))
    unlist(lapply(as.data.frame(res),\(y){max(nchar(y))}))
}

##  Function: redSolve
##   Purpose: construct solve calls, execute and call redSolve2R to parse results
## Arguments:
##        id: session id
##      eqns: character vector of equations in the system
##  unknowns: character vector of unknowns
##  switches: optional character vector of REDUCE switches relevant to solve()
##     Value: object of type redSolve
redSolve <- function(id, eqns, unknowns, switches) {
    ## check existence and type of required arguments
    if (missing(eqns) || missing(unknowns)) {
        message("error: both eqns and unknowns are required. Stopping.")
        return(FALSE)
    }
    if (missing(switches)) switches <- vector("character", 0)
    ## check that all inputs are character
    msg <- vector("character",0)
    if (!is.character(eqns)) msg <- paste0(msg, "error: eqns is not character. Stopping.")
    if (!is.character(unknowns)) {
        if (length(msg) != 0) msg <- "\n"
        msg <- paste0(msg, "error: unknowns is not character. Stopping.")
    }
    if (!is.character(switches)) {
        if (length(msg) != 0) msg <- "\n"
        msg <- paste0(msg, "error: switches is not character. Stopping.")
    }
    if (length(switches)>0 && grepl("on [^;]+nat", switches ,ignore.case = TRUE)) {
        msg <- paste0(msg, "error: switches may not turn NAT on. Stopping.")
    }
    if (length(msg) != 0) {
        message(msg)
        return(FALSE)
    }
    rm(msg)

    ## check that we have a REDUCE session
    if (!sessionRunning(id)) {
        message("There is no REDUCE session ", id)
        return(FALSE)
    }

    ## if NAT is on, turn off and call on.exit to turn it on when we are finished
    nat.check <- redExec(id, "if swget(nat) then <<swtoggle(nat);write \"NAT was on\">>;")[["out"]]
    if (any(grepl("NAT was on", nat.check))) {
        message("note: turning NAT off for duration of redSolve execution.")
        on.exit({nat.on <- redExec(id, "swtoggle(nat);")[["out"]]
            if (any(grepl("^t$", nat.on))) {message("note: NAT has been turned back on.")
            } else {message("note: failed to turn NAT back on after redSolve finished.")}
        })
    }
    ## solve & return the equations
    if (length(switches) != 0) {res <- redExec(id, switches)}
    solCall <- sprintf("solve({%s}, {%s});",
                       paste0(eqns,collapse=","), paste0(unknowns, collapse=","))
    solres <- redExec(id, solCall)

    ## parse the output and build the redcas.solve object
    rsobj <- new("redcas.solve", eqns=eqns, unknowns=unknowns, switches=switches)
    out <- gsub("\\$", "", redDropOut(solres$out, "blank"))
    ## solutions may require multiple lines ($out vector elements) so collapse
    out <- paste0(out,collapse = "")
    ## replace comma in root_of expressions with semi-colon
    out <- gsub("(root_of\\([^,]+),([^,]+),tag", "\\1;\\2;tag", out)

    ## if there are no double braces but there are commas, we are dealing with multiple
    ## solutions for a system with only one variable. In order to recognize these we
    ## replace the commas with },{ so the split works correctly
    if (!grepl("\\{\\{", out) && grepl(",", out)) {
        out <- gsub(",", "},{", out)
    }

    ## remove the double braces
    out <- gsub("\\{\\{", "{", out)
    out <- gsub("\\}\\}", "}", out)

    ## if there are no solutions we are done
    if (out == "{}") {
        rsobj@rc <- 1
        rsobj@nsolutions <- 0
        return(rsobj)
    }

    ## create the lists for the character and evaluated versions of the solutions
    solutions <- rsolutions <- list()
    root_of <- vector("complex")
    ## convert to a vector with one element per solution and remove remaining braces
    out <- unlist(strsplit(out,"},{", perl=TRUE))
    out <- gsub("\\{|\\}", "", out)
    ## split each solution into a vector with one element per unknown, move
    ## the "unknown=" to be the name of the element add the resulting
    ## vector to solution try to convert to R objects and save in
    ## rsolutions either as real, complex or expression. For this we need
    ## the regular expessions for identifying real and complex numbers
    re.real <- "^([a-z]=)?( ?[0-9.+-]+)$"
    re.comp <- "^([a-z]=)?( ?[+-]? ?[0-9.]*\\*i)?( ?[+-] ?[0-9.]+)?$"
    for (j in 1:length(out)) {
        a.soln <- unlist(strsplit(out[j], ","))
        names(a.soln) <- sub("=$", "", unlist(regmatches(a.soln,gregexpr("^([a-z]+)=",a.soln))))
        a.soln <- sub("^[a-z]+=", "", a.soln)

        ## since we are now finished with spliting by comma, we can restore the commas in
        ## root_of solutions
        a.soln <- gsub("(root_of\\([^,]+);([^,]+);tag", "\\1,\\2,tag", a.soln)

        ## we can now save solutions[[j]]
        solutions[[j]] <- a.soln
        find.root_of <- which(grepl("root_of\\(", solutions[[j]]))
        if (length(find.root_of)>0)
            for (r in find.root_of) root_of <- c(root_of, complex(real=j, imaginary=r))
        
        ## if solution contains indeterminates, need to return as string because,
        ## e.g. eval will use a value of the variable if present and will complain about
        ## object not found if it doesn't exist.  Since not all solutions will be of the
        ## same type in R (could be real, complex or expression, we return a list for
        ## rsolutions. We also move the variable name from the string to the item name -
        ## otherwise eval will replace a variable of the same name.

        ## TODO: provide a separate function which can be called on the redcas.solve
        ## object produced by this function. This could use eval(str2*()) in try/catch and
        ## if it fails return the string. It can also encourage the user to pass values
        ## for the indeterminates. Here we only convert numeric or complex value.
        a.soln <- lapply(a.soln,
                         function(x){
                             ## after modifying a complex, re.comp no longer matches so save
                             ist.real <- grepl(re.real, x)
                             ist.comp <- grepl(re.comp, x)

                             ## i is a reserved word in REDUCE and uses n*i whereas R used ni
                             if (ist.comp) x <- sub("*i", "i", x, fixed=TRUE)

                             ## convert arb* operators to variables
                             if (grepl("(arbcomplex|arbint)\\([0-9]+\\)", x)) {
                                 x <- gsub("(arbcomplex|arbint)\\(([0-9]+)\\)", "\\1\\2", x)
                             }
                             ## eval real and complex numbers expressed explicitly
                             if (ist.real || ist.comp) {
                                 x <- eval(str2expression(x))
                             } 
                             return(x)
                         }) 
                            
        rsolutions[[j]] <- a.soln
    }
    rsobj@solutions <- solutions
    rsobj@rsolutions <- rsolutions
    rsobj@nsolutions <- length(solutions)       ## can the object do this? Y but only on init
    rsobj@root_of <- root_of
    rsobj@rc <- 0

    return(rsobj)
    
}

