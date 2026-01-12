clear; clc;

m1 = 0.5;          
m2 = 0.5; 
m_s = 1;
J0 = 5e-4;
r  = 0.04;

k_belt = 1e7; 
c_belt = 0.01;     
k_leaf_1 = 5e3;
k_leaf_2 = 1e3;
c_leaf_1 = 0.5;
c_leaf_2 = 0.5;

M = diag([ J0, m1, m_s, m2 ]);

dofs = size(M,2);

K = [ k_belt*r^2, -k_belt*r,           0,                   0;
     -k_belt*r,    k_belt + k_leaf_1, -k_leaf_1,            0;
      0,          -k_leaf_1,           k_leaf_1+k_leaf_2,  -k_leaf_2;
      0,           0,                 -k_leaf_2,            k_leaf_2 ];

C = [ c_belt*r^2, -c_belt*r,           0,                   0;
     -c_belt*r,    c_belt + c_leaf_1, -c_leaf_1,            0;
      0,          -c_leaf_1,           c_leaf_1+c_leaf_2,  -c_leaf_2;
      0,           0,                 -c_leaf_2,            c_leaf_2 ];

Bgen = [ 1; 0; 0; 0 ];

Minv = inv(M);

A = [ zeros(dofs)        eye(dofs);
     -Minv * K     -Minv * C ];

Bss = [ zeros(dofs,1);
        Minv * Bgen ];

Css = [ 0 1 0 0  0 0 0 0;
        0 0 0 1  0 0 0 0 ];

Dss = zeros(2,1);

sys = ss(A,Bss,Css,Dss);

G = tf(sys);

G1 = G(1);
G2 = G(2);

figure(1)
bode(G1, G2);