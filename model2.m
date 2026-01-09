clear; clc;

m1 = 0.5;          
m2 = 0.5;  
J0 = 1.53e-4;      % rotor inertia
J1 = 1e-3;       % second pulley interia
r  = 0.04;

k1 = 1e6; 
c1 = 0.005;     
k2 = 1e3;       
c2 = 0.002;     

M = diag([ J0, m1, m2, J1]);

K = [ k1*r^2, -k1*r,      0     0;
     -k1*r,    k1+k2+k1, -k2   -k1*r;
      0,      -k2,        k2    0;
      0       -k1*r       0     k1*r^2];

C = [ c1*r^2, -c1*r,      0,      0;
     -c1*r,   2*c1 + c2, -c2,    -c1*r;
      0,      -c2,        c2,     0;
      0,      -c1*r,      0,      c1*r^2 ];

Bgen = [ 1; 0; 0; 0 ];

Minv = inv(M);

A = [ zeros(4)        eye(4);
     -Minv * K     -Minv * C ];

Bss = [ zeros(4,1);
        Minv * Bgen ];

Css = [ 0 1 0 0  0 0 0 0;   % x1
        0 0 1 0  0 0 0 0 ];  % x2

Dss = zeros(2,1);

sys = ss(A,Bss,Css,Dss);

G = tf(sys);

G1 = G(1);
G2 = G(2);

figure(1)
bode(G1, G2);