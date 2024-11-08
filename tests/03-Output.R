## $Id: 03-Output.R,v 1.4 2024/10/19 13:20:10 mg Exp $
## Purpose: tests for output handling function redDropOut, redExpand, redSplitOut, cleanAndCopy
## $Log: 03-Output.R,v $
## Revision 1.4  2024/10/19 13:20:10  mg
## added aelen function to compare lengths of expect and actual and their elements
##
## Revision 1.3  2024/09/07 15:46:48  mg
## For tests 015-017 read from data/redOut-in-015-SplitOut.clg
##
## Revision 1.2  2024/09/04 11:00:13  mg
## Added tests 015-017 to check that comments are treated as commands
##
## Revision 1.1  2024/03/05 15:42:25  mg
## replaces test-3-redOut
##
## Revision 1.1  2024/02/27 14:25:32  mg
## Initial version
##
library(redcas)
source("data/test-utils.R")

expect <- list()
actual <- list()

## redDropOut: marker
expect[[1]] <- readLines("data/redOut-ex-001-DropOut")
expect[[2]] <- readLines("data/redOut-ex-002-DropOut")
expect[[3]] <- readLines("data/redOut-ex-003-DropOut")
actual[[1]] <- redDropOut(readLines("data/redOut-in-001-DropOut"), 'marker')
actual[[2]] <- redDropOut(readLines("data/redOut-in-002-DropOut"), 'marker')
actual[[3]] <- redDropOut(readLines("data/redOut-in-003-DropOut"), 'marker')

## redDropOut: blank lines
expect[[4]] <- readLines("data/redOut-ex-004-DropOut")
expect[[5]] <- readLines("data/redOut-ex-005-DropOut")
expect[[6]] <- readLines("data/redOut-ex-006-DropOut")
actual[[4]] <- redDropOut(readLines("data/redOut-in-001-DropOut"), 'blank')
actual[[5]] <- redDropOut(readLines("data/redOut-in-002-DropOut"), 'blank')
actual[[6]] <- redDropOut(readLines("data/redOut-in-003-DropOut"), 'blank')

## redExpand
expect[[7]] <- readLines("data/redOut-ex-007-Expand")
actual[[7]] <- redExpand(readLines("data/redOut-in-007-Expand"))

## redSplitOut
expect[[8]] <- readLines("data/redOut-ex-008-SplitOut.raw")
expect[[9]] <- readLines("data/redOut-ex-008-SplitOut.cmd")
expect[[10]] <-readLines("data/redOut-ex-008-SplitOut.out")
expect[[11]] <- readLines("data/redOut-ex-011-SplitOut.raw")
expect[[12]] <- readLines("data/redOut-ex-011-SplitOut.cmd")
expect[[13]] <-readLines("data/redOut-ex-011-SplitOut.out")
expect[[15]] <- readLines("data/redOut-ex-015-SplitOut.raw")
expect[[16]] <- readLines("data/redOut-ex-016-SplitOut.cmd")
expect[[17]] <-readLines("data/redOut-ex-017-SplitOut.out")

actual008 <- redSplitOut(readLines("data/redOut-in-008-SplitOut"))
actual[[8]] <- actual008[['raw']]
actual[[9]] <- actual008[['cmd']]
actual[[10]] <- actual008[['out']]
actual011 <- redSplitOut(readLines("data/redOut-in-011-SplitOut"))
actual[[11]] <- actual011[['raw']]
actual[[12]] <- actual011[['cmd']]
actual[[13]] <- actual011[['out']]
actual015 <- redSplitOut(readLines("data/redOut-in-015-SplitOut.clg"))
actual[[15]] <- actual015[['raw']]
actual[[16]] <- actual015[['cmd']]
actual[[17]] <- actual015[['out']]

## redDropOut: marker when NAT is off
expect[[14]] <-readLines("data/redOut-ex-014-DropOut")
actual[[14]] <- redDropOut(readLines("data/redOut-in-014-DropOut"), 'marker')


## cleanAndCopy
warning("TODO: cleanAndCopy tests")

## check lengths
aelen(what=c("out", "cmd"))

print(save.results('red3Output',expect,actual))
## ensure next R session has an empty .redcas.env
q("no")
