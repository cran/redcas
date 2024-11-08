off echo ;
COMMENT---------------------------------------------------------------------------------
  Module:	form.red
Function:	This computes the extrinsic curvature of a hypersurface given the 
		connection coefficients of the embedding space (Christoffel symbols)	
		and the normal to the hypersurface.
  Author:	Martin Gregory
    Date:	July 1979
---------------------------------------------------------------------------------------;

for l:=0:2 do for p:=l:2 do two(p,l) := two(l,p) :=
    for i:=0:3 sum df(z(i),q(l)) * (df(n(i),q(p)) -
	for j:=0:3 sum for m:=0:3 sum n(m) * cs2(i,j,m)*df(z(j),q(p))) ;
; end ;
