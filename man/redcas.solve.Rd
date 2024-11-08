\name{redcas.solve}
\docType{class}
\alias{redcas.solve}
\alias{redcas.solve-class}

\title{Class \code{"redcas.solve"}}
\description{
Contains the inputs and outputs of a call to the function
\code{\link{redSolve}} which executes the REDUCE \code{solve} operator
to determine solutions to a system of algebraic equations.
}
\section{Objects from the Class}{
Objects are created by calls to the function \code{redSolve} and can be
used as input to the \code{\link{print}} method.
}

\section{Slots}{
  \describe{
    \item{\code{.Data}:}{Object of class \code{"list"} containing the
      actual data.}

    \item{\code{solutions}:}{Object of class \code{"list"}
      containing a character vector  for each solution of the system of
      equations. The character vectors have a named element for each
      unknown  with the name being the unknown and the value being the
      value of the unknown for the solution. This is essentially a copy
      of the list returned by the REDUCE \code{solve} operator. }

    \item{\code{rsolutions}:}{Object of class \code{"list"} containing a
    list for each solution converted to appropriate R types where
    possible. A vector will not suffice because the values of the
    unknowns may be of different types: integer, real, complex or
    expression. Explicit real and complex numbers are always
    converted. If the REDUCE switch \code{ROUNDED} is off, real and
    complex numbers may be expressions and may result in errors or NaN
    if conversion were attempted. }

    \item{\code{nsolutions}:}{Object of class \code{"numeric"}. The
      number of solutions }

    \item{\code{rc}:}{Object of class \code{"numeric"}. Return code from
      the \code{redSolve} call: 0 is success and 1 failure. }

    \item{\code{root_of}:}{Object of class \code{"complex"}. A solution
      may express one or more unknowns in terms of the roots of
      another equation. In this case the other equation is enclosed in
      \code{root_of()}. This slot is a complex vector with the real part
      identifying the solution contain \code{root_of()} and the
      imaginary part the index of the unknown in that solution.}

    \item{\code{eqns}:}{Object of class \code{"character"}. The system
      of equations provided to \code{redSolve} }

  \item{\code{unknowns}:}{Object of class \code{"character"}. The
      unknowns provided to \code{redSolve} }
    
    \item{\code{switches}:}{Object of class \code{"character"}. Any REDUCE
      switches set prior to executing the REDUCE \code{solve}
      function.}
  
  }
}
\section{Extends}{
Class \code{"\linkS4class{list}"}, from data part.
Class \code{"\linkS4class{vector}"}, by class "list", distance 2.
}
\section{Methods}{
A print method, \code{\link{print}}, is defined.
}
%%\references{
%%  ~~put references to the literature/web site here~~
%%}
\author{
Martin Gregory
}
%%\note{
%%  ~~further notes~~
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{redSolve}} is currently the only function using this class.

}
\examples{
showClass("redcas.solve")
}
\keyword{classes}
\usage{
redcas.solve(...)
}
\arguments{
  \item{\dots}{
    see section Slots for details.
}
}
