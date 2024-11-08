off echo ;
COMMENT---------------------------------------------------------------------------------
  Module:	chris.red
Function:	calculate Christoffel symbol of first and second kind.
  Author:	Martin Gregory
    Date:	July 1979
---------------------------------------------------------------------------------------;
for i:=0:3 do h(i,i) := 1 / g(i,i) ;
for all i,j such that i neq j let df(z(i),z(j)) = 0 ;
for i:=0:3 do for j:=i:3 do for k:=0:3 do
    cs1(j,i,k) := cs1(i,j,k) := (df(g(i,k),z(j)) + df(g(k,j),z(i)) - df(g(i,j),z(k))) / 2 ;
for i:=0:3 do for j:=i:3 do for k:=0:3 do
    cs2(j,i,k) := cs2(i,j,k) := for p:=0:3 sum cs1(i,j,p) * h(p,k) ;
;end;

