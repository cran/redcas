--%% $Id$
%% Purpose: calculate some arrays for testing redltxtm functions
%% $Log$
write "exp: ", lisp(!*exp), "factor: ", lisp(!*factor), "allfac: ", lisp(!*allfac), 
operator x, y ;
for all i,j such that i neq j
   let df (x (i), x(j)) = 0,
      df (y(i), y(j)) = 0;

array g(3,3), h(3,3), cs1(3,3,3), cs2(3,3,3), n(3), two(2,2) ;

% input exterior field and normal and compute 2nd fundamental forms;
g(0,0) := -u^(-2);
g(1,1) := (u*x(3))^2;
g(2,2) := g(1,1) * (sin(x(1)))^2;
g(3,3) := u^2;

%% calculate Christoffel symbol of first and second kind.
for i:=0:3 do h(i,i) := 1 / g(i,i) ;
%% for all i,j such that i neq j let df(x(i),x(j)) = 0 ;
for i:=0:3 do for j:=i:3 do for k:=0:3 do
    cs1(j,i,k) := cs1(i,j,k) := (df(g(i,k),x(j)) + df(g(k,j),x(i)) - df(g(i,j),x(k))) / 2 ;
for i:=0:3 do for j:=i:3 do for k:=0:3 do
    cs2(j,i,k) := cs2(i,j,k) := for p:=0:3 sum cs1(i,j,p) * h(p,k) ;

%% This computes the extrinsic curvature of a hypersurface given the connection
%% coefficients of the embedding space (Christoffel symbols) and the normal to the
%% hypersurface.

n(3) := u ;
let x(3)=a ;

for l:=0:2 do for p:=l:2 do two(p,l) := two(l,p) :=
    for i:=0:3 sum df(x(i),x(l)) * (df(n(i),x(p)) -
	for j:=0:3 sum for m:=0:3 sum n(m) * cs2(i,j,m)*df(x(j),x(p))) ;
;end;
