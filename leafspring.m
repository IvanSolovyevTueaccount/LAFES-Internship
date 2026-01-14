m = 0.5;
L_mm = 50;
W_mm = 40;
T_mm = 2;

L_m = L_mm/1000;
W_m = W_mm/1000;
T_m = T_mm/1000;

E = 2.0e9;

K = (E*W_m*T_m^3)/(L_m^3);

omega1 = sqrt((2*K)/m);

% Mode numbers
n = [1 2];  

omega = n.^2 * omega1;
f_Hz = omega / (2*pi);

disp(f_Hz)

%% Torsion
L_mm = 50;
W_mm = 40;
T_mm = 1;

L = L_mm/1000;   % length [m]
W = W_mm/1000;   % width [m]
T = T_mm/1000;   % thickness [m]

E  = 2.0e9;      % Young's modulus [Pa]
nu = 0.3;        % Poisson's ratio
rho = 1200;      % density [kg/m^3] (adjust if needed)

G = E/(2*(1+nu));  % shear modulus [Pa]

A = W*T;                              % area [m^2]

J  = (1/3)*W*T^3;                     % torsional constant [m^4]
Ip = (A*(W^2 + T^2))/12;              % polar area moment [m^4]

omega_t1 = (pi/L)*sqrt(G*J/(rho*Ip)); % rad/s
f_t1 = omega_t1/(2*pi);               % Hz

fprintf('1st torsional natural frequency: %.1f Hz\n', f_t1);


%% Two-mass, two-plate torsional system
L_mm = 50;
W_mm = 40;
T_mm = 2;

L = L_mm/1000;   % length [m]
W = W_mm/1000;   % width [m]
T = T_mm/1000;   % thickness [m]

rho = 1200; % kg/m^3
E  = 2.0e9;      % Young's modulus [Pa]
nu = 0.3;        % Poisson's ratio

G = E/(2*(1+nu));  % shear modulus [Pa]
m = rho * W * T * L;
I_m = m * (W^2 + T^2)/12;

J = (1/3) * W * T^3;
K_theta = G * J / L;

M = I_m * eye(2);
K = [K_theta, -K_theta;
     -K_theta, K_theta];

[V,D] = eig(K,M);
f_Hz = sqrt(diag(D)) / (2*pi);

disp('Torsional mode frequencies [Hz]:')
disp(f_Hz)
