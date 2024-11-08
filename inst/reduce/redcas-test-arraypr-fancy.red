%% $Id$

%% Purpose: Test 

%% $Log$
%load_package tmprint ;
in "redcas.red" $
on echo ;
operator x;
array g(3,3) ;
off echo ;
g(0,0) := -u^(-2); g(1,1) := (u*x(3))^2;
g(2,2) := g(1,1) * (sin(x(1)))^2; g(3,3) := u^2;
on echo ;
on nero ;
%% TEST 1: nat output
arraypr(g, "", "") ;
%% TEST 2: dmath, fancy
arraypr(g, "dmath", "fancy") ;
%% fancy by switch
on fancy, fancy_tex ;
%% TEST 3: nodmath, fancy switch
arraypr(g, "", "") ; 
off fancy, fancy_tex ;
%% TEST 4: nat after off fancy ;
arraypr(g, "", "") ; 

