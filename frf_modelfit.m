% ======== Options ========
% Frequency limits
fmin = 1;      % Hz (adjust)
fmax = 60;    % Hz

% ======= FRF =========
% load data
load("input.mat")
load("position1.mat")
load("position2.mat")

% pull data
t = input(1,:); 
u = input(2,:);
x1 = position1(2,:);
x2 = position2(2,:);

% sample time
dt = mean(diff(t));
fs = 1/dt;

% skip first 10 seconds
idx_start = find(t >= 10, 1, 'first');

t  = t(idx_start:end);
u  = u(idx_start:end);
x1 = x1(idx_start:end);
x2 = x2(idx_start:end);

% Time delay correction
Nd_x1 = 5;   % delay of motor encoder [samples]
Nd_x2 = 3;   % delay of linear encoder [samples]

% Apply delays independently
x1 = x1(Nd_x1+1:end);
x2 = x2(Nd_x2+1:end);

% Trim to shortest remaining signal
N = min([length(x1), length(x2), length(u), length(t)]);
x1 = x1(1:N);
x2 = x2(1:N);
u  = u(1:N);
t  = t(1:N);

% Define outputs for FRF
y = [x1; x2; x2 - x1];

nOutputs = size(y,1);

% time window for pwelch
nfft = 2^nextpow2(length(u)/128);
noverlap = 0.5*nfft;
window = hann(nfft);

% cross power spectral densities
[Suu,f] = pwelch(u, window, noverlap, nfft, fs);

G = zeros(nOutputs,length(f));

for k = 1:nOutputs
    [Syy,~] = pwelch(y(k,:), window, noverlap, nfft, fs);
    [Syu,~] = cpsd(y(k,:), u, window, noverlap, nfft, fs);

    G(k,:) = Syu ./ Suu;
end

% ========== FITTING ==========

% Frequency
w = 2*pi*f(:);          % rad/s
Gexp = transpose(G(1:2,:));
r = 0.038;

% Apply frequency limits
idx = f >= fmin & f <= fmax;

f    = f(idx);
w    = w(idx);
Gexp = Gexp(idx,:);

% Initial parameter guess
m1 = 80e-3*40e-3*20e-3*2700; % Fixed, rest is fitted
m2 = 0.5;
J0 = 2e-4;
k1 = 3e7;
k2 = 1e3;
c1 = 0.01;
c2 = 0.01;

% Normalisation definitions
scale.m  = 1;        % kg
scale.k  = 1e5;      % N/m
scale.w  = sqrt(scale.k/scale.m);
scale.c  = 2 * scale.m * scale.w;        % Ns/m
scale.J  = 1e-4;

% Normalisation
w_n = w / scale.w;
theta_n = [m2/scale.m, J0/scale.J, k2/scale.k, c1/scale.c, c2/scale.c, 1e2/scale.c, 1e2/scale.c, 1e2/scale.c ];
lb = [0.1/scale.m, 0, 1e2/scale.k, 0, 0, 0, 0, 0];
ub = [2/scale.m, 1/scale.J, 1e5/scale.k, inf/scale.c, 1e3/scale.c, 1e3/scale.c, 1e3/scale.c, 1e3/scale.c];

% Optimization settings
opts = optimoptions('lsqnonlin', ...
    'Display','iter', ...
    'MaxIterations',1000, ...
    'FunctionTolerance',1e-12, ...
    'StepTolerance',1e-12, ...
    'TypicalX', theta_n, ...
    'FiniteDifferenceStepSize', 0.01);

% Run fit
theta_hat = lsqnonlin(@residual, theta_n, lb, ub, opts);

disp('Estimated parameters:')
disp(theta_hat)

% Compute fitted FRF
Gfit = frf_model(theta_hat);

% Show found thetas
names = {'m2','J0','k2','c1','c2','fric_1','fric_2','fric_3'};
theta_phys = theta_hat .* [ scale.m, scale.J, scale.k, scale.c, scale.c scale.c, scale.c, scale.c];

fprintf('\nFitted physical parameters:\n');
for i = 1:numel(theta_phys)
    fprintf('  %-3s = %.4e\n', names{i}, theta_phys(i));
end

% initial guess results
G0 = frf_model(theta_n);
figure(1);
clf
title('Initial value FRF')
subplot(2,2,1)
semilogx(f, 20*log10(abs(Gexp(:,1))), f, 20*log10(abs(G0(:,1))));
grid on
legend('x1 - meas','x1 - init')
xlabel('Frequency [Hz]')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(G0(:,2))));
grid on
legend('x2 - meas', 'x2 - init')
xlabel('Frequency [Hz]')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(G0(:,1)))*180/pi));
grid on
legend('x1 - meas','x1 - init')
xlabel('Frequency [Hz]')
subplot(2,2,4)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi),f, wrapTo180(unwrap(angle(G0(:,2)))*180/pi));
grid on
legend('x2 - meas', 'x2 - init')
xlabel('Frequency [Hz]')

% Plot fitted results
figure(2)
clf
title('Fitted values FRF')
subplot(2,2,1)
semilogx(f, 20*log10(abs(Gexp(:,1))), f, 20*log10(abs(Gfit(:,1))));
grid on
legend('x1 - meas','x1 - fit')
xlabel('Frequency [Hz]')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(Gfit(:,2))));
grid on
legend('x2 - meas', 'x2 - fit')
xlabel('Frequency [Hz]')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(Gfit(:,1)))*180/pi));
grid on
legend('x1 - meas','x1 - fit')
xlabel('Frequency [Hz]')
subplot(2,2,4)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi), f, wrapTo180(unwrap(angle(Gfit(:,2)))*180/pi));
grid on
legend('x2 - meas', 'x2 - fit')
xlabel('Frequency [Hz]')

% Functions
function r = residual(theta)

    % Pull workspace variables
    w    = evalin('base','w');
    Gexp = evalin('base','Gexp');

    Gmod = frf_model(theta);

    % Frequency-dependent weighting
    W = 1 ./ max(abs(Gexp), 1e-12);

    % Complex residual (real + imaginary parts)
    r_complex = (Gmod - Gexp) .* W;
    
    r = [
        real(r_complex(:,1));
        imag(r_complex(:,1));
        real(r_complex(:,2));
        imag(r_complex(:,2))
    ];
end

function G = frf_model(theta)

    % Pull constants
    w_n = evalin('base','w_n');
    r   = evalin('base','r');

    % Parameters
    scale = evalin('base','scale');
    
    m1 = evalin('base','m1');
    m2 = theta(1) * scale.m;
    k1 = evalin('base', 'k1');
    J0 = theta(2) * scale.J;

    k2 = theta(3) * scale.k;

    c1 = theta(4) * scale.c;
    c2 = theta(5) * scale.c;

    fric_m1 = theta(6) * scale.c;
    fric_m2 = theta(7) * scale.c;
    fric_J0 = theta(8) * scale.c;

    % Matrices
    M = [ m1      0        0;
          0       m2       0;
          0       0   J0/r^2 ];
    
    C = [ c1+c2+fric_m1   -c2    -c1;
         -c2      c2+fric_m2      0;
         -c1      0       c1+fric_J0 ];
    
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