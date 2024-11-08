\name{redSolve}
\alias{redSolve}
\title{
function to solve a system of equations using the REDUCE  \code{solve} operator
}
\description{
  \code{redSolve} generates code for the REDUCE \code{solve} operator,
executes it and converts the result to appropriate R
objects if possible.}

\usage{
redSolve(id, eqns, unknowns, switches)
}

\arguments{

  \item{id}{the session identifier returned by
    \code{\link{redStart}}. Required with no default }

  \item{eqns}{the system of equations to be solved as character vector
    with one element per equation. If equations are in the normal form
    the \code{=0} may be omitted. Required. No default.  }

  \item{unknowns}{the unknowns for the system of equations specified by
    \code{eqns} as a character vector with one element for each
    unknown. Required. No default.  }

  \item{switches}{a character vector of switches to be applied prior to
    executing \code{solve}. See Details below. Optional. }

}
\details{

\code{solve} is a REDUCE operator for solving one or more simultaneous
algebraic equations in one or more variables, both linear and
non-linear. Equations may contain arbitrary constants which is why it is
necessary to specify the unknowns. For example, given a quadratic
equation with constants \code{a, b} and \code{c}:

\preformatted{
16: solve(a*x^2 + b*x + c, x);
  
                     2
    sqrt( - 4*a*c + b ) - b
{x=-------------------------,
              2*a

                         2
     - (sqrt( - 4*a*c + b ) + b)
 x=------------------------------}
                2*a
}
The standard solution is returned as a REDUCE list.  We can change the
order of the expression to get the usual form by using the \code{korder}
declaration before calling solve:
\preformatted{
17: korder b, a;
18: solve(a*x^2 + b*x + c, x);

          2
    sqrt(b  - 4*a*c) - b
{x=----------------------,
            2*a

              2
     - (sqrt(b  - 4*a*c) + b)
 x=---------------------------}
               2*a
}

If the solve operator could not find an explicit solution, it may still
be able to find one in terms of an equation for the unknown. Such a
solution is identified by specifying the subsidiary equation as the
argument of the operator \code{root_of}. If there are several unknowns,
each solution will be a list of equations for the unknowns. For example,
\preformatted{
  solve(x^7 - x^6 + x^2 = 1, x) ;
  {x=root_of(x_**6  + x_ + 1,x_,tag_1),x=1}}

Note that \code{redSolve} turns off the NAT switch as otherwise the results will
not be parsed correctly. \code{redSolve} will ensure that NAT is off for
the duration of its execution. Turning on the NAT switch using the
\code{switches} parameter results in an error.

There are several switches related to \code{solve}, in particular
\code{cramer, multiplicities, fullroots, trigform} and \code{varopt}.
See the
\href{http://www.reduce-algebra.com/manual/manualse44.html}{REDUCE
manual section 7.17} for details of these and of the methods used for
solving equations.  }

\value{

\code{redSolve} returns an object of class
\code{"\linkS4class{redcas.solve}"} which contains the following
elements:

\describe{

  \item{solutions}{a list of the solutions as returned by
    REDUCE. Each solution is a character vector.}

  \item{rsolutions}{a list of the solutions, where possible converted to
    appropriate R objects. Because each element of a solution may be of
    a different type (real, complex, string), each solution is a list
    rather than a vector.}

  \item{nsolutions}{numeric. The number of solutions.}

  \item{rc}{numeric. The return code. 0 is success, 1 failure }

  \item{root_of}{a complex vector identifying which solutions are
    presented in terms of the REDUCE \code{root_of} operator. A solution
    may expressed one or more unknowns in terms of the roots of another
    equation. In this case the other equation is enclosed in
    \code{root_of()}. This slot is a complex vector with the real part
    identifying the solution containing \code{root_of()} and the imaginary
    part the index of the unknown in that solution. This item is
    intended for use in a future release.}

  \item{eqns}{the vector of equations passed to \code{redSolve}}
  \item{unknowns}{the vector of unknowns passed to \code{redSolve}}
  \item{switches}{the vector of switches passed to \code{redSolve}}
}
The \code{redcas.solve} object may be printed using the \code{print} method.
}


\author{
martin gregory
}

\seealso{
\code{\link{print}} to print a \code{redcas.solve} object,
\href{http://www.reduce-algebra.com/manual/manualse44.html}{REDUCE
manual section 7.17} for details of the REDUCE \code{solve} operator and
\code{\link{redStart}} for creating a REDUCE session.
}

\examples{
## Open a CSL session:
s1 <- redStart()

## can only run code if session was successfully started
if (is.numeric(s1)) {
   sol <- redSolve(s1, eqns=c("x+3y=7", "y-x=1"), unknowns=c("x", "y"))
   print(sol)

   ## close session:
   redClose(s1)
}
}
