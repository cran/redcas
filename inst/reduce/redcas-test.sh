

#!/bin/bash
## $Id$
## Purpose: execute tests for redcas.red for both CSL and PSL and compare actual to expected values
## $Log$
##

function usage {
    echo -e "usage: $0 fn-name"
    echo -e "where fn-name is one of"
    echo -e "\tbasic"
    echo -e "\tfancy"
}

if [ -z "$1" ] ; then
    usage 
    exit 1
fi

pgm="redcas-test-arraypr-$1.red"
if [ ! -e $pgm ] ; then
    echo -e "There is no test program $pgm"
    exit 1
fi

declare -A csl psl

function basic {
    ntests=0
    for x in $tests; do let ntests=ntests+1; done
    echo "Number of tests: $ntests"

    ## first CSL
    reduce -cl $pgm
    for f in $tests ;do
	diff -sq tm_array/${prefix}${f}-expect.txt tm_array/${prefix}${f}-actual-csl.txt
	let csl[${f}]=$?
    done

    ## then PSL
    reduce -pl $pgm
    for f in $tests ;do
	diff -sq tm_array/${prefix}${f}-expect.txt tm_array/${prefix}${f}-actual-psl.txt
	let psl[${f}]=$?
    done

    let cslfail=0
    let pslfail=0
    let cslpass=0
    let pslpass=0
    for x in ${csl[*]} ; do
	if ((x==0)); then let cslpass=cslpass+1;
	else let cslfail=cslfail+1;
	fi;
    done
    for x in ${psl[*]} ; do
	if ((x==0)); then let pslpass=pslpass+1;
	else let pslfail=pslfail+1;
	fi;
    done

    let cslskip=ntests-cslfail-cslpass
    let pslskip=ntests-pslfail-pslpass
    echo -e "CSL: $cslpass passed, $cslfail failed, $cslskip skipped"
    echo -e "PSL: $pslpass passed, $pslfail failed, $pslskip skipped"
}

function fancy {
    echo "running fancy"
    testno=([1]=1 [2]=2 [3]=3 [4]=4 [5]=5 [6]=6)
    nlines=([1]=14 [2]=13 [3]=5 [4]=14 [5]=10 [6]=3)
    ntests=${#testno[*]}
    echo $ntests
    for dialect in c p; do
	let pass=0; let fail=0 ;
	reduce -$dialect -l $pgm
	for ((i=1; i<$ntests+1; i=i+1)) ; do
	    ## extract the output of arraypr
	    actual=tm_array/${prefix}${testno[$i]}-actual-${dialect}sl.txt
	    expect=tm_array/${prefix}${testno[$i]}-expect.txt
	    grep -A ${nlines[$i]} "TEST ${testno[$i]}" ${pgm%%.*}.${dialect}lg |\
		egrep -v "^ *[0-9]+:" > $actual
	    ## compare to expected
	    diff -sq $expect $actual
	    if [ "$?" == "0" ] ; then let pass=pass+1; else let fail=fail+1; fi
	done
	if [ "$dialect" == "c" ] ; then let cslpass=pass; let cslfail=fail
	else let pslpass=pass; let pslfail=fail
	fi
    done
    let cslskip=$ntests-cslfail-cslpass
    let pslskip=$ntests-pslfail-pslpass
    echo -e "CSL: $cslpass passed, $cslfail failed, $cslskip skipped"
    echo -e "PSL: $pslpass passed, $pslfail failed, $pslskip skipped"
}

case $1 in
    "basic") tests="01 a  b c d e f g h i j" ;
	       prefix=tm ;
	       basic ;;
    "fancy") prefix=fancy ;
	     fancy ;;
    ?) usage; exit 1 ;;
esac
