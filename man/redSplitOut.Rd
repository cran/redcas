\name{redSplitOut}
\alias{redSplitOut}
\title{
  convert the vector returned by redExec into commands and command output.
}
\description{
REDUCE output contains both the commands issued and the output from the
commands. Since the output is of interest, redSplitOut separates the
input vector into a list containing vectors of output, commands and the
input to \code{redSplitOut}.
}
\usage{
redSplitOut(x)
}
\arguments{
  \item{x}{a character vector containing REDUCE output}
}
\details{
Although it is possible to use the REDUCE switch ECHO to prevent display
of commands, this does not prevent display of the sequence numbers for
the commands. \code{redSplitOut} can be called by \code{\link{redExec}} to
separate the output from the commands. It can also be used after the
call if the \code{split} option was not used or on an arbitrary output
file from REDUCE, for example the full output which can be retrieved by
\code{\link{redClose}}.

}
\value{
A list containing three elements:
  \item{out}{the command output}
  \item{cmd}{the commands}
  \item{raw}{the input to \code{redSplitOut}, i.e. the combined cmd and
    out vectors.}
}
\author{
  Martin Gregory
}
\seealso{
\code{\link{redExec}}
}
\examples{
result <- c("5: ",
            "{x=-1}",
            "",
            "6: ",
            "b := {{2,12},{11,1}}",
            "",
            "7: ",
            "8: ",
            "               - m",
            "la := ---------------------",
            "                2       2",
            "       sqrt(v(3)  + v(2) )",
            "",
            "9: ",
            "",
            "10: ")
split <- redSplitOut(result)
writeLines(split$out)
}
