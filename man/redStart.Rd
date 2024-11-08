\name{redStart}
\alias{redStart}
\title{
function to start a REDUCE session
}
\description{
Starts a REDUCE session using a pipe connection sending the output (log)
to a temporary file.
}
\usage{
redStart(dialect = "csl", dirpath, options, echo=FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dialect}{
    character. The version of lisp with which the REDUCE executable was
    built. Allowed values are \code{csl}, the default, or \code{psl}.  }
  \item{dirpath}{
    character. Path to a directory containing the REDUCE
    executables. Optional, see details below.}
  \item{options}{
    character. Options for the \code{csl} version. See details.
  }
  \item{echo}{boolean. Should the ECHO switch be turned on. Default is
    FALSE to match the REDUCE default. }
}
\details{
  \code{redcas} finds the REDUCE executables in two different ways. The
  first is the explicit specification of the path using the
  \code{dirpath} argument passed to the \code{redStart} function. If this
  does not contain the REDUCE executable, \code{redStart} stops executing
  on the assumption that a specific version was intended.

  The second method is used if \code{dirpath} is not specified. This
  determines the path at package load time by searching the following three
  locations in turn until the executable is found:  
  \itemize{
    \item{the environment variable REDUCE_EXEC exists and contains the
      path to a directory containing an  executable;}
    \item{the R option \code{reduce_exec} exists and contains the path
      to a directory containing the executable;}
    \item{the REDUCE executable is found in a directory named in the
      environment variable PATH.}}

  This approach provides the flexibility to have a default version while
  being able to call different versions explicitly.

  While it is possible to start a second REDUCE session without closing
  the first, garbage collection closes its connection. A future release
  will fix this issue.
  %% It is mandatory to save the session identifier returned by
  %% \code{redStart} in order to call \code{\link{redExec}} to execute
  %% code.

  \code{redStart} carries out the following actions:
  \itemize{

    \item creates the REDUCE session using a pipe connection and sending
    the REDUCE output to a temporary file (in REDUCE terminology
    referred to as a log); 
    \item registers the session, acquiring a session identifier
    \item calls \code{\link{redExec}} to load the REDUCE functions which
    are part of the package and to set the ECHO switch if requested.
    \item returns the session identifier.
  }
}

\value{
  
The session identifier which is an integer >0 if the session started
successfully. If the session could not be started, \code{redStart}
terminates using \code{stop}. If no REDUCE executable was found returns FALSE.}

\author{
martin gregory
}

\seealso{
\code{\link{showSessions}} to list active sessions and 
\code{\link{redClose}} for closing a session.
}
\examples{
## Open a CSL session:
id1 <- redStart()
## can only run code if session was successfully started
if (is.numeric(id1)) {
   ## show session details:
   print(showSessions())
   ## close session:
   redClose(id1)
}
}
