1: 
2: off exp;
3: 
3: % a programme to calculate the surface energy tensor or the Curzon field in
3: % quasi-cylindrical coords. The surface is a cylinder x(0)=time, x(1)=azimuthal angle,
3: % x(2)=radial, x(3)=axial.
3: 
3: operator q, x, y, z;
4: for all i,j such that i neq j
4:    let {df (x (i), x(j)) => 0,
4:       df (y(i), y(j)) => 0,
4:       df (q(i), q(j)) => 0};
5: 
5: array g(3,3), gp(3,3), gm(3,3), h(3,3), cs1(3,3,3), cs2(3,3,3),
5:    n(3), twop(2,2), twom(2,2), two(2,2), gam(2,2), s(2,2);
6: 
6: % input exterior field and normal and compute 2nd fundamental forms;
6: la:=-m/(x(2)^2 + x(3)^2)^(1/2) ;
7: nu:=-((m*x(2)/(x(2)^2 + x(3)^2))^2)/2;
8: gp(0,0):=-e^(2*la);
9: gp(1,1):=-x(2)^2/gp(0,0);
10: gp(3,3):=gp(2,2):=e^(2*(nu-la));
11: for i:=0:3 do g(i,i):=gp(i,i) ;
12: for i:=0:3 do let z(i)=x(i) ;
13: 
13: in "chris.red";off echo ;
14: 
14: for all i such that i neq 3 let x(i)=q(i) ;
15: let x(3)=(a^2 - x(2)^2)^(1/2);
16: for i:=2:3 do write n(i):=x(i)*e^(nu-la)/(x(2)^2 + x(3)^2)^(1/2);
17: 
17: in "form.red";off echo ;
18: %% CHECKED TO HERE
18: for i:=0:2 do for j:=i:2 do write twop(j,i):=twop(i,j):=two(i,j);
19: 
19: % now we repeat the procedure for the interior metric
19: n0:=-((m*y(2)/a^2)^2)/2;
20: l0:=-m/a;
21: gm(0,0):=-e^(2*l0);
22: gm(1,1):=-y(2)^2/gm(0,0);
23: gm(2,2):=gm(3,3):=-1/gm(0,0);
24: for i:=0:3 do g(i,i):=gm(i,i);
25: for i:=0:3 do let z(i)=y(i) ;
26: in "chrisx.red";
27: for all i such that i neq 3 let y(i)=q(i);
28: for all i such that i neq 2 let df(y(3),q(i))=0;
29: f:=(e^(2*n0)/(1 - q(2)^2/a^2)-1)^(1/2);
30: df(y(3),q(2)):=f;
31: n(3):=x(3)*e^(-(l0+n0))/a;
32: n(2):=-n(3)*f;
33: in "formx.red";
34: for i:=0:2 do for j:=i:2 do write twom(j,i):=twom(i,j):=two(i,j);
35: 
35: % now compute the surface energy tensor, s
35: for p:=0:2 do
35:    for l:=p:2 do
35:       gam(l,p):=gam(p,l):=twop(p,l) - twom(p,l);
36: for p:=0:2 do
36:    for l:=p:2 do write
36:       s(l,p):=s(p,l):=gam(p,l) - gp(p,l)*(for i:=0:2 sum gam(i,i)/gp(i,i));
37: ;
39: 
39: 
