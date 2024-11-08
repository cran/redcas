\name{redDropOut}
\alias{redDropOut}
\title{
Removes certain elements from the REDUCE output.
}
\description{
Removes blank lines or the submit block end marker from the REDUCE output.
}
\usage{
redDropOut(x, what)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{
    a character vector containing REDUCE output
  }
  \item{what}{a character string describing what to
    drop. \code{what='blank'} removes blank lines, i.e. those matching
    regular expression "^$" while \code{what='marker'} removes the end
    of block marker} 
}
\details{

  \code{redDropOut} is called by \code{\link{redExec}} if the option
  \code{drop.blank.lines} is TRUE, so you generally do not need to
  call it explicity. If you have forgotten to set the option, you can
  use this function to remove blank lines.

  The purpose of \code{what='marker'} is to remove the end of block
  marker described in the details section of \code{\link{redExec}}. This
  may be useful if you need to process a REDUCE transcript not produced
  by \code{redcas}.

  When removing blank lines and the output is not LaTeX or the switch
  NAT is on, output may be difficult to read and difficult to parse.

}
\value{
  The input vector with the corresponding elements removed.
}
\author{
Martin Gregory
}


\seealso{
  \code{\link{redExec}}
}
\examples{
x <- c("first", "", "last")
## this will return elements 1 and 3:
redDropOut(x, "blank")
}
