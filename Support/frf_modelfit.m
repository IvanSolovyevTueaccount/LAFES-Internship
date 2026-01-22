% ======== Options ========
% Frequency limits
fmin = 2;      % Hz (adjust)
fmax = 500;    % Hz

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

time_min = 10;
time_max = 8000;

idx_start = find(t >= time_min, 1, 'first');
idx_end = find(t >= min(time_max,t(end)), 1, 'first');

t  = t(idx_start:idx_end);
u  = u(idx_start:idx_end);
x1 = x1(idx_start:idx_end);
x2 = x2(idx_start:idx_end);

% Time delay correction
Nd_x1 = 7;   % delay of motor encoder [samples]
Nd_x2 = 6;   % delay of linear encoder [samples]

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
nfft = 2^nextpow2(length(u)/2^10);
noverlap = 0.5*nfft;
window = hann(nfft);

% cross power spectral densities
[Suu,f] = pwelch(u, window, noverlap, nfft, fs);

G = zeros(nOutputs,length(f));

for k = 1:nOutputs
    [Syy,~] = pwelch(y(k,:), window, noverlap, nfft, fs);
    [Syu,~] = cpsd(y(k,:), u, window, noverlap, nfft, fs);

    G(k,:) = Syu ./ Suu;
    coh(k,:) = abs(Syu).^2 ./ (Suu .* Syy);
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
coh_trim  = transpose(coh(:,idx));

% Initial parameter guess
m1 = 0.5;
m2 = 0.5;
J0 = 3e-4;
k_b = 5e5;
k_l = 5e3;
c_b = 10;
c_l = 5;

% Normalisation definitions
scale.m  = 1;        % kg
scale.k  = 1e4;      % N/m
scale.w  = sqrt(scale.k/scale.m);
scale.c  = 1e1;        % Ns/m
scale.J  = 1e-4;

% Normalisation
w_n = w / scale.w;
theta_n = [m1/scale.m, m2/scale.m, J0/scale.J, k_b/scale.k, k_l/scale.k, c_b/scale.c, c_l/scale.c ];
lb = [0.1/scale.m, 0.1/scale.m, 0/scale.J, 1e2/scale.k, 1e2/scale.k, 0/scale.c, 0/scale.c ];
ub = [10/scale.m, 10/scale.m, 1/scale.J, 1e7/scale.k, 1e7/scale.k, 1e3/scale.c, 1e3/scale.c ]; 

% Optimization settings
opts = optimoptions('lsqnonlin', ...
    'Display','iter', ...
    'MaxIterations',1000, ...
    'FunctionTolerance',1e-12, ...
    'StepTolerance',1e-12, ...
    'FiniteDifferenceStepSize', 0.01);

% Run fit
theta_hat = lsqnonlin(@residual, theta_n, lb, ub, opts);

disp('Estimated parameters:')
disp(theta_hat)

% Compute fitted FRF
Gfit = frf_model(theta_hat);

% Show found thetas
names = {'m1','m2','J0','k_b','k_l','c_b','c_l'};
theta_phys = theta_hat .* [ scale.m, scale.m, scale.J, scale.k, scale.k, scale.c, scale.c ];

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
legend('x1 - meas','x1 - init', 'Location', 'best')
xlabel('Frequency [Hz]')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(G0(:,2))));
grid on
legend('x2 - meas', 'x2 - init', 'Location', 'best')
xlabel('Frequency [Hz]')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(G0(:,1)))*180/pi));
grid on
legend('x1 - meas','x1 - init', 'Location', 'best')
xlabel('Frequency [Hz]')
subplot(2,2,4)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi),f, wrapTo180(unwrap(angle(G0(:,2)))*180/pi));
grid on
legend('x2 - meas', 'x2 - init', 'Location', 'best')
xlabel('Frequency [Hz]')

% Plot fitted results
figure(2)
clf
title('Fitted values FRF')
subplot(2,2,1)
semilogx(f, 20*log10(abs(Gexp(:,1))), f, 20*log10(abs(Gfit(:,1))));
grid on
legend('x1 - meas','x1 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title('x1/tau')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(Gfit(:,2))));
grid on
legend('x2 - meas', 'x2 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title('x2/tau')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(Gfit(:,1)))*180/pi));
grid on
legend('x1 - meas','x1 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [deg]')
title('x1/tau')
subplot(2,2,4)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi), f, wrapTo180(unwrap(angle(Gfit(:,2)))*180/pi));
grid on
legend('x2 - meas', 'x2 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [deg]')
title('x2/tau')

% Functions
function r = residual(theta)

    % Pull workspace variables
    Gexp = evalin('base','Gexp');
    coh = evalin('base', 'coh_trim');

    Gmod = frf_model(theta);

    % Coherence-dependent weighting
    epsc = 0.05;
    coh_adj = max(coh, epsc);
    
    Wmag   = 1    * coh_adj.^1.0;
    Wphase = 0.2  * coh_adj.^0.2;      

    mag_mod   = 20*log10(abs(Gmod));
    mag_exp   = 20*log10(abs(Gexp));
    phase_mod = angle(Gmod);
    phase_exp = angle(Gexp);
    
    phase_diff = mod(phase_mod - phase_exp + pi, 2*pi) - pi;

    r = [
        (mag_mod(:,1) - mag_exp(:,1)) .* Wmag(:,1);
        phase_diff(:,1) .* Wphase(:,1);
        (mag_mod(:,2) - mag_exp(:,2)) .* Wmag(:,2);
        phase_diff(:,2) .* Wphase(:,2);
    ];
end

function G = frf_model(theta)

    % Pull constants
    w_n = evalin('base','w_n');
    r   = evalin('base','r');

    % Parameters
    scale = evalin('base','scale');
    
    m1 = theta(1) * scale.m;
    m2 = theta(2) * scale.m;
    J0 = theta(3) * scale.J;

    k_b = theta(4) * scale.k;
    k_l = theta(5) * scale.k;
    
    c_b = theta(6) * scale.c;
    c_l = theta(7) * scale.c;
    
    % Matrices
    M = diag([ J0/r^2, m1, m2 ]);
    
    K = [ k_b  -k_b          0                  
         -k_b   k_b + k_l   -k_l
          0    -k_l          k_l ];
    
    C = [ c_b  -c_b          0                  
         -c_b   c_b + c_l   -c_l
          0    -c_l          c_l ];
    
    B = [ 1/(2*r); 0; 0 ];

    n = length(w_n);
    G = zeros(n,2);

    for i = 1:n
        w = w_n(i)*scale.w;
        D = -w^2*M + 1i*w*C + K;
        x = D\B;
        G(i,1) = x(1);
        G(i,2) = x(3);
    end
end