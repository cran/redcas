\name{print}
\alias{print}
\alias{print,redcas.solve-method}
\title{Print a redcas.solve object}
\description{
\code{print.redcas.solve} is a print method for function \code{print} in
package \pkg{base}
}


\usage{
print(x, ...) %%, mode=c("text", "latex"))
}

\arguments{
  \item{x}{a \code{\link{redcas.solve}} object returned by the function
    \code{\link{redSolve}}.}

  \item{...}{ other arguments passed to print.}
}
%%  \item{mode}{whether to print plain text (default) or \LaTeX.}

\details{
\code{print.redcas.solve} displays the equations, solutions if any and
the list of unknowns and switches. The solutions displayed are those
returned from REDUCE without any transformation to R objects.

The layout depends on the length of the individual solution values and
the \code{width} option.  If there is sufficient space, the solutions
for each unknown are printed in separate columns on the same line, for
example with a width of 80, the output of the example below will be:
\preformatted{Equations:
  x+y+z = 0
  x^2 + y^2 + z^2 = 9
  x^2 + y^2 = z^2

Number of solutions: 4

Solutions:
               x               y               z
   2.12132034356               0  -2.12132034356
  -2.12132034356               0   2.12132034356
               0   2.12132034356  -2.12132034356
               0  -2.12132034356   2.12132034356

Unknowns: x,y,z
Switches:  rounded
}
If all values for a solution with not fit on a line, they are printed
below each other. With a width of 30, the solutions section would be
\preformatted{Solution 1:
x:    2.12132034356
y:                0
z:   -2.12132034356

Solution 2:
x:   -2.12132034356
y:                0
z:    2.12132034356

Solution 3:
x:                0
y:    2.12132034356
z:   -2.12132034356

Solution 4:
x:                0
y:   -2.12132034356
z:    2.12132034356
}
}

\value{
\code{print.redcas.solve} is called for its side-effect and returns NULL.
}

\examples{
## start the session
r0 <- redStart()

## can only run code if session was successfully started
if (is.numeric(r0)) {
   rsobj <- redSolve(id=r0,
		     eqns=c("x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z^2"),
		     unknowns=c("x", "y", "z"),
		     switch=c("on rounded;") )
   print(rsobj)
   redClose(r0)
}}

\keyword{methods}

