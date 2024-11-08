\name{redClose}
\alias{redClose}
\title{
function to close a REDUCE session and optionally save the log file
}
\description{
\code{redClose} closes the connection to  the REDUCE session thereby
ending the session. If requested the log file is copied from the
temporary location to one specified by the \code{log} argument. 
}
\usage{
redClose(id, log)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{id}{the session identifier returned by
    \code{\link{redStart}}. Required with no default
}
  \item{log}{the path to the location in which to save the session's log
    file. Optional.
}
}
\details{
The session log returned by \code{redClose} includes the submit block
markers set by \code{\link{redExec}}.

In addition to closing the connection, redClose removes the session's
entry from the session registry.
}
\value{
\code{redClose} returns TRUE if the session is closed, FALSE if it does
not exist.
}
\author{
martin gregory
}

\seealso{
\code{\link{redStart}} for creating a REDUCE session and
\code{\link{showSessions}} to display the session registry.
}
\examples{
## Open a CSL session:
s1 <- redStart()
## can only run code if session was successfully started
if (is.numeric(s1)) {
   ## show session details:
   print(showSessions())
   ## close session:
   redClose(s1)
}
}
