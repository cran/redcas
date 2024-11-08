\name{showSessions}
\alias{showSessions}
\title{
function to list details for currently active REDUCE sessions.
}
\description{
For each active REDUCE session returns the full path to the REDUCE
executable and the temporary log file, the connection identifier, the
number of code blocks executed and the number of lines read from the
log so far.
}
\usage{
showSessions(id)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{id}{
    The session id for which to display the details. May be omitted. If
    none specified, display details for all sessions. The session id is
    returned by \code{\link{redStart}}. 
  }
}
\value{
  A data frame with the following columns:
  \item{id}{ integer, the session identifier;}
  \item{pcon}{integer, the input connection for the REDUCE session;}
  \item{cmd}{character, full path to the REDUCE executable;}
  \item{logname}{character, full path to the log file;}
  \item{blockn}{integer, number of blocks of REDUCE code submitted,
    i.e. number of calls to any function which sends code to REDUCE,
    currently \code{\link{redExec}}, \code{\link{asltx}} and
    \code{\link{redSolve}} ;}  
  \item{lines.read}{integer, number of lines read from the log file for
    the session.} 
}
\author{
martin gregory
}
\seealso{
\code{\link{redStart}} for creating a REDUCE session and
\code{\link{redClose}} for closing a session.

}
\examples{
## Open a PSL session:
id1 <- redStart('psl')
## can only run code if session was successfully started
if (is.numeric(id1)) {
   ## show session details:
   print(showSessions(id1))

   ## retrieve the entire transcript up to now
   writeLines(readLines(showSessions(id1)[,'logname'], warn=FALSE))

   ## close session:
   redClose(id1)
}
}
