
clear; clc;

m1 = 0.5;          
m2 = 0.5;          
k1 = 5e7;        
c1 = 0;          
k2 = 1000;         
c2 = 0;         
J0  = 1.53e-4;      
r  = 0.04;         


M = [ m1      0        0;
      0       m2       0;
      0       0   J0/r^2 ];

C = [ c1+c2   -c2    -c1;
     -c2      c2      0;
     -c1      0       c1 ];

K = [ k1+k2   -k2    -k1;
     -k2      k2      0;
     -k1      0       k1 ];


B = [ 0;
      0;
      1/r ];

%% 
Minv = M \ eye(3);              

A = [ zeros(3)  eye(3);
     -Minv*K   -Minv*C ];

Bss = [ zeros(3,1);
        Minv*B ];


Css = [1 0 0  0 0 0;
       0 1 0  0 0 0];

Dss = [0; 0];

sys_ss = ss(A,Bss,Css,Dss);    
%%
G = tf(sys_ss);         

G_d=c2d(G, 1/250, 'tustin')

G1 = G(1);               
G2 = G(2);               

disp('G1(s) = X1(s) / tau(s):');
G1

disp('G2(s) = X2(s) / tau(s):');
G2

% figure()
% bode(G1, G2); legend('x1/tau','x2/tau');