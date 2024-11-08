%% $Id: 150-asltx.red,v 1.1 2024/09/04 11:28:52 mg Exp $
%% Purpose: test functions from redcas.red
%% $Log: 150-asltx.red,v $
%% Revision 1.1  2024/09/04 11:28:52  mg
%% initial version
%%

%% load the function
redcascodepath:=lisp(getenv("REDCAS_CODE_PATH")) ;
in <<redcascodepath>> $

array testno(20) ;
if lisp_dialect() = 'psl then for i:=1:20 do testno(i):=itoa(i+20)
else <<for i:=1:9 do testno(i):=concat("0", itoa(i));
   for i:=10:20 for i:=1:20 do testno(i):=itoa(i)>>
      ;

%% calculate inputs: tensors and expressions
off output ;
in "data/122-arrayltx-input.red" $
in "data/132-expr-input.red" $
on output ;

%% display only non-zero entries
swtoggle(nero) ;

%% tests without echo
asltx_marker(g,  "dmath", "fancy", "",    "01") ;
asltx_marker(xe, "dmath", "fancy", "xe",  "02") ;
asltx_marker(g,  "",      "",      "",    "03") ;
asltx_marker(xe,  "",     "",      "xe",  "04") ;

%% tests with echo
swtoggle(echo) ;

%% LaTeX arrays
asltx_marker(g,   "dmath", "fancy", "",   "05") ;
asltx_marker(cs1, "dmath", "fancy", "",   "06") ;

%% LaTeX expressions
asltx_marker(xe,  "dmath", "fancy", "xe", "07") ;
asltx_marker(xf,  "dmath", "fancy", "xf", "08") ;
asltx_marker(ye,  "dmath", "fancy", "ye", "09") ;
asltx_marker(yf,  "dmath", "fancy", "yf", "10") ;
asltx_marker(ze,  "dmath", "fancy", "ze", "11") ;
asltx_marker(zf,  "dmath", "fancy", "zf", "12") ;

%% plain arrays
asltx_marker(g,   "",      "",      "",   "13") ;
asltx_marker(cs1, "",      "",      "",   "14") ;

%% plain expressions
asltx_marker(xe,  "",      "",      "xe", "15") ;
asltx_marker(xf,  "",      "",      "xf", "16") ;
asltx_marker(ye,  "",      "",      "ye", "17") ;
asltx_marker(yf,  "",      "",      "yf", "18") ;
asltx_marker(ze,  "",      "",      "ze", "19") ;
asltx_marker(zf,  "",      "",      "zf", "20") ;
