%% $Id$
%% Purpose: test thata arraypr produces the correct elements by comparing to explicitly
%%          writing arrays with for loops. Note that writing to a file causes the fancy
%%          switches to be ignored, but we are testing arrayp, not fancy. We can test the
%%          math argument.
%% $Log$

%% load the function
in "redcas.red" $

%% function to write expected result using nested for loops
procedure prexpect (x, f) ;
   begin scalar dim ;
      dim:=length(x) ;
      out <<f>> ;
      if length(dim)=1 then for i:=0:(part(dim, 1)-1) do write  x(i) := i 
      else if length(dim)=2 then for i:=0:(part(dim, 1)-1) do for j:=0:(part(dim, 2)-1) do
	 write  x(i,j) := 10*i + 1*j 
      else if length(dim)=3 then for i:=0:(part(dim, 1)-1) do
	 for j:=0:(part(dim, 2)-1) do
         for k:=0:(part(dim, 3)-1) do write  x(i,j,k) := 100*i + 10*j + k
      else if length(dim)=4 then for i:=0:(part(dim, 1)-1) do
	 for j:=0:(part(dim, 2)-1) do
         for k:=0:(part(dim, 3)-1) do
         for u:=0:(part(dim, 4)-1) do
	    write  x(i,j,k,u) := 1000*i + 100*j + 10*k + 1*u  
      else if length(dim)=5 then for i:=0:(part(dim, 1)-1) do
	 for j:=0:(part(dim, 2)-1) do
         for k:=0:(part(dim, 3)-1) do
         for u:=0:(part(dim, 4)-1) do
         for v:=0:(part(dim, 5)-1) do
	    write  x(i,j,k,u,v) := 10000*i + 1000*j + 100*k + 10*u + 1*v
      else if length(dim)=6 then for i:=0:(part(dim, 1)-1) do
	 for j:=0:(part(dim, 2)-1) do
         for k:=0:(part(dim, 3)-1) do
         for u:=0:(part(dim, 4)-1) do
         for v:=0:(part(dim, 5)-1) do
         for w:=0:(part(dim, 6)-1) do
	    write  x(i,j,k,u,v,w) := 100000*i + 10000*j + 1000*k + 100*u + 10*v + w;
      shut <<f>> ;
   end ;

%% proc to execute tests
procedure doarraypr(x) ;
   begin scalar of ;
      of:=concat("tm_array/",
	 concat(id2string(x),
	 concat("-actual-",
	 concat(id2string(lisp_dialect()),".txt")))) ;
      out <<of>> ;
      arraypr(x, "", "") ;
      shut <<of>> ;
   end ;

%% Generate and populate test arrays
array tm01(2), tma(2), tmb(2,2), tmc(2,2,2), tmd(2,3), tme(1,1,1,1), tmf(2,4,1), tmg(3), tmh(3),
   tmi(5,4,3,2,1), tmj(1, 1, 1, 1, 1, 1);
      
off echo ;

%% array, dim 3, name ends with number ;
prexpect(tm01, "tm_array/tm01-expect.txt") ; 
%% Test
doarraypr(tm01);

%% array, dim 3
prexpect(tma, "tm_array/tma-expect.txt") ;
%% Test
doarraypr(tma);

%%  3x3 array, 
prexpect(tmb, "tm_array/tmb-expect.txt") ;
%% Test
doarraypr(tmb);

%%  3x3x3 array
prexpect(tmc, "tm_array/tmc-expect.txt") ;
%% Test
doarraypr(tmc);

%%  3x4 array, unequal dimensions
prexpect(tmd, "tm_array/tmd-expect.txt") ;
%% Test
doarraypr(tmd);

%%  2x2x2x2 array
prexpect(tme, "tm_array/tme-expect.txt") ;
%% Test
doarraypr(tme);

%% 3x5x2 array
prexpect(tmf, "tm_array/tmf-expect.txt") ;
%% Test
doarraypr(tmf);

%% 3 array, no zeros
on nero ;
prexpect(tmg, "tm_array/tmg-expect.txt") ;
%% Test
doarraypr(tmg);
off nero ;

%% 3 array, with zeros
prexpect(tmh, "tm_array/tmh-expect.txt") ;
%% Test
doarraypr(tmh);

%% 6x5x4x3x2
prexpect(tmi, "tm_array/tmi-expect.txt") ;
%% Test
doarraypr(tmi);

%% 2x 2x 2x 2x 2x 2
prexpect(tmj, "tm_array/tmj-expect.txt") ;
%% Test
doarraypr(tmj);

out t ;

