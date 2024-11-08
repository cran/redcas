<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
  <meta charset="utf-8" />
  <title>README</title>
  <!--link rel="stylesheet" href="../../../CRAN_web.css" /-->
</head>
<body>
<h1 id="abc">redcas - R interface to REDUCE</h1>

<!--p><a href="https://CRAN.R-project.org/package=rim"><img
src="https://cranlogs.r-pkg.org/badges/rim" /></a> <a
href="https://CRAN.R-project.org/package=rim"><img
src="https://cranlogs.r-pkg.org/badges/grand-total/rim" /></a></p-->

<p> This initial version can start an interactive REDUCE session, send REDUCE commands to
the session, retrieve and format the output of those commands and close the session. Any
REDUCE command which does not require user interaction may be executed and the output is
returned as a character vector or list of character vectors. There are also two
specialized functions which format: asltx produces LaTeX and redSolve returns the output
of the REDUCE solve operator as a custom R object.</p>

<h1 >System Requirements</h2>
In order to use <code>redcas</code> on Linux either the CSL or PSL dialect must be
installed and in the search path. For MacOS, only CSL is available. There are other
options besides the search path for finding the REDUCE executable - see the documentation
for <code>redStart()</code> for details.

REDUCE is available from <a href="http://www.reduce-algebra.com">
http://www.reduce-algebra.com</a> and has been tested with versions &gt;=6339. 

<h1 id="installation">Installation</h1>
<p>Installation is done in the usual way:</p>

<code>install.packages(&quot;redcas&quot;)</code>

<p><code>redcas</code> can be installed even if there is no REDUCE installation, but cannot
be used.</p>


<H1><a name="Testing">Testing</a></H1> The package <code>redcas</code> comes with 328
tests. if no REDUCE installation is present 46 tests involving only R code will be
executed which the remaining 282 will be skipped. A summary of the test results are
contained in the file <code>99-test-results.Rout</code> in the test output directory.

</body>
</html>
