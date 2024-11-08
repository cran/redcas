\name{redExpand}
\alias{redExpand}
\title{
Insert the content of a file into a vector
}
\description{
A vector of REDUCE commands may contain the name of a file containing
REDUCE commands. \code{redExpand} returns a vector containing the
commands up to the element containing the file name, the contents of the
file and the elements following the file name. Multiple files may be
specified in the input vector.
}
\usage{
redExpand(x)
}
\arguments{
  \item{x}{vector of commands to submit to REDUCE, possibly including
    names of files of commands to submit.    
}
}
\details{
  \code{redExpand} is called by \code{\link{redExec}} before submitting
  commands so it is generally not necessary to call it explicitly. It
  can be used if you wish do the expansion yourself. If the input vector
  elements \ifelse{latex}{\eqn{x_j},
    \eqn{x_k}}{\ifelse{html}{\out{x<sub>j</sub>, x<sub>k</sub>}}{x[j], x[k]}},
  where \ifelse{html}{\out{j &lt; k}}{\eqn{j < k}}, 
  are file references, then the output  vector will consist of
  \itemize{
    \item \ifelse{html}{\out{x<sub>1</sub>...x<sub>j-1</sub>}}{\ifelse{latex}{\eqn{x_1 \ldots x_{j-1}}}{x[1]...x[j-1]}}
    \item the contents of \ifelse{html}{\out{x<sub>j</sub>}}{\ifelse{latex}{\eqn{x_j}}{x[j]}}
    \item \ifelse{html}{\out{x<sub>j+1</sub>...x<sub>k-1</sub>}}{\ifelse{latex}{\eqn{x_{j+1} \ldots x_{k-1}}}{x[j+1]...x[k-1]}}
    \item the contents of \ifelse{html}{\out{x<sub>k</sub>}}{\ifelse{latex}{\eqn{x_k}}{x[k]}}
    \item \ifelse{html}{\out{x<sub>k+1</sub>...x<sub>n</sub>}}{\ifelse{latex}{\eqn{x_{k+1} \ldots x_{n}}}{x[k+1]...x[n]}}
  }
}
\value{
  a character vector containing the commands to submit with any file
  names replaced by their contents.
}
\author{
Martin Gregory
}

\seealso{
  \code{\link{redExec}}
}
%\examples{}
