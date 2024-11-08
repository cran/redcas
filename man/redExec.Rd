\name{redExec}
\alias{redExec}
\title{
execute REDUCE commands from R
}
\description{
sends a vector of commands to the REDUCE process for execution and
retrieves and formats the output.
}
\usage{
redExec(id, x, split = TRUE, drop.blank.lines = FALSE, notify=0, timeout=0)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{id}{
    session identification returned by \code{\link{redStart}}. Required.
}
  \item{x}{
    A character vector contain either the REDUCE commands to execute,
    the names of REDUCE command files or a mixture of both. Required.
}
  \item{split}{
    Logical. Should the output be split into separate vectors for echoed
    commands and for output. Default TRUE.
}
  \item{drop.blank.lines}{
    Logical. Should blank lines be removed from the output? Default FALSE.
}
  \item{notify}{
    while waiting for the REDUCE commands to complete, write a note to
    the console every \verb{notify} seconds. Default is zero which
    suppresses the message.
  }
  \item{timeout}{
    numer of seconds after which to terminate the function if it is
    still waiting for output from the REDUCE process. Default is 0
    which will never initiate termination.
  }
}
\details{
  Before submitting the vector \code{x}, \code{redExec} modifies it as
  follows:
  \itemize{
    \item inserts a ";" terminator at the start of \code{x}. This is
    required to ensure that the first command in the next submit block
    has a number. Numbers are required to distinguish commands from
    command output;
    \item replaces any file names in \code{x} with their contents. This
    means that the contents of the files are executed directly and not
    via an \code{IN} or \code{IN_TEX} command. Files are specified by
    preceding the filename with \code{file:}. A terminator is not
    required and, if present, is ignored;
    \item appends a command to \code{x} in order to set an end of block
    marker. This is required so that \code{redExec} can wait until 
    all the commands submitted have been executed. This is especially
    important for commands which run for a long time.
  }

  When reading the output from the submitted commands, \code{redExec}
  removes the end of block command and the marker it sets. 

  Care must be taken when using the \code{drop.blank.lines} option. In
  particular, if using the REDUCE \code{NAT} switch, which is the
  default, and output is not formatted for LaTeX, it may be difficult to
  read the output.

  If REDUCE prompts for input during a sumbit block, \code{redExec} will
  write an informative message, return the output and close the session,
  writing the log to the current directory.  This most likely happens if
  you use a variable as an operator but did not declare it as such. One
  way to avoid this is to turn off the switch INT which causes REDUCE to
  declare any undeclared operators it encounters. If you do this, be
  sure to turn on INT before you call \code{redClose} as otherwise the
  REDUCE session will hang. You should use the code \code{on int;;}.
  Note that both semicolons are required. Since REDUCE is run via a
  pipe, INT is on by default.

  If the last statement (element of \code{x}) is missing a terminator
  (semi-colon or dollar sign) \code{redExec} checks whether the last
  non-blank, non-comment element of the input vector has a
  terminator. If not it stops with an appropriate message and returns
  FALSE. This reduces the likelihood that \code{redExec} fails to
  return.  }

\value{
  Like R, the REDUCE log contains both commands and outputs. If split is
  TRUE a list containing the following elements is returned:
  \describe{
    \item{out}{the output of the executed commands;}
    \item{cmd}{the executed commands}
    \item{raw}{the interspersed commands and output.}
  }
  If split is FALSE, \code{redExec} returns a character vector with the
  output from the REDUCE commands. 
}
\author{
Martin Gregory
}
\seealso{
\code{\link{redStart}} for starting a REDUCE session,
  \code{\link{redSplitOut}} and   \code{\link{redDropOut}} for
  post-processing the output if the \code{split} or
  \code{drop.blank.lines} are not used.
}
\examples{
s1 <- redStart()

## can only run code if session was successfully started
if (is.numeric(s1)) {
   ## submit with neither split nor drop.blank.lines
   x1 <- c("solve((x+1)^2, x);",
	   "b:=factorize(45056);",
	   "operator v; ",
	   "la:=-m/(v(2)^2 + v(3)^2)^(1/2) ;")
   writeLines("## submit with neither split nor drop.blank.lines")
   writeLines(y1 <- redExec(s1, x1, split=FALSE))

   ## submit with split=TRUE and drop.blank.lines=TRUE
   writeLines("\n## submit with split=TRUE and drop.blank.lines=TRUE")
   writeLines(redExec(s1, x1, drop.blank.lines=TRUE)[["out"]])

   ## submit with file name in input
   tfile <- tempfile('reduce')
   writeLines(c(paste0('write "code from ', tfile, '";'),
		"b:=factorize(54056);"),
	      tfile)
   x3 <- c("la:=-m/(v(2)^2 + v(3)^2)^(1/2) ;",
	   paste0("file:",tfile))
   y3 <- redExec(s1, x3, split=TRUE)
   writeLines("\n## submit with file name in input")
   writeLines("## commands")
   writeLines(y3$cmd)
   writeLines("\n## output")
   writeLines(y3$out)
   redClose(s1)
}
}
