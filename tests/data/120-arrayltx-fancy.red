%% $Id: 120-arrayltx-fancy.red,v 1.1 2024/09/04 11:25:32 mg Exp $

%% Purpose: Test 

%% $Log: 120-arrayltx-fancy.red,v $
%% Revision 1.1  2024/09/04 11:25:32  mg
%% initial version
%%

%% load the functions
redcascodepath:=lisp(getenv("REDCAS_CODE_PATH")) ;
in <<redcascodepath>> $

%% calculate tensors (pwd is ../ so need data/)
in "data/122-arrayltx-input.red" $

on echo ;
on nero ;
%% TEST 1: nat output
arrayltx(g, "", "") ;
%% TEST 2: dmath, fancy
arrayltx(g, "dmath", "fancy") ;
%% fancy by switch
on fancy, fancy_tex ;
%% TEST 3: nodmath, fancy switch
arrayltx(g, "", "") ; 
off fancy, fancy_tex ;
%% TEST 4: nat after off fancy ;
arrayltx(g, "", "") ; 
%% TEST 5: array with numeric suffix ;
arrayltx(cs1, "", "fancy") ; 
%% TEST 6: exterior second fundamental for a surface
arrayltx(kplus, "", "fancy") ; 
