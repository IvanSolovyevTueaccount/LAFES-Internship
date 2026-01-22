clear; clc;

m1 = 0.4;          
m2 = 0.75; 
J0 = 4e-4;
r  = 0.04;

k_b = 6e5; 
c_b = 6.5;     
k_l = 7e3;
c_l = 10;

M = diag([ J0/r^2, m1, m2 ]);

dofs = size(M,2);

K = [ k_b  -k_b          0                  
     -k_b   k_b + k_l   -k_l
      0    -k_l          k_l ];

C = [ c_b  -c_b          0                  
     -c_b   c_b + c_l   -c_l
      0    -c_l          c_l ];

B = [ 1/(2*r); 0; 0 ];

Minv = inv(M);

A = [ zeros(dofs)        eye(dofs);
     -Minv * K     -Minv * C ];

Bss = [ zeros(dofs,1);
        Minv * B ];

Css = [ 1 0 0  0 0 0;
        0 0 1  0 0 0 ];

Dss = zeros(2,1);

sys = ss(A,Bss,Css,Dss);

G = tf(sys);

G1 = G(1);
G2 = G(2);

figure(1)
bode(G1, G2);