%% $Id: 131-expr-expect.red,v 1.1 2024/09/04 11:27:35 mg Exp $

%% Purpose: generate expected results for data/130-expr.red

%% $Log: 131-expr-expect.red,v $
%% Revision 1.1  2024/09/04 11:27:35  mg
%% initial version
%%
in "../../inst/reduce/redcas.red" $
on echo ;
xe := (a + b)^2 ;
xf := (a + b +1)^2 ;
ye := df(xe, a)/xe ;
yf := df(xf, a)/xf ;

algebraic procedure mkexp (u, v, w) ;
   begin scalar pfix, sfix;
      if lisp(v = "") then write u else write concat(v," := "), u ;
      on fancy, fancy_tex ;
      tex_string("\begin{equation}") ;
      if lisp(v = "") then write u else write concat(v," := "), u ;
      tex_string("\end{equation}") ;
      if lisp(w = "") then write u else write concat(w," := "), u ;
      if lisp(w = "") then write "$", u, "$" else write concat("$", concat(w," := ")), u , "$" ;
      off fancy, fancy_tex ;
   end ;

%% TEST 1:
mkexp(xe, "xe", "xe") ;
%% TEST 2:
mkexp(xf, "", "xf") ;
%% TEST 3:
mkexp(ye, "ye", "ye") ;
%% TEST 4:
mkexp(yf, "yf", "") ;

