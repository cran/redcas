%% $Id$

%% Purpose: explore how to get fancy working for psl. Issues are:

%%       1. without loading tmprint, tex_string is not available
%%       2. defining tex_string in redcas.red works correctly but prefix/suffix for translated
%%       items are \> and none
%%       3. after loading tmprint prompt is no longer line-no:

%% $Log$
in "redcas.red" $ %% now also load the modified tmprint-psl.red

on echo ;
operator x;
array g(3,3) ;
g(0,0) := -u^(-2);
g(1,1) := (u*x(3))^2;
g(2,2) := g(1,1) * (sin(x(1)))^2;
g(3,3) := u^2;

on nero ;

%% nat output:
arrayltx(g, "", "") ;

%% TeXmacs output with the environment dmath from breqn package
arrayltx(g, "dmath", "fancy") ;

%% fancy by switch
on fancy, fancy_tex ;
arrayltx(g, "", "") ;

%% nat after off fancy ;
off fancy, fancy_tex ;
arrayltx(g, "", "") ;
