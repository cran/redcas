## $Id: 161-input.R,v 1.2 2024/10/14 16:06:52 mg Exp $
## Purpose: Generate input for 161-ltx.index.R for testing changes to avoid
##          double superscripts when an indexed item with covariant indices is raised to a
##          power
## $Log: 161-input.R,v $
## Revision 1.2  2024/10/14 16:06:52  mg
## Header incorrectly stated "expected output" instead of "input"
##
## Revision 1.1  2024/10/03 13:05:37  mg
## Initial version
##

library(redcas)

## reduce code for execution. Can't use [gG]amma as array name because of function
input <- c("operator x, h, sigma;",
           "array g(3,3), phi(2,2,2), xGamma(1,1,1,1) ;",
           "g(0,0):=-(x(0)^3)/sigma(delta);",
           "g(1,1):=x(1)^2 + x(1)*h(alpha, beta);",
           "g(2,2):=sin(x(2))^2*u^2*h(alpha,beta)^2;",
           "g(3,3):=h(2,2)*u^2;",
           "for i:=0:2 do ",
           "   phi(i,i,i):=df(g(i,i),x(i)) + df(g(3,3),u) - df(g(3,3),h(2,2));",
           "for i:=0:1 do ",
           "   xGamma(i,i,i,i):=df(g(i,i),x(i)) - df(g(3,3),u) + df(g(3,3),h(2,2));",
           "on nero;")

ide.map=c("xgamma"="\\\\Gamma")         ## note: arrays are always lower case
idx.map=c(g="__", "x"="^", "h"="^_", "\\\\sigma"="_", "\\\\phi"="^^_", "\\\\Gamma"="__^^")

s0 <- redStart()
o0 <- redExec(s0, input)
o1 <- asltx(s0, "g", list(ident=ide.map))
o2 <- asltx(s0, "phi", list(ident=ide.map))
o3 <- asltx(s0, "xGamma", list(ident=ide.map))
l1 <- list(o1$tex, o2$tex, o3$tex)
for (i in 1:3) writeLines(l1[[i]], paste0("161-input-", i, ".tex"))
redClose(s0)
