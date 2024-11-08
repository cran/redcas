for all i such that i neq 3 let x(i)=q(i) ;
let x(3)=(a^2 - x(2)^2)^(1/2);
for i:=2:3 do write n(i):=x(i)*e^(nu-la)/(x(2)^2 + x(3)^2)^(1/2);
file:data/redEXEC-011-and-012in.red
for i:=0:2 do for j:=i:2 do write twop(j,i):=twop(i,j):=two(i,j);
