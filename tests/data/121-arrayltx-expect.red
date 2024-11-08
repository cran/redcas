%% $Id: 121-arrayltx-expect.red,v 1.1 2024/09/04 11:25:32 mg Exp $

%% Purpose: generate expected results for redcas-test-fancy.red

%% $Log: 121-arrayltx-expect.red,v $
%% Revision 1.1  2024/09/04 11:25:32  mg
%% initial version
%%
in "../../inst/reduce/redcas.red" $
in "122-arrayltx-input.red" $
on echo ;
on nero ;

%% TEST 1
for i:=0:3 do <<
   idx:=concat(itoa(i), concat(",", itoa(i))) ;
   if g(i,i) neq 0 then write "g", "(", idx, ") := ", g(i,i) >>;

on fancy, fancy_tex ;
%% TEST 2
for i:=0:3 do <<
   idx:=concat(itoa(i), concat(",", itoa(i))) ;
   write tex_string("\begin{dmath}") ;
   if g(i,i) neq 0 then write "g", "(", idx, ") := ", g(i,i) ;
   write tex_string("\end{dmath}") >>;

%% TEST 3
for i:=0:3 do <<
   idx:=concat(itoa(i), concat(",", itoa(i))) ;
   if g(i,i) neq 0 then write "g", "(", idx, ") := ", g(i,i) >>;

off fancy ;
%% TEST 4
for i:=0:3 do <<
   idx:=concat(itoa(i), concat(",", itoa(i))) ;
   if g(i,i) neq 0 then write "g", "(", idx, ") := ", g(i,i) >>;

on fancy, fancy_tex ;
%% TEST 5
for i:=0:3 do for j:=0:3 do for k:=0:3 do <<
   idx:=concat(itoa(i), concat(",", concat(itoa(j), concat(",", itoa(k))))) ;
   if cs1(i,j,k) neq 0 then write "cs1", "(", idx, ") := ", cs1(i,j,k) >>;

%% TEST 6
for i:=0:2 do for j:=0:2 do <<
   idx:=concat(itoa(i), concat(",", itoa(j))) ;
   if kplus(i,j) neq 0 then write "kplus", "(", idx, ") := ", kplus(i,j) >>;
