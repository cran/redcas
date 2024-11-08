## $Id: 190-redSolve.R,v 1.4 2024/10/19 13:49:34 mg Exp $
## Purpose: Tests for redSolve()
##    Note: created by redSolve-test.R from redSolve-test.txt

library(redcas)
source("data/test-utils.R")

## it does not make sense to run these tests  if there is neither redcsl nor redpsl
do.csl <- class(redcas:::getReduceExec("csl")) != "logical"
do.psl <- class(redcas:::getReduceExec("psl")) != "logical"
if (do.csl == FALSE && do.psl == FALSE) {
    writeLines("Skipping test execution because neither redcsl nor redpsl was found.")
    q("no")
}

source("data/190-redSolve-expect.R")    # build expected list
ntests <- 27
expect <- list()
actual <- list()

if (do.csl) {
    r0 <- redStart()
    if (r0 == 0) {
        writeLines("failed to start csl session. All csl tests will be skipped.")
    } else {
        expect <- exptmpl
        
        r1 <- redExec(r0, c("on echo; off nat;"))

        ## Test No.:01 error: both eqns and unknowns are required. Stopping.
        actual[[1]] <- capture.output(redSolve(id=r0, eqns=c("x+y", "x-y=8")   ), type="message")
        
        ## Test No.:02 error: both eqns and unknowns are required. Stopping.
        actual[[2]] <- capture.output(redSolve(id=r0,  unknowns=c("x"), switch=c("on rounded;") ), type="message")
        
        ## Test No.:03 error: eqns is not character. Stopping.
        actual[[3]] <- capture.output(redSolve(id=r0, eqns=c(1,2,3), unknowns=c("x"), switch=c("on rounded;") ), type="message")
        
        ## Test No.:04 error: unknowns is not character. Stopping.
        actual[[4]] <- capture.output(redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c(1,2)  ), type="message")
        
        ## Test No.:05 error: switch is not character. Stopping.
        actual[[5]] <- capture.output(redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y"), switch=c(55) ), type="message")
        
        ## Test No.:06 error: switch may not turn NAT on. Stopping.
        actual[[6]] <- capture.output(redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y"), switch=c("on echo, nat, exp;") ), type="message")
        
        ## Test No.:07 check turning off NAT. rsobj07 to avoid result in capture
        redExec(r0,"on nat;");actual[[7]] <- capture.output(rsobj07 <-redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y")  ), type="message")
        
        ## Test No.:08 2 eqn, 2 unknown, order 1
        redExec(r0,"off nat;");actual[[8]] <- redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y")  )
        
        ## Test No.:09 1 eqn, 1 unknown, order 7, root_of
        actual[[9]] <- redSolve(id=r0, eqns=c("x^7-x^6+x^2=1"), unknowns=c("x")  )
        
        ## Test No.:10 1 eqn, 1 unknown, order 2, off multiplicities
        actual[[10]] <- redSolve(id=r0, eqns=c("x^2=2x-1"), unknowns=c("x")  )
        
        ## Test No.:11 1 eqn, 1 unknown, order 2, on multiplicities
        actual[[11]] <- redSolve(id=r0, eqns=c("x^2=2x-1"), unknowns=c("x"), switch=c("on multiplicities;") )
        
        ## Test No.:12 1 eqn, 1 unknown, order 2, unknown redundant, no solution
        actual[[12]] <- redSolve(id=r0, eqns=c("x=2*z", "z=2*y"), unknowns=c("z")  )
        
        ## Test No.:13 2 eqn, 2 unknown, order 1, no solution
        actual[[13]] <- redSolve(id=r0, eqns=c("x = a", "x = b", "y = c", "y = d"), unknowns=c("x", "y")  )
        
        ## Test No.:14 2 eqn, 2 unknown, order 1, no unknown, no solution
        actual[[14]] <- redSolve(id=r0, eqns=c("x2 = a", "x2 = b", "y2 = c", "y2 = d"), unknowns=c("x", "y")  )
        
        ## Test No.:15 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
        actual[[15]] <- redSolve(id=r0, eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z^2"), unknowns=c("x", "y", "z"), switch=c("on rounded;") )
        
        ## Test No.:16 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
        actual[[16]] <- redSolve(id=r0, eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"), unknowns=c("x", "y", "z")  )
        
        ## Test No.:17 3 eqn, 3 unknown, order 2, off rounded, 4 solutions with NaN;
        actual[[17]] <- redSolve(id=r0, eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"), unknowns=c("x", "y", "z"), switch=c("off rounded;") )
        
        ## Test No.:18 1 eqn, 1 unknown, order 2, indeterminate coeff, 2 solutions
        actual[[18]] <- redSolve(id=r0, eqns=c("a*x^2 + 2*b*x + c"), unknowns=c("x")  )
        
        ## Test No.:19 2 eqn, 2 unknown, order 1, 1 solution
        actual[[19]] <- redSolve(id=r0, eqns=c("x + y = 8", "x - y = 0"), unknowns=c("x", "y")  )
        
        ## Test No.:20 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
        actual[[20]] <- redSolve(id=r0, eqns=c("a*x + b*y=8", "x - y=0"), unknowns=c("x", "y")  )
        
        ## Test No.:21 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
        actual[[21]] <- redSolve(id=r0, eqns=c("a*x + b*y=8", "x - b*y=0"), unknowns=c("x", "y")  )
        
        ## Test No.:22 2 eqn, 2 unknown, order 2, degenerate, arbcomplex, 1 solution
        actual[[22]] <- redSolve(id=r0, eqns=c("a*x^2 + b*xy + c"), unknowns=c("x", "y")  )
        
        ## Test No.:23 2 eqn, 2 unknown, o(2), off rounded - root_of, 2 solutions
        actual[[23]] <- redSolve(id=r0, eqns=c("x^7-x^6+x^2+y=1", "y+x=0"), unknowns=c("x", "y"), switch=c("off rounded;") )
        
        ## Test No.:24 complex solution multi-column
        options(width=100);actual[[24]] <- capture.output(print(actual[[16]]))
        
        ## Test No.:25 complex solution single column
        options(width=70) ;actual[[25]] <- capture.output(print(actual[[16]]))
        
        ## Test No.:26 expression solution single column, no wrap
        options(width=100);actual[[26]] <- capture.output(print(actual[[17]]))
        
        ## Test No.:27 expression solution single column, wrap
        options(width=70) ;actual[[27]] <- capture.output(print(actual[[17]]))
        
        redClose(r0, "190-redSolve.clg")
    } ## r0 == 0
} ## do.csl

if (do.psl) {
    r0 <- redStart()
    if (r0 == 0) {
        writeLines("failed to start psl session. All psl tests will be skipped.")
    } else {
        expect <- c(expect, exptmpl)

        r1 <- redExec(r0, c("on echo; off nat;"))

        ## Test No.:28 error: both eqns and unknowns are required. Stopping.
        actual[[1+ntests]] <- capture.output(redSolve(id=r0, eqns=c("x+y", "x-y=8")   ), type="message")
        
        ## Test No.:29 error: both eqns and unknowns are required. Stopping.
        actual[[2+ntests]] <- capture.output(redSolve(id=r0,  unknowns=c("x"), switch=c("on rounded;") ), type="message")
        
        ## Test No.:30 error: eqns is not character. Stopping.
        actual[[3+ntests]] <- capture.output(redSolve(id=r0, eqns=c(1,2,3), unknowns=c("x"), switch=c("on rounded;") ), type="message")
        
        ## Test No.:31 error: unknowns is not character. Stopping.
        actual[[4+ntests]] <- capture.output(redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c(1,2)  ), type="message")
        
        ## Test No.:32 error: switch is not character. Stopping.
        actual[[5+ntests]] <- capture.output(redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y"), switch=c(55) ), type="message")
        
        ## Test No.:33 error: switch may not turn NAT on. Stopping.
        actual[[6+ntests]] <- capture.output(redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y"), switch=c("on echo, nat, exp;") ), type="message")
        
        ## Test No.:34 check turning off NAT. rsobj07 to avoid result in capture
        redExec(r0,"on nat;");actual[[7+ntests]] <- capture.output(rsobj07 <-redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y")  ), type="message")
        
        ## Test No.:35 2 eqn, 2 unknown, order 1
        redExec(r0,"off nat;");actual[[8+ntests]] <- redSolve(id=r0, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y")  )
        
        ## Test No.:36 1 eqn, 1 unknown, order 7, root_of
        actual[[9+ntests]] <- redSolve(id=r0, eqns=c("x^7-x^6+x^2=1"), unknowns=c("x")  )
        
        ## Test No.:37 1 eqn, 1 unknown, order 2, off multiplicities
        actual[[10+ntests]] <- redSolve(id=r0, eqns=c("x^2=2x-1"), unknowns=c("x")  )
        
        ## Test No.:38 1 eqn, 1 unknown, order 2, on multiplicities
        actual[[11+ntests]] <- redSolve(id=r0, eqns=c("x^2=2x-1"), unknowns=c("x"), switch=c("on multiplicities;") )
        
        ## Test No.:39 1 eqn, 1 unknown, order 2, unknown redundant, no solution
        actual[[12+ntests]] <- redSolve(id=r0, eqns=c("x=2*z", "z=2*y"), unknowns=c("z")  )
        
        ## Test No.:40 2 eqn, 2 unknown, order 1, no solution
        actual[[13+ntests]] <- redSolve(id=r0, eqns=c("x = a", "x = b", "y = c", "y = d"), unknowns=c("x", "y")  )
        
        ## Test No.:41 2 eqn, 2 unknown, order 1, no unknown, no solution
        actual[[14+ntests]] <- redSolve(id=r0, eqns=c("x2 = a", "x2 = b", "y2 = c", "y2 = d"), unknowns=c("x", "y")  )
        
        ## Test No.:42 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
        actual[[15+ntests]] <- redSolve(id=r0, eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z^2"), unknowns=c("x", "y", "z"), switch=c("on rounded;") )
        
        ## Test No.:43 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
        actual[[16+ntests]] <- redSolve(id=r0, eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"), unknowns=c("x", "y", "z")  )
        
        ## Test No.:44 3 eqn, 3 unknown, order 2, off rounded, 4 solutions with NaN;
        actual[[17+ntests]] <- redSolve(id=r0, eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"), unknowns=c("x", "y", "z"), switch=c("off rounded;") )
        
        ## Test No.:45 1 eqn, 1 unknown, order 2, indeterminate coeff, 2 solutions
        actual[[18+ntests]] <- redSolve(id=r0, eqns=c("a*x^2 + 2*b*x + c"), unknowns=c("x")  )
        
        ## Test No.:46 2 eqn, 2 unknown, order 1, 1 solution
        actual[[19+ntests]] <- redSolve(id=r0, eqns=c("x + y = 8", "x - y = 0"), unknowns=c("x", "y")  )
        
        ## Test No.:47 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
        actual[[20+ntests]] <- redSolve(id=r0, eqns=c("a*x + b*y=8", "x - y=0"), unknowns=c("x", "y")  )
        
        ## Test No.:48 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
        actual[[21+ntests]] <- redSolve(id=r0, eqns=c("a*x + b*y=8", "x - b*y=0"), unknowns=c("x", "y")  )
        
        ## Test No.:49 2 eqn, 2 unknown, order 2, degenerate, arbcomplex, 1 solution
        actual[[22+ntests]] <- redSolve(id=r0, eqns=c("a*x^2 + b*xy + c"), unknowns=c("x", "y")  )
        
        ## Test No.:50 2 eqn, 2 unknown, o(2), off rounded - root_of, 2 solutions
        actual[[23+ntests]] <- redSolve(id=r0, eqns=c("x^7-x^6+x^2+y=1", "y+x=0"), unknowns=c("x", "y"), switch=c("off rounded;") )
        
        ## Test No.:51 complex solution multi-column
        options(width=100);actual[[24+ntests]] <- capture.output(print(actual[[16]]))
        
        ## Test No.:52 complex solution single column
        options(width=70) ;actual[[25+ntests]] <- capture.output(print(actual[[16]]))
        
        ## Test No.:53 expression solution single column, no wrap
        options(width=100);actual[[26+ntests]] <- capture.output(print(actual[[17]]))
        
        ## Test No.:54 expression solution single column, wrap
        options(width=70) ;actual[[27+ntests]] <- capture.output(print(actual[[17]]))
        
        redClose(r0, "190-redSolve.plg")
    } ## r0 == 0
} ## do.psl

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('redSolve',expect,actual))

## don't save environment
q("no")
