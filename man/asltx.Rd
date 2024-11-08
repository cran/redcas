\name{asltx}
\alias{asltx}
\title{
Convert REDUCE output to LaTeX
}
\description{
sends the name of an array or expression to the REDUCE process for
display either as is or as LaTeX using the FANCY switch. If the object
is an array, each element is printed. The LaTeX produced by REDUCE is
then post-processed to translate object names according to a map
specified by the user, to convert array arguments to indices and,
optionally, to enclose the result in a math environment specified by the
user.
}
\usage{
asltx(id, x, usermap, mathenv="", mode="fancy", notify=0, timeout=0, debug=FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{id}{
    session identification returned by \code{\link{redStart}}. Required.
  }
  \item{x}{
    A character vector with one element naming the object to display.
  }
  \item{usermap}{
    A list containing one or both of the following items:
    \describe{
      \item{ident}{a named character vector specifying translation of
	REDUCE identifiers to LaTeX names. The element name is the REDUCE
	identifier and the value the LaTeX name.}  
      \item{index}{a named character vector specifying the conversion of
	arguments to indices. The name specifies which identifier to
	process. Since this mapping is done after the identifier
	mapping, you need to use the LaTeX name for any name you have
	mapped. The value is a sequence of \code{^} and \code{_}
	characters specifiying whether the index is contravariant
	(superscript) or covariant (subscript), respectively.}
    }
    This argument is optional. Default is no user-specified translation. 
  }
  \item{mathenv}{
    Character. The name of a LaTeX math environment in which to enclose
    an expression or each element of an array. Defaults to no
    environment. This is useful for displaying the array elements in a
    subordinate math environment, for example \command{\\dmath*} within a
    \command{dgroup} environment. %% see the ? vignette for examples
  }
  \item{mode}{
    Character. Whether to display \code{x} as LaTeX (\code{"fancy"})
    or not (\code{"nat"}). Default is \code{"fancy"}. \code{""} is
    treated as \code{"nat"}.
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
  \item{debug}{Boolean. When TRUE the mappings are printed to enable
    debugging since regular expressions can be tricky. Default is FALSE. 
  }
}
\details{
  asltx  uses \code{redExec} to display the object \code{x} as
  desired by:

  \enumerate{
    \item constructing a call to the REDUCE function \code{asltx} with
    appropriate quoting of the arguments;
    \item executing this call using \link{redExec} and specifying
    \code{split=TRUE}; 
    \item applying a standard set of transformations to remove some
    non-LaTeX markup and perform some conversions on the result. See
    below;
    \item applying a set of transformations specified by the
    \code{usermap} argument. 
  }

  \subsection{Features of REDUCE conversion to LaTeX}{ REDUCE provides
    three different methods for converting output to LaTeX, the packages
    TMPRINT, RLFI and TRI. \pkg{redcas} uses the TMPRINT package which
    was designed for use with the TeXmacs editor (hence TM) and triggers
    conversion using the \code{fancy} and \code{fancy_tex}
    switches. TMPRINT was chosen because it can be easily applied to
    fragments, supports using the \command{\\frac} command, produces
    LaTeX output and is well supported. In contrast RLFI is designed to
    produce complete documents using LaTeX 2.09 syntax and does not
    support the \command{\\frac} command. TRI produces plain TeX output.

    TMPRINT supports
    \enumerate{
      \item inserting \code{\\left} and \code{\\right} in nested
      parentheses, braces and brackets;

      \item converting variables whose names are those of Greek letters
      to the corresponding LaTeX command. Capitalized names are mapped
      to the command for the capital. For example, \command{psi} is
      mapped to \command{\\psi} while \command{Psi} is mapped to
      \command{\\Psi}. There are two exceptions; \command{epsilon} and
      \command{kappa} are mapped to \command{\\varepsilon} and
      \command{\\varkappa}, respectively. If you need
      \command{\\epsilon} or \command{\\kappa} you can use the
      \code{usermap} argument;

      \item the following names are mapped to special symbols:
      \tabular{lclclcl}{
	infinity     \tab \tab \\infty    \tab \tab union        \tab \tab \\cup        \cr
	partial!-df  \tab \tab \\partial  \tab \tab member       \tab \tab \\in         \cr
	empty!-set   \tab \tab \\emptyset \tab \tab and          \tab \tab \\wedge      \cr
	not          \tab \tab \\neg      \tab \tab or           \tab \tab \\vee        \cr
	not          \tab \tab \\neg      \tab \tab when         \tab \tab |            \cr
	leq          \tab \tab \\leq      \tab \tab !*wcomma!*   \tab \tab ,\\,         \cr
	geq          \tab \tab \\geq      \tab \tab replaceby    \tab \tab \\Rightarrow \cr
	neq          \tab \tab \\neq      \tab \tab !~           \tab \tab \\forall     \cr
	intersection \tab \tab \\cap      \tab \tab              \tab \tab              \cr
      }
    }
  }
  
  \subsection{Standard transformations}{
    Standard transformations done by \code{asltx} are as follows:
    \enumerate{
      \item removal of markup used for interactive display in TeXmacs and
      which has no correspondence with LaTeX markup;
      \item replacement of REDUCE assignments \code{:=} and \code{~:=~}
      with a plain equals sign;

      \item reversing the unwanted conversion of numeric suffix to
      index. The REDUCE FANCY option assumes that a numeric suffix to a
      variable is a subscript index even when the variable is an array,
      e.g. \code{cs1(a,b)} is converted to
      \code{cs_\{1\}(a,b)}. \code{asltx} undoes this conversion. 
      
      \item removal of redundant  \code{mathrm} commands;
      \item removal of unnecessary trailing spaces from Greek capitals;
      \item replacement of \code{mathit\{Q\}} with \code{mathrm\{Q\}} where
      \code{Q} is one of the Greek capitals A, B, E, Z, H, I, M, N, O,
      P. i.e. those which have the same form as a Latin capital. This
      transformation is required to have the same type for as the
      Greek-only capitals.
    }
  }
  
  \subsection{User transformations}{

    The \code{usermap} argument allows renaming variables, converting
    arguments in REDUCE objects to indices and specifying whether
    indices are covariant or contravariant. If a LaTeX command is used
    in the map, four backslashes are required to get the single
    backslash for LaTeX because the mapping is done using regular
    expressions. For example suppose we have arrays \code{s}, \code{g},
    \code{kminus} and \code{kplus} in REDUCE and want the following
    mapping to LaTeX

    \tabular{ll}{
	REDUCE \tab LaTeX \cr
	s \tab \\Sigma \cr
	g \tab g \cr
	kminus \tab K^- \cr
	kplus \tab K^+ \cr
      }
      then the \code{ident} element of the list passed to \code{usermap}
      would be
      \preformatted{ident=c("s"="\\\\\\\\Sigma", kminus="K^-", kplus="K^\\\\+")}
      Since we are not mapping \code{g} it does not need to appear here.
      
      To illustrate mapping arguments to indices, assume that  all four
      arrays in the example above are two dimensional and \code{s} has one
      subscript and one superscript, \code{g} and \code{kminus} have two
      subscripts and \code{kplus} has two superscripts then the
      \code{index} element will be   
      \preformatted{index=c("\\\\\\\\Sigma"="_^", "g"="__", "K^-"="__", "K^\\\\+"="^^")}
      Note that the name of the \code{index} elements must be the result
      of applying the \code{ident} mapping. The names are regular
      expressions so the character \code{+} must be escaped in the names. 
  }
}

\value{
  A list containing the following elements is returned:
  \describe{
    \item{tex}{the transformed LaTeX output;}
    \item{out}{the output of the executed commands;}
    \item{cmd}{the executed commands}
    \item{raw}{the interspersed commands and output.}
  }
}
\author{
Martin Gregory
}
\seealso{
\code{\link{redExec}} for details of executing REDUCE code.
}
\examples{
## start the session
s1 <- redStart()

## can only run code if session was successfully started
if (is.numeric(s1)) {
   ## create the arrays
   redcode <- c("array g(2,2), s(3,3), kplus(2,2), kminus(2,2) ;",
		"operator x;",
		"g(0,0) := -u^(-2);",
		"g(1,1) := (u*x(3))^2;",
		"g(2,2) := g(1,1) * (sin(x(1)))^2;",
		"s(0,0) := 0;",
		"s(1,1) := df((u*x(3))^2, x(3));",
		"s(2,2) := df(g(2,2), x(1));",
		"s(3,3) := u^2;",
		"kplus(0,0) := df(g(0,0), u);",
		"kplus(1,1) := df(g(1,1), u);",
		"kplus(2,2) := df(g(2,2), u) ;",
		"kminus(0,0) := df(g(2,2), u);",
		"kminus(1,1) := df(g(1,1), u);",
		"kminus(2,2) := df(g(0,0), u) ;",
		"on nero ;"
		)

   o2 <- redExec(s1, redcode)

   ## create LaTeX output 
   writeLines(c("", asltx(s1, "g", mathenv="")[["tex"]], ""))
   writeLines(c("", asltx(s1, "s", mathenv="")[["tex"]], ""))
   writeLines(c("", asltx(s1, "kplus", mathenv="")[["tex"]], ""))
   writeLines(c("", asltx(s1, "kminus", mathenv="")[["tex"]], ""))

   ## close the session
   redClose(s1)
}
}

