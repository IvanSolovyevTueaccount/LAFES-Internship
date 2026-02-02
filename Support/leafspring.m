clear;
m = 0.5;

L_mm = 50;
W_mm = 40;
T_mm = 2;

L_m = L_mm/1000;
W_m = W_mm/1000;
T_m = T_mm/1000;

E = 2e9;

K = (E*W_m*T_m^3)/(L_m^3);

omega1 = sqrt((2*K)/m);

% Mode numbers
n = [1 2];  

omega = n.^2 * omega1;
f_Hz = omega / (2*pi);

disp(f_Hz)

%%
m= 0.5;
n= 5;
w = 2;
a = 52/5; %=h
b = 10; 
a_m = a/1000;
b_m = b/1000;
w_m = w/1000;

I = (a_m*w_m^3)/12;

K_s = (48*E*I)/((a_m^2*n)*((a_m+b_m*n^2 - 3*b_m*n +2*b_m)));

omega1 = sqrt((2*K_s)/m);

% Mode numbers
  

f_Hz = omega1/ (2*pi);

disp(f_Hz)