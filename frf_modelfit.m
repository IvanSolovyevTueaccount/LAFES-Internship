%% FRF PARAMETER FITTING SCRIPT
% Assumes the following variables already exist in workspace:
%   f        : Nx1 frequency vector [Hz]
%   G        : NxM experimental complex FRF

clearvars -except f G
clc

% Frequency
w = 2*pi*f(:);          % rad/s
Gexp = G(1:2,:)';
r = 0.038;

% Limit frequencies
fmin = 1;      % Hz (adjust)
fmax = 60;    % Hz

idx = f >= fmin & f <= fmax;

f    = f(idx);
w    = w(idx);
Gexp = Gexp(idx,:);

% Initial parameter guess

m1 = 80e-3*40e-3*20e-3*2700;
m2 = 0.2;
J0 = 2e-4;
k1 = 4e7;
k2 = 1e3;
c1 = 0.1;
c2 = 0.1;

% Normalisation

scale.m  = 1;        % kg
scale.k  = 1e5;      % N/m
scale.w  = sqrt(scale.k/scale.m);
scale.c  = 2 * scale.m * scale.w;        % Ns/m

w_n = w / scale.w;

theta_n = [m2/scale.m, k2/scale.k, c1/scale.c, c2/scale.c];
lb = [0.1/scale.m, 1e2/scale.k, 0, 0];
ub = [0.5/scale.m, 1e5/scale.k, 100/scale.c, 100/scale.c];

% Optimization
opts = optimoptions('lsqnonlin', ...
    'Display','iter', ...
    'MaxIterations',1000, ...
    'FunctionTolerance',1e-12, ...
    'StepTolerance',1e-12, ...
    'TypicalX', theta_n, ...
    'FiniteDifferenceStepSize', 0.01);

theta_hat = lsqnonlin(@residual, theta_n, lb, ub, opts);

disp('Estimated parameters:')
disp(theta_hat)

% Compute fitted FRF
Gfit = frf_model(theta_hat);

% Show found thetas
names = {'m2','k2','c1','c2'};
theta_phys = theta_hat .* [scale.m, scale.k, scale.c, scale.c ];

fprintf('\nFitted physical parameters:\n');
for i = 1:numel(theta_phys)
    fprintf('  %-3s = %.4e\n', names{i}, theta_phys(i));
end

% initial guess results
G0 = frf_model(theta_n);
figure(1);
clf
subplot(2,2,1)
semilogy(f, abs(Gexp(:,1)),f, abs(G0(:,1)));
grid on
legend('x1 - meas','x1 - init')
subplot(2,2,2)
semilogy(f, abs(Gexp(:,2)),f, abs(G0(:,2)));
grid on
legend('x2 - meas', 'x2 - init')
subplot(2,2,3)
plot(f, angle(Gexp(:,1)),f, angle(G0(:,1)));
grid on
legend('x1 - meas','x1 - init')
subplot(2,2,4)
plot(f, angle(Gexp(:,2)),f, angle(G0(:,2)));
grid on
legend('x2 - meas', 'x2 - init')

% Plot fitted results
figure(2)
clf
subplot(2,2,1)
semilogy(f, abs(Gexp(:,1)),f, abs(Gfit(:,1)));
grid on
legend('x1 - meas','x1 - fit')
subplot(2,2,2)
semilogy(f, abs(Gexp(:,2)),f, abs(Gfit(:,2)));
grid on
legend('x2 - meas', 'x2 - fit')
subplot(2,2,3)
plot(f, angle(Gexp(:,1)),f, angle(Gfit(:,1)));
grid on
legend('x1 - meas','x1 - fit')
subplot(2,2,4)
plot(f, angle(Gexp(:,2)),f, angle(Gfit(:,2)));
grid on
legend('x2 - meas', 'x2 - fit')

% Functions
function r = residual(theta)

    % Pull workspace variables
    w    = evalin('base','w');
    Gexp = evalin('base','Gexp');

    Gmod = frf_model(theta);

    % Frequency-dependent weighting
    W = 1 ./ max(abs(Gexp), 1e-12);
    
    r = [
        (abs(Gmod(:,1)) - abs(Gexp(:,1))) ./ max(abs(Gexp(:,1)),1e-12);
        (abs(Gmod(:,2)) - abs(Gexp(:,2))) ./ max(abs(Gexp(:,2)),1e-12);
    ];
end

function G = frf_model(theta)

    % Pull constants
    w_n = evalin('base','w_n');
    r   = evalin('base','r');

    % Parameters
    scale = evalin('base','scale');
    
    m1 = evalin('base','m1');
    k1 = evalin('base', 'k1');
    J0 = evalin('base', 'J0');

    m2 = theta(1) * scale.m;
    k2 = theta(2) * scale.k;
    c1 = theta(3) * scale.c;
    c2 = theta(4) * scale.c;

    c_m1 = 0.01 * scale.c;  % small damping on m1
    c_m2 = 0.01 * scale.c;  % small damping on m2
    c_J0 = 0.01 * scale.c;  % small rotational damping

    % Matrices
    M = [ m1      0        0;
          0       m2       0;
          0       0   J0/r^2 ];
    
    C = [ c1+c2+c_m1   -c2    -c1;
         -c2      c2+c_m2      0;
         -c1      0       c1+c_J0 ];
    
    K = [ k1+k2   -k2    -k1;
         -k2      k2      0;
         -k1      0       k1 ];
    
    B = [ 0;
          0;
          1e-3/r ];

    n = length(w_n);
    G = zeros(n,2);

    for i = 1:n
        w = w_n(i)*scale.w;
        D = -w^2*M + 1i*w*C + K;
        x = D\B;
        G(i,1) = x(1);
        G(i,2) = x(2);
    end
end