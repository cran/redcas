% input exterior field and normal and compute 2nd fundamental forms;
la:=-m/(x(2)^2 + x(3)^2)^(1/2) ;
nu:=-((m*x(2)/(x(2)^2 + x(3)^2))^2)/2;
gp(0,0):=-e^(2*la);
gp(1,1):=-x(2)^2/gp(0,0);
gp(3,3):=gp(2,2):=e^(2*(nu-la));
for i:=0:3 do g(i,i):=gp(i,i) ;
for i:=0:3 do let z(i)=x(i) ;
file:data/redEXEC-010in.red
