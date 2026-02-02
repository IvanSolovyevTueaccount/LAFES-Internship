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

C = [ c1+c2   -c2    -c1;      %change this
     -c2      c2      0;
     -c1*r      0       c1*r ];

K = [ k1+k2   -k2    -k1;    %change this
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
eigenvalues = eig(Ass);
Obs = obsv(Ass, Css);
Obsstates = rank(Obs);
Cont = ctrb(Ass, Bss);
Contstates = rank(Cont);
Uc = null(ctrb(Ass,Bss)');
%%

t = 0:0.01:2;
u = zeros(size(t));
x0 = [0 0 0 0 0 0];
[y, t, x] =lsim(sys_ss, u, t, x0);

q1  = x(:,1);
q2  = x(:,2);
q3  = x(:,3);
dq1 = x(:,4);
dq2 = x(:,5);
dq3 = x(:,6);

figure
subplot(2,1,1)
plot(t, q1, t, q2, t, q3)
legend('q_1','q_2','q_3')
ylabel('Displacement')

subplot(2,1,2)
plot(t, dq1, t, dq2, t, dq3)
legend('\dot q_1','\dot q_2','\dot q_3')
ylabel('Velocity')
xlabel('Time (s)')

%%
G = tf(sys_ss);         

G_d=c2d(G, 1/250, 'tustin')

G1 = G(1);               
G2 = G(2);               

disp('G1(s) = X1(s) / tau(s):');
G1

disp('G2(s) = X2(s) / tau(s):');
G2

figure()
bode(G1, G2); legend('x1/tau','x2/tau');

%% 
p = [ -119+105j, -119-105j, -340, -360, -540, -560 ];
Ka = place(A,Bss,p);

sys_cl = ss(A-Bss*Ka,Bss,Css,0);


[y, t, x] = lsim(sys_cl, u, t, x0);
q1  = x(:,1);
q2  = x(:,2);
q3  = x(:,3);
dq1 = x(:,4);
dq2 = x(:,5);
dq3 = x(:,6);

figure
subplot(2,1,1)
plot(t, q1, t, q2, t, q3)
legend('q_1','q_2','q_3')
ylabel('Displacement')

subplot(2,1,2)
plot(t, dq1, t, dq2, t, dq3)
legend('\dot q_1','\dot q_2','\dot q_3')
ylabel('Velocity')
xlabel('Time (s)')

%%
G_cont = tf(sys_cl);         

G_dcont = c2d(G_cont, 1/250, 'tustin')

G1cont = G_cont(1);               
G2cont = G_cont(2);               

disp('Controllable G1(s) = X1(s) / tau(s):');
G1cont

disp('Controllable G2(s) = X2(s) / tau(s):');
G2cont

figure()
bode(G1cont, G2cont); legend('x1/tau','x2/tau');

%%
sys_min = minreal(ss(Ass,Bss,Css,Dss));
step(sys_ss)
hold on
step(sys_min)
legend('Full','Reduced')