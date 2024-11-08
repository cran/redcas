1: 1: 1: 1: 1: 1: 
2: 
3: if swget(echo) then write "ECHO is ON" else write "ECHO is OFF" ;
4: %% Purpose: check  comments are treated as commands
4: off exp ;
5: q := (x + y)^2 + 1/(x+y)^2 ;
6:      % a comment with white space
6: df(q, x) ;
 % a comment after command
7: %% comment with semi-colon at end ;
7: qq := q^2 ;
8: 
8: 
