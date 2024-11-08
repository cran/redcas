## $Id: 190-redSolve-expect.R,v 1.3 2024/10/19 13:59:35 mg Exp $

## Purpose: Expected results for redSolve tests.  This program was created
##          manually from the results of running the solve() calls directly
##          in REDUCE (we are testing redcas, not REDUCE).
##          It is sourced from 190-redSolve.R which is created by
##          190-redSolve-mk-tests.R

## $Log: 190-redSolve-expect.R,v $
## Revision 1.3  2024/10/19 13:59:35  mg
## renamed list expect to exptmpl to match streamlined execution in 190-redSolve.R
##
## Revision 1.2  2024/09/09 12:18:52  mg
## Added expected results for test checking handling solutions too long for available width
##
## Revision 1.1  2024/09/03 16:40:26  mg
## Initial version
##

## these are required for testing creation of the expected results
## library(redcas)

exptmpl <- list()

## Test No.:01 unknowns missing
exptmpl[[1]] <- "error: both eqns and unknowns are required. Stopping."

## Test No.:02 eqns missing
exptmpl[[2]] <- "error: both eqns and unknowns are required. Stopping."

## Test No.:03 eqns is not character
exptmpl[[3]] <- "error: eqns is not character. Stopping."

## Test No.:04 unknowns is not character
exptmpl[[4]] <- "error: unknowns is not character. Stopping."

## Test No.:05 switches is not character
exptmpl[[5]] <- "error: switches is not character. Stopping."

## Test No.:06 2 switches turns on NAT
exptmpl[[6]] <- "error: switches may not turn NAT on. Stopping."

## Test No.:07 NAT turned off during redSolve execution
exptmpl[[7]] <- unlist(strsplit("note: turning NAT off for duration of redSolve execution.\nnote: NAT has been turned back on.","\n"))

## Test No.:06 2 eqn, 2 unknown, order 1
exptmpl[[8]] <- new("redcas.solve", eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y"),
                   solutions=list(c(x="1", y="2")), rsolutions=list(list(x=1, y=2)),
                   nsolutions=1, rc=0)

## Test No.:07 1 eqn, 1 unknown, order 7, root_of
exptmpl[[9]] <- new("redcas.solve", eqns=c("x^7-x^6+x^2=1"), unknowns=c("x"),
                   solutions=list(c(x="root_of(x_**6 + x_ + 1,x_,tag_1)"), c(x="1")),
                   rsolutions=list(list(x="root_of(x_**6 + x_ + 1,x_,tag_1)"), list(x=1)),
                   nsolutions=2, rc=0,
                   root_of=1+1i)

## Test No.:08 1 eqn, 1 unknown, order 2, off multiplicities
exptmpl[[10]] <- new("redcas.solve", eqns=c("x^2=2x-1"), unknowns=c("x"),
                   solutions=list(c(x="1")),
                   rsolutions=list(list(x=1)),
                   nsolutions=1, rc=0)

## Test No.:09 1 eqn, 1 unknown, order 2, on multiplicities
exptmpl[[11]] <- new("redcas.solve", eqns=c("x^2=2x-1"), unknowns=c("x"),
                   switches="on multiplicities;",
                   solutions=list(c(x="1"), c(x="1")),
                   rsolutions=list(list(x=1), list(x=1)),
                   nsolutions=2, rc=0 )

## Test No.:10 1 eqn, 1 unknown, order 2, unknown redundant, no solution
exptmpl[[12]] <- new("redcas.solve", eqns=c("x=2*z", "z=2*y"), unknowns=c("z"),
                    solutions=list(),
                    rsolutions=list(),
                    nsolutions=0, rc=1 )

## Test No.:11 2 eqn, 2 unknown, order 1, no solution
exptmpl[[13]] <- new("redcas.solve", eqns=c("x = a", "x = b", "y = c", "y = d"),
                    unknowns=c("x", "y"),
                    solutions=list(),
                    rsolutions=list(),
                    nsolutions=0, rc=1)

## Test No.:12 2 eqn, 2 unknown, order 1, no unknown, no solution
exptmpl[[14]] <- new("redcas.solve", eqns=c("x2 = a", "x2 = b", "y2 = c", "y2 = d"),
                    unknowns=c("x", "y"),
                    solutions=list(),
                    rsolutions=list(),
                    nsolutions=0, rc=1)

## Test No.:13 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
exptmpl[[15]] <- new("redcas.solve", eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z^2"),
                    unknowns=c("x", "y", "z"), switches="on rounded;",
                    solutions=list(c(x="2.12132034356",y="0",z="-2.12132034356"),
                                   c(x="-2.12132034356",y="0",z="2.12132034356"),
                                   c(x="0",y="2.12132034356",z="-2.12132034356"),
                                   c(x="0",y="-2.12132034356",z="2.12132034356")),
                    rsolutions=list(list(x=2.12132034356,y=0,z=-2.12132034356),
                                   list(x=-2.12132034356,y=0,z=2.12132034356),
                                   list(x=0,y=2.12132034356,z=-2.12132034356),
                                   list(x=0,y=-2.12132034356,z=2.12132034356)),
                    nsolutions=4, rc=0)

## Test No.:14 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
exptmpl[[16]] <- new("redcas.solve", eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"),
                    unknowns=c("x", "y", "z"),
                    solutions=list(c(x="2.21495732439*i + 1.77069063257",
                                     y=" - 2.21495732439*i + 1.77069063257",z="-3.54138126515"),
                                   c(x="0.586484484994*i - 1.27069063257",
                                     y=" - 0.586484484994*i - 1.27069063257",z="2.54138126515"),
                                   c(x=" - 0.586484484994*i - 1.27069063257",
                                     y="0.586484484994*i - 1.27069063257",z="2.54138126515"),
                                   c(x=" - 2.21495732439*i + 1.77069063257",
                                     y="2.21495732439*i + 1.77069063257",z="-3.54138126515")),
                    rsolutions=list(list(x=2.21495732439i + 1.77069063257,
                                      y= - 2.21495732439i + 1.77069063257,z=-3.54138126515),
                                    list(x=0.586484484994i - 1.27069063257,
                                      y= - 0.586484484994i - 1.27069063257,z=2.54138126515),
                                    list(x= - 0.586484484994i - 1.27069063257,
                                      y=0.586484484994i - 1.27069063257,z=2.54138126515),
                                    list(x= - 2.21495732439i + 1.77069063257,
                                      y=2.21495732439i + 1.77069063257,z=-3.54138126515)),
                    nsolutions=4, rc=0)

## Test No.:15 3 eqn, 3 unknown, order 2, off rounded, 4 solutions with NaN;
exptmpl[[17]] <- new("redcas.solve", eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"),
                    unknowns=c("x", "y", "z"), switches=c("off rounded;"),
                    solutions=list(c(x="(2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     y="( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     z="( - (sqrt(37) + 1))/2"),
                                   c(x="( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     y="(2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     z="( - (sqrt(37) + 1))/2"),
                                   c(x="(2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     y="( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     z="(sqrt(37) - 1)/2"),
                                   c(x="( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     y="(2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                     z="(sqrt(37) - 1)/2")),
                    rsolutions=list(list(x="(2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      y="( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      z="( - (sqrt(37) + 1))/2"),
                                    list(x="( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      y="(2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      z="( - (sqrt(37) + 1))/2"),
                                    list(x="(2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      y="( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      z="(sqrt(37) - 1)/2"),
                                    list(x="( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      y="(2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                                      z="(sqrt(37) - 1)/2")),
                    nsolutions=4, rc=0)

## Test No.:16 1 eqn, 1 unknown, order 2, indeterminate coeff, 2 solutions
exptmpl[[18]] <- new("redcas.solve", eqns=c("a*x^2 + 2*b*x + c"), unknowns=c("x"),
                    solutions=list(c(x="(sqrt( - a*c + b**2) - b)/a"),
                                   c(x="( - (sqrt( - a*c + b**2) + b))/a")),
                    rsolutions=list(list(x="(sqrt( - a*c + b**2) - b)/a"),
                                    list(x="( - (sqrt( - a*c + b**2) + b))/a")),
                    nsolutions=2, rc=0)

## Test No.:17 2 eqn, 2 unknown, order 1, 1 solution
exptmpl[[19]] <- new("redcas.solve", eqns=c("x + y = 8", "x - y = 0"), unknowns=c("x", "y"),
                    solutions=list(c(x="4", y="4") ),
                    rsolutions=list(list(x=4, y=4)),
                    nsolutions=1, rc=0)

## Test No.:18 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
exptmpl[[20]] <- new("redcas.solve", eqns=c("a*x + b*y=8", "x - y=0"), unknowns=c("x", "y"),
                    solutions=list(c(x="8/(a + b)", y="8/(a + b)") ),
                    rsolutions=list(list(x="8/(a + b)", y="8/(a + b)") ),
                    nsolutions=1, rc=0)

## Test No.:19 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
exptmpl[[21]] <- new("redcas.solve", eqns=c("a*x + b*y=8", "x - b*y=0"), unknowns=c("x", "y"),
                    solutions=list(c(x="8/(a + 1)", y="8/(b*(a + 1))") ),
                    rsolutions=list(list(x="8/(a + 1)", y="8/(b*(a + 1))") ),
                    nsolutions=1, rc=0)

## Test No.:20 2 eqn, 2 unknown, order 2, degenerate, arbcomplex, 2 solutions
exptmpl[[22]] <- new("redcas.solve", eqns=c("a*x^2 + b*xy + c"), unknowns=c("x", "y"),
                    solutions=list(c(x="(sqrt(b*xy + c)*i)/sqrt(a)", y="arbcomplex(2)"),
                                   c(x="( - sqrt(b*xy + c)*i)/sqrt(a)", y="arbcomplex(1)")),
                    rsolutions=list(list(x="(sqrt(b*xy + c)*i)/sqrt(a)", y="arbcomplex2"),
                                    list(x="( - sqrt(b*xy + c)*i)/sqrt(a)", y="arbcomplex1")),
                    nsolutions=2, rc=0)

## Test No.:21 2 eqn, 2 unknown, o(2), off rounded - root_of, 2 solutions
exptmpl[[23]] <- new("redcas.solve", eqns=c("x^7-x^6+x^2+y=1", "y+x=0"), unknowns=c("x", "y"),
                    switches="off rounded;",
                    solutions=list(c(x=" - y", y="root_of(y_**4 + y_ - 1,y_,tag_3)"),
                                   c(x=" - y", y="root_of(y_**3 + y_**2 - 1,y_,tag_2)")),
                    rsolutions=list(list(x=" - y", y="root_of(y_**4 + y_ - 1,y_,tag_3)"),
                                    list(x=" - y", y="root_of(y_**3 + y_**2 - 1,y_,tag_2)")),
                    nsolutions=2, rc=0, root_of=c(1+2i, 2+2i))


exptmpl[[24]] <- c("Equations:",
                  "  x+y+z = 0",
                  "  x^2 + y^2 + z^2 = 9",
                  "  x^2 + y^2 = z",
                  "",
                  "Number of solutions: 4",
                  "",
                  "Solutions:",
                  "                                    x                                    y               z",
                  "      2.21495732439*i + 1.77069063257    - 2.21495732439*i + 1.77069063257  -3.54138126515",
                  "     0.586484484994*i - 1.27069063257   - 0.586484484994*i - 1.27069063257   2.54138126515",
                  "   - 0.586484484994*i - 1.27069063257     0.586484484994*i - 1.27069063257   2.54138126515",
                  "    - 2.21495732439*i + 1.77069063257      2.21495732439*i + 1.77069063257  -3.54138126515",
                  "",
                  "Unknowns: x,y,z"
                  )

exptmpl[[25]] <- c("Equations:",
                  "  x+y+z = 0",
                  "  x^2 + y^2 + z^2 = 9",
                  "  x^2 + y^2 = z",
                  "",
                  "Number of solutions: 4",
                  "",
                  "Solution 1:",
                  "x:       2.21495732439*i + 1.77069063257",
                  "y:     - 2.21495732439*i + 1.77069063257",
                  "z:   -3.54138126515",
                  "",
                  "Solution 2:",
                  "x:      0.586484484994*i - 1.27069063257",
                  "y:    - 0.586484484994*i - 1.27069063257",
                  "z:    2.54138126515",
                  "",
                  "Solution 3:",
                  "x:    - 0.586484484994*i - 1.27069063257",
                  "y:      0.586484484994*i - 1.27069063257",
                  "z:    2.54138126515",
                  "",
                  "Solution 4:",
                  "x:     - 2.21495732439*i + 1.77069063257",
                  "y:       2.21495732439*i + 1.77069063257",
                  "z:   -3.54138126515",
                  "",
                  "Unknowns: x,y,z"
                  )

exptmpl[[26]] <- c("Equations:",
                  "  x+y+z = 0",
                  "  x^2 + y^2 + z^2 = 9",
                  "  x^2 + y^2 = z",
                  "",
                  "Number of solutions: 4",
                  "",
                  "Solution 1:",
                  "x:      (2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "y:   ( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "z:   ( - (sqrt(37) + 1))/2",
                  "",
                  "Solution 2:",
                  "x:   ( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "y:      (2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "z:   ( - (sqrt(37) + 1))/2",
                  "",
                  "Solution 3:",
                  "x:         (2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "y:      ( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "z:        (sqrt(37) - 1)/2",
                  "",
                  "Solution 4:",
                  "x:      ( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "y:         (2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) + sqrt(2))/(4*sqrt(2))",
                  "z:        (sqrt(37) - 1)/2",
                  "",
                  "Unknowns: x,y,z",
                  "Switches: off rounded;")

exptmpl[[27]] <- c("Equations:",
                  "  x+y+z = 0",
                  "  x^2 + y^2 + z^2 = 9",
                  "  x^2 + y^2 = z",
                  "",
                  "Number of solutions: 4",
                  "",
                  "Solution 1:",
                  "x: (2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "y: ( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "z: ( - (sqrt(37) + 1))/2",
                  "",
                  "Solution 2:",
                  "x: ( - 2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "y: (2*sqrt( - sqrt(37) - 7)*sqrt(3) + sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "z: ( - (sqrt(37) + 1))/2",
                  "",
                  "Solution 3:",
                  "x: (2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "y: ( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "z: (sqrt(37) - 1)/2",
                  "",
                  "Solution 4:",
                  "x: ( - 2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "y: (2*sqrt(sqrt(37) - 7)*sqrt(3) - sqrt(74) +",
                  "   sqrt(2))/(4*sqrt(2))",
                  "z: (sqrt(37) - 1)/2",
                  "",
                  "Unknowns: x,y,z",
                  "Switches: off rounded;")

## Note since this is sourced by ../190-redSolve.R DO NOT quit here!
