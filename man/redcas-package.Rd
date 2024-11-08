\name{redcas-package}
\alias{redcas-package}
\alias{redcas}
\docType{package}
\title{
\packageTitle{redcas}
}
\description{
\packageDescription{redcas}
}
\details{

The package allows you to start a REDUCE session
 (\code{\link{redStart}}), send one or more vectors of REDUCE commands
 to the session for execution and retrieve the
 output (\code{\link{redExec}}), render output as \LaTeX
 (\code{\link{asltx}}), and shut down the session and optionally return
 the entire output file (\code{\link{redClose}}). Output is returned as
 a list of character vectors containing the command output, the commands
 and the combined comands and output. \code{redcas} can also directly
 call the REDUCE operator for solving algebraic equations
 (\code{\link{redSolve}}), returning a \code{\link{redcas.solve}}
 object.

Several other functions are available: \code{\link{redExpand}} is called by
\code{redExec} for checking and preparing the input vector while
\code{\link{redDropOut}} and \code{\link{redSplitOut}} are called by
\code{redExec} to format the output. All three can be called
independently of \code{redExec}.

REDUCE uses a different terminology to R. Some translations:
\tabular{rl}{
  \bold{REDUCE}   \tab \bold{R} \cr
  command:   \tab statement \cr
  log: \tab transcript \cr
  operator (prefix):   \tab function \cr
  operator (infix):   \tab operator \cr
  procedure:   \tab function \cr
  switch: \tab (global) option \cr
}
}
\author{
\packageAuthor{redcas}

Maintainer: \packageMaintainer{redcas}
}
\references{
Details of the REDUCE system including extensive documentation is
available at the \href{http://www.reduce-algebra.com/}{REDUCE web site}. 
}

\keyword{ package }

\examples{
## start a session
id <- redStart()

## can only run code if session was successfully started
if (is.numeric(id)) {
   ## define vectors of REDUCE code for submission
   x1 <- "solve((x+1)^2, x);"
   x2 <- "b:=factorize(45056);"
   x3 <- c("operator v; ",
	   "la:=-m/(v(2)^2 + v(3)^2)^(1/2) ;")

   ## execute x1 and display on the output of the commands
   y1 <- redExec(id, x1)
   writeLines(y1$out)

   ## execute x2 and display first the output and then the commands
   y2 <- redExec(id, x2)
   writeLines(c(y2$out, y2$cmd))

   ## execute x3 and display the log (commands and output interspersed)
   writeLines(y3 <- redExec(id, x3, split=FALSE))

   ## close the session
   redClose(id)
   }
}
