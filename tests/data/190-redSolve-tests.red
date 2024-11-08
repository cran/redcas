%% $Id: 190-redSolve-tests.red,v 1.2 2024/10/05 15:12:43 mg Exp $
%% Purpose: Expected results for redSove tests, created by REDUCE.
%%
off nat; on echo ;
% Test No.:06 error: switch may not turn NAT on. Stopping.
"on echo, nat, exp;"
solve({"x+3y=7", "y-x=1"},{"x", "y"});

% Test No.:07 check turning off NAT. rsobj07 to avoid result in capture
solve({"x+3y=7", "y-x=1"},{"x", "y"});

% Test No.:08 2 eqn, 2 unknown, order 1
solve({"x+3y=7", "y-x=1"},{"x", "y"});

% Test No.:09 1 eqn, 1 unknown, order 7, root_of
solve({"x^7-x^6+x^2=1"},{"x"});

% Test No.:10 1 eqn, 1 unknown, order 2, off multiplicities
solve({"x^2=2x-1"},{"x"});

% Test No.:11 1 eqn, 1 unknown, order 2, on multiplicities
"on multiplicities;"
solve({"x^2=2x-1"},{"x"});

% Test No.:12 1 eqn, 1 unknown, order 2, unknown redundant, no solution
solve({"x=2*z", "z=2*y"},{"z"});

% Test No.:13 2 eqn, 2 unknown, order 1, no solution
solve({"x = a", "x = b", "y = c", "y = d"},{"x", "y"});

% Test No.:14 2 eqn, 2 unknown, order 1, no unknown, no solution
solve({"x2 = a", "x2 = b", "y2 = c", "y2 = d"},{"x", "y"});

% Test No.:15 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
"on rounded;"
solve({"x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z^2"},{"x", "y", "z"});

% Test No.:16 3 eqn, 3 unknown, order 2, on rounded, 4 solutions
solve({"x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"},{"x", "y", "z"});

% Test No.:17 3 eqn, 3 unknown, order 2, off rounded, 4 solutions with NaN;
"off rounded;"
solve({"x+y+z = 0", "x^2 + y^2 + z^2 = 9", "x^2 + y^2 = z"},{"x", "y", "z"});

% Test No.:18 1 eqn, 1 unknown, order 2, indeterminate coeff, 2 solutions
solve({"a*x^2 + 2*b*x + c"},{"x"});

% Test No.:19 2 eqn, 2 unknown, order 1, 1 solution
solve({"x + y = 8", "x - y = 0"},{"x", "y"});

% Test No.:20 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
solve({"a*x + b*y=8", "x - y=0"},{"x", "y"});

% Test No.:21 2 eqn, 2 unknown, order 2, indeterminate coeff, 1 solution
solve({"a*x + b*y=8", "x - b*y=0"},{"x", "y"});

% Test No.:22 2 eqn, 2 unknown, order 2, degenerate, arbcomplex, 1 solution
solve({"a*x^2 + b*xy + c"},{"x", "y"});

% Test No.:23 2 eqn, 2 unknown, o(2), off rounded - root_of, 2 solutions
"off rounded;"
solve({"x^7-x^6+x^2+y=1", "y+x=0"},{"x", "y"});

