clear; clc;

m1 = 0.5;
m2 = 0.5;
k_leaf = 1e4;
c_leaf = 0.4;
r = 0.038;

M = diag([m1 m2]);

dofs = size(M,1);

K = [k_leaf   -k_leaf;
    -k_leaf    k_leaf;];

C = [c_leaf   -c_leaf;
    -c_leaf    c_leaf;];

B = [1/r; 0;];

%% 
Minv = M \ eye(dofs);              

A = [ zeros(dofs)  eye(dofs);
     -Minv*K   -Minv*C ];

Bss = [ zeros(dofs,1);
        Minv*B ];


Css = [1 0  0 0;
       0 1  0 0];

Dss = [0; 0];

sys_ss = ss(A,Bss,Css,Dss);    

%%
G = tf(sys_ss);         

G1 = G(1);               
G2 = G(2);               

% disp('G1(s) = X1(s) / tau(s):');
% G1
% 
% disp('G2(s) = X2(s) / tau(s):');
% G2

bode(G1, G2); legend('x1/tau','x2/tau');

