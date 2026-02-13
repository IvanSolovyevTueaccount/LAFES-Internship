clear; clc;

m1 = 0.452;          
m2 = 0.717;          
k1 = 5.4e5;        
c1 = 5.3745;        
k2 = 5.82e3;         
c2 = 1.585;         
J0  = 3.42e-04;      
r  = 0.04;         


M = [ m1      0        0;
      0       m2       0;
      0       0   J0/r ];

C = [ c1+c2   -c2    -c1;      
     -c2      c2      0;
     -c1*r      0       c1*r ];

K = [ k1+k2   -k2    -k1;    
     -k2      k2      0;
     -k1*r      0       k1*r ];


B = [ 0;
      0;
      1/r ];

%%

%Minv = M \ eye(3);            %change this  
a1 = [C M;
      M zeros(3)];
b1 = [K zeros(3);
     zeros(3) -M];
inva = inv(a1);
S = [0;0;1;0;0;0];

Ass = -inva*b1; 
Bss = inva*S;


Css = [1 0 0  0 0 0;
       0 1 0  0 0 0];

Dss = [0; 0];

sys_ss = ss(Ass,Bss,Css,Dss); 
Co = ctrb(Ass,Bss);
Ob = obsv(Ass, Css);
rank_Co = rank(Co); 
rank_Ob = rank(Ob);
disp(['Controllable rank: ', num2str(rank_Co)])
disp(['Observable rank: ', num2str(rank_Ob)])

eig_orig = eig(Ass); 

zeta = 0.009;       % damping ratio
wn = 12;           % natural frequency (rad/s)
pole1 = -zeta*wn + wn*sqrt(1-zeta^2)*1i;
pole2 = -zeta*wn - wn*sqrt(1-zeta^2)*1i;
poles_ctrl = [pole1 pole2 -0.005 -0.001];  

poles_unctrl = eig_orig(5:6);    

poles_ctrl_col = poles_ctrl(:);  

poles_all = [poles_ctrl_col; poles_unctrl];  

Knew = place(Ass, Bss, poles_all);


%% Closed-loop system
Acl = Ass - Bss*Knew;

% Check eigenvalues
eig_Acl = eig(Acl);
disp('Closed-loop eigenvalues:')
disp(eig_Acl)


t = 0:0.001:2;  
x0 = [1;0.1;0.01;0;0;0];  
[y,t,x] = lsim(ss(Ass,Bss,Css,Dss),zeros(size(t)),t,x0);
figure;
plot(t,y)
xlabel('Time (s)')
ylabel('Outputs')
title('Open-loop response')
legend('x_1','x_2')
grid on
%% Simulation example
t = 0:0.001:2;  
x0 = [0; 0; 0; 0; 0; 0];
% Closed-loop simulation
[y,t,x] = lsim(ss(Acl,Bss,Css,Dss),zeros(size(t)),t,x0);
figure;
plot(t,y)
xlabel('Time (s)')
ylabel('Outputs')
title('Closed-loop response with state feedback')
legend('x_1','x_2')
grid on

%%
Acl = Ass - Bss*Knew;
sys_cl = ss(Acl, Bss, Css, Dss);
Gcl = tf(sys_cl);
