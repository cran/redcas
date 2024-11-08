%% $Id: redOut-in-015-SplitOut.red,v 1.1 2024/09/07 15:50:37 mg Exp $
%% Purpose: create inputs for 03-Output.R tests 015, 016, 017. Expected are manually
%% 	    created from the log file. This is only run prior to building the package.
%% $Log: redOut-in-015-SplitOut.red,v $
%% Revision 1.1  2024/09/07 15:50:37  mg
%% initial version
%%

in "/data/projects/R-pkgdev/reduce/redcas/inst/reduce/redcas.red" $
swtoggle(echo) ;
if swget(echo) then write "ECHO is ON" else write "ECHO is OFF" ;
%% Purpose: check  comments are treated as commands
off exp ;
q := (x + y)^2 + 1/(x+y)^2 ;
     % a comment with white space
df(q, x) ; % a comment after command
%% comment with semi-colon at end ;
qq := q^2 ;

