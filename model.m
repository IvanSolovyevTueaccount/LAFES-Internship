clear; clc;

m1 = 0.4;          
m2 = 0.75; 
J0 = 4e-4;
r  = 0.04;

k_b = 6e5; 
c_b = 6.5;     
k_l = 7e3;
c_l = 10;
c_f = 1;
k_g = 1e-10;

f_s = 1000;

M = diag([ J0/r^2, m1, m2 ]);

K = [ k_b  -k_b          0                  
     -k_b   k_b + k_l   -k_l
      0    -k_l          k_l + k_g ];

C = [ c_b  -c_b          0                  
     -c_b   c_b + c_l   -c_l
      0    -c_l          c_l + c_f ];

B = [ 1/r; 0; 0 ];

dofs = size(M,1);

%% Build state-space system
% State vector:
% x = [q1 q2 q3 q1dot q2dot q3dot]'

A = [ zeros(dofs)      eye(dofs);
     -M\K   -M\C ];

Bss = [ zeros(dofs,1);
         M\B ];

% Output all displacements
C_out = [1 0 0 0 0 0
         0 0 1 0 0 0];

D = zeros(2,1);

sys = ss(A, Bss, C_out, D);

G1 = c2d(tf(sys(1)), 1/f_s, 'tustin')
G2 = c2d(tf(sys(2)), 1/f_s, 'tustin')
