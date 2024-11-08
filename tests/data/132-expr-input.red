%% $Id: 132-expr-input.red,v 1.1 2024/09/04 11:27:36 mg Exp $
%% Purpose: define/calculate expressions for testing asltx/exprltx
%% $Log: 132-expr-input.red,v $
%% Revision 1.1  2024/09/04 11:27:36  mg
%% initial version
%%

xe := (a + b)^2 ;
xf := (a + b +1)^2 ;
ye := df(xe, a)/xe ;
yf := df(xf, a)/xf ;
ze := a**4 + 4*a**3*b + 6*a**2*b**2 + 4*a*b**3 + b**4 ;
zf := a^4 + 4*a^3*b + 8*a^2*b^2 + 4*a*b^3 + b^4 ;
;end;
