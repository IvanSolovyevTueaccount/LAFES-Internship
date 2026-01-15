% Frequency limits
fmin = 5;      % Hz (adjust)
fmax = 100;    % Hz

% Frequency
w = 2*pi*f(:);          % rad/s
r = 0.038;

% Apply frequency limits
idx = f >= fmin & f <= fmax;

f_trunc    = f(idx);
w_trunc    = w(idx);
Gexp = transpose(G(3,idx));

% Initial parameter guess
m1 = 0.5;
m2 = 0.5;
k_leaf = 1e4;
c_leaf = 0.001;

% Normalisation definitions
scale.m  = 1;        % kg
scale.k  = 1e4;      % N/m
scale.w  = sqrt(scale.k/scale.m);
scale.c  = 2 * scale.m * scale.w;        % Ns/m

% Normalisation
w_n = w_trunc / scale.w;
theta_n = [m1/scale.m, m2/scale.m, k_leaf/scale.k, c_leaf/scale.c ];
lb = [0/scale.m, 0.01/scale.m, 1e3/scale.k, 1e-1/scale.c ];
ub = [10/scale.m, 10/scale.m, 1e6/scale.k, 1e3/scale.c ];

% Optimization settings
opts = optimoptions('lsqnonlin', ...
    'Display','iter', ...
    'MaxIterations',1000, ...
    'FunctionTolerance',1e-10, ...
    'StepTolerance',1e-10, ...
    'FiniteDifferenceStepSize', 0.01);

% Run fit
theta_hat = lsqnonlin(@residual, theta_n, lb, ub, opts);

disp('Estimated parameters:')
disp(theta_hat)

% Compute fitted FRF
Gfit = frf_model(theta_hat);

% Show found thetas
names = {'m1','m2','k_leaf','c_leaf'};
theta_phys = theta_hat .* [ scale.m, scale.m, scale.k, scale.c];

fprintf('\nFitted physical parameters:\n');
for i = 1:numel(theta_phys)
    fprintf('  %-3s = %.4e\n', names{i}, theta_phys(i));
end

% initial guess results
G0 = frf_model(theta_n);
figure(1);
clf
title('Initial value FRF')
subplot(2,1,1)
semilogx(f_trunc, 20*log10(abs(Gexp(:,1))), f_trunc, 20*log10(abs(G0(:,1))));
grid on
legend('x1 - meas','x1 - init')
xlabel('Frequency [Hz]')

subplot(2,1,2)
semilogx(f_trunc, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f_trunc, wrapTo180(unwrap(angle(G0(:,1)))*180/pi));
grid on
legend('x1 - meas','x1 - init')
xlabel('Frequency [Hz]')

% Plot fitted results
figure(2)
clf
title('Fitted values FRF')
subplot(2,1,1)
semilogx(f_trunc, 20*log10(abs(Gexp(:,1))), f_trunc, 20*log10(abs(Gfit(:,1))));
grid on
legend('x1 - meas','x1 - fit')
xlabel('Frequency [Hz]')

subplot(2,1,2)
semilogx(f_trunc, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f_trunc, wrapTo180(unwrap(angle(Gfit(:,1)))*180/pi));
grid on
legend('x1 - meas','x1 - fit')
xlabel('Frequency [Hz]')

% Functions
function r = residual(theta)

    % Pull workspace variables
    w    = evalin('base','w');
    Gexp = evalin('base','Gexp');

    Gmod = frf_model(theta);

    % Frequency-dependent weighting
    W = 1 ./ max(abs(Gexp), 1e-12);

    mag_mod = 20*log10(abs(Gmod));
    mag_exp = 20*log10(abs(Gexp));
    phase_mod = angle(Gmod);
    phase_exp = angle(Gexp);
    
    phase_diff = mod(phase_mod - phase_exp + pi, 2*pi) - pi;

    phase_weight = 1;
    
    % Residual vector
    r = [
        (mag_mod - mag_exp) .* W;
        phase_weight * phase_diff .* W;
    ];
end

function G = frf_model(theta)

    % Pull constants
    w_trunc = evalin('base','w_trunc');
    r   = evalin('base','r');

    % Parameters
    scale = evalin('base','scale');
    
    m1 = theta(1) * scale.m;
    m2 = theta(2) * scale.m;

    k_leaf = theta(3) * scale.k;
    c_leaf = theta(4) * scale.c;

    % Matrices
    M = diag([m1 m2]);
   
    K = [k_leaf   -k_leaf;
        -k_leaf    k_leaf;];

    C = [c_leaf   -c_leaf;
        -c_leaf    c_leaf;];
    
    B = [ 1/r; 0;];

    n = length(w_trunc);
    G = zeros(n,1);

    for i = 1:n
        w = w_trunc(i)*scale.w;
        D = -w^2*M + 1i*w*C + K;
        x = D\B;
        G(i) = x(2) - x(1);
    end
end