\name{redCodeDir}
\alias{redCodeDir}
\title{
Retrieve the directory containing the REDUCE code which is part of \code{redcas}. 
}
\description{
  \code{redCodeDir} retrieves the full path to the directory containing
  the REDUCE code which is part of \code{redcas}. 
}
\usage{
redCodeDir()
}

\details{
In addition to returning the REDUCE code directory, \code{redCodedir}
assigns three environment variables:
\describe{
  \item{REDCODEDIR}{the full path to the directory containing the REDUCE
    code which is the \code{reduce} sub-directory of the \code{redcas}
    package; 
  }
  \item{REDCAS_CODE_PATH}{the full path to the program \code{redcas.red}
    which defines REDUCE procedures used by \code{redcas};
  }
  \item{TMPRINT_PSL_PATH}{the full path to the program \code{tmprint-psl.red}
    which makes a modified version of the REDUCE package TMPRINT which
    implements \LaTeX rendering for the PSL dialect. The change is minor
    and is designed to ensure that the TeXmacs markup is identical to
    that of CSL.
  }
}
You can use the two programs directly in REDUCE. You need only load
\code{redcas.red} as it loads \code{tmprint-psl.red} if executing in
PSL. In order to have \code{tmprint-psl.red} loaded, you must assign the
environment variable \code{TMPRINT_PSL_PATH} before starting
REDUCE. 
}
\value{
\code{redCodeDir} returns the full path to the directory containing
  the REDUCE code which is part of \code{redcas}.
}
\author{
martin gregory
}

\examples{
redCodeDir()
Sys.getenv("REDCAS_CODE_PATH")
Sys.getenv("TMPRINT_PSL_PATH")
}
