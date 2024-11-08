%% $Id$

%% Purpose: generate expected results for redcas-test-fancy.red

%% $Log$
in "redcas.red" $
in "redcas-test-calc.red" $

%% Test 1
for i:=0:3 do <<
   idx1:=concat(itoa(i), concat(",", itoa(i))) ;
   if g(i,i) neq 0 then write "g", "(", idx(i), ") := ", g(i,i) >>;

on fancy, fancy_tex ;
%% Test 2
for i:=0:3 do <<
   idx1:=concat(itoa(i), concat(",", itoa(i))) ;
   write tex_string("\begin{dmath}") ;
   if g(i,i) neq 0 then write "g", "(", idx(i), ") := ", g(i,i) ;
   write tex_string("\end{dmath}") >>;

%% Test 3
for i:=0:3 do <<
   idx1:=concat(itoa(i), concat(",", itoa(i))) ;
   if g(i,i) neq 0 then write "g", "(", idx(i), ") := ", g(i,i) >>;

off fancy ;
%% Test 4
for i:=0:3 do <<
   idx1:=concat(itoa(i), concat(",", itoa(i))) ;
   if g(i,i) neq 0 then write "g", "(", idx(i), ") := ", g(i,i) >>;

on fancy, fancy_tex ;
%% Test 5:
for i:=0:3 do for j:=0:3 do for k:=0:3 do <<
   idx:=concat(itoa(i), concat(",", concat(itoa(j), concat(",", itoa(k))))) ;
   if cs1(i,j,k) neq 0 then write "cs1", "(", idx, ") := ", cs1(i,j,k) >>;

%% Test 6:
for i:=0:2 do for j:=0:2 do <<
   idx:=concat(itoa(i), concat(",", itoa(j))) ;
   if two(i,j) neq 0 then write "two", "(", idx, ") := ", two(i,j) >>;
