on echo;
off exp;

% a programme to calculate the surface energy tensor or the Curzon field in
% quasi-cylindrical coords. The surface is a cylinder x(0)=time, x(1)=azimuthal angle,
% x(2)=radial, x(3)=axial.

operator q, x, y, z;
for all i,j such that i neq j
   let {df (x (i), x(j)) => 0,
      df (y(i), y(j)) => 0,
      df (q(i), q(j)) => 0};

array g(3,3), gp(3,3), h(3,3), cs1(3,3,3), cs2(3,3,3),
   n(3), twop(2,2), two(2,2) ;
