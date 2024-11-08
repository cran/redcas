%% Name: redOut-in-007-Expand.red
%% Purpose: input for redExpand test

let f=a^3+b^3 ;
let d=1/d ;

q1:=y^2 - x^3 + d^2*x ;
solve(y^2=x^3 - d^2*x, {x,y}) ;

%% Done: redpipe-test-01a.red
