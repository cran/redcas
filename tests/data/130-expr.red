%% $Id: 130-expr.red,v 1.1 2024/09/04 11:27:35 mg Exp $

%% Purpose: test that exprltx produces the correct results by comparing to explicitly
%%          written expressions. Note that writing to a file causes the fancy switches to
%%          be ignored, but we are testing arrayp, not fancy. We can test the math
%%          argument.

%% $Log: 130-expr.red,v $
%% Revision 1.1  2024/09/04 11:27:35  mg
%% initial version
%%

%% load the functions
redcascodepath:=lisp(getenv("REDCAS_CODE_PATH")) ;
in <<redcascodepath>> $

on echo ;

%% define expressions
in "data/132-expr-input.red" ;

%% procedure to run the test ;
algebraic procedure do_exprltx (u, v, w) ;
   begin ;
      exprltx(u, "", "nat", v) ;
      exprltx(u, "equation", "fancy", v) ;
      exprltx(u, "", "fancy", w) ;
      exprltx(u, "$", "fancy", w) ;
   end ;

%% TEST 1:
do_exprltx(xe, "xe", "xe") ;
%% TEST 2:
do_exprltx(xf, "", "xf") ;
%% TEST 3:
do_exprltx(ye, "ye", "ye") ;
%% TEST 4:
do_exprltx(yf, "yf", "") ;
