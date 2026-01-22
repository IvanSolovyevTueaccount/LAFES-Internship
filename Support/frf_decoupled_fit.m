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
J0 = 1e-4;
k_b = 1e6;
k_l = 1e3;
c_b = 1;
c_l = 1;

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

% Step 1 fitting
theta_n_step1 = theta_n;
theta_n_step1(6:7)= 1e-3;

lb_step1 = lb;
ub_step1 = ub;
lb_step1(6:7) = theta_n_step1(6:7);
ub_step1(6:7) = theta_n_step1(6:7);

theta_hat_step1 = lsqnonlin(@residual_MK, theta_n_step1, lb_step1, ub_step1, opts);

disp('Step 1: Estimated M, J, K')
disp(theta_hat_step1)

% Compute fitted FRF after step 1
Gfit_step1 = frf_model(theta_hat_step1);

% Setup for step 2
theta_n_step2 = theta_hat_step1;
lb_step2 = theta_n_step2;
ub_step2 = theta_n_step2;

% Only allow damping to change
lb_step2(6:7) = 0;
ub_step2(6:7) = 1e3;

theta_hat_step2 = lsqnonlin(@residual_C, theta_n_step2, lb_step2, ub_step2, opts);

Gfit_step2 = frf_model(theta_hat_step2);

% Show found thetas
names = {'m1','m2','J0','k_b','k_l','c_b','c_l'};
theta_phys = theta_hat_step2 .* [ scale.m, scale.m, scale.J, scale.k, scale.k, scale.c, scale.c ];

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
legend('y1 - meas','y1 - init', 'Location', 'best')
xlabel('Frequency [Hz]')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(G0(:,2))));
grid on
legend('x2 - meas', 'x2 - init', 'Location', 'best')
xlabel('Frequency [Hz]')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(G0(:,1)))*180/pi));
grid on
legend('y1 - meas','y1 - init', 'Location', 'best')
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
semilogx(f, 20*log10(abs(Gexp(:,1))), f, 20*log10(abs(Gfit_step1(:,1))));
grid on
legend('y1 - meas','y1 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title('x1/tau')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(Gfit_step1(:,2))));
grid on
legend('x2 - meas', 'x2 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title('x2/tau')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(Gfit_step1(:,1)))*180/pi));
grid on
legend('y1 - meas','y1 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [deg]')
title('x1/tau')
subplot(2,2,4)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi), f, wrapTo180(unwrap(angle(Gfit_step1(:,2)))*180/pi));
grid on
legend('x2 - meas', 'x2 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [deg]')
title('x2/tau')


% Plot fitted results
figure(3)
clf
title('Fitted values FRF')
subplot(2,2,1)
semilogx(f, 20*log10(abs(Gexp(:,1))), f, 20*log10(abs(Gfit_step2(:,1))));
grid on
legend('y1 - meas','y1 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title('x1/tau')
subplot(2,2,2)
semilogx(f, 20*log10(abs(Gexp(:,2))), f, 20*log10(abs(Gfit_step2(:,2))));
grid on
legend('x2 - meas', 'x2 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
title('x2/tau')
subplot(2,2,3)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi),f, wrapTo180(unwrap(angle(Gfit_step2(:,1)))*180/pi));
grid on
legend('y1 - meas','y1 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [deg]')
title('x1/tau')
subplot(2,2,4)
semilogx(f, wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi), f, wrapTo180(unwrap(angle(Gfit_step2(:,2)))*180/pi));
grid on
legend('x2 - meas', 'x2 - fit', 'Location', 'best')
xlabel('Frequency [Hz]')
ylabel('Magnitude [deg]')
title('x2/tau')

% Functions

function r = residual_MK(theta)
    Gexp = evalin('base','Gexp');
    coh = evalin('base','coh_trim');
    epsc = 0.05;

    theta(6:7) = 1e-3;  % fix damping small

    Gmod = frf_model(theta);

    % Find resonance points
    [~, idx_peaks1] = findpeaks(abs(Gexp(:,1)), 'MinPeakProminence', 0.05*max(abs(Gexp(:,1))));
    [~, idx_peaks2] = findpeaks(abs(Gexp(:,2)), 'MinPeakProminence', 0.05*max(abs(Gexp(:,2))));
    idx_peaks = unique([idx_peaks1; idx_peaks2]);

    % ±20% around peaks
    bw_factor = 0.2;
    peak_idx = false(size(Gexp,1),1);
    f = evalin('base','f');
    for ip = idx_peaks'
        fpeak = f(ip);
        peak_idx = peak_idx | (f >= fpeak*(1-bw_factor) & f <= fpeak*(1+bw_factor));
    end

    mag_mod = 20*log10(abs(Gmod(peak_idx,:)));
    mag_exp = 20*log10(abs(Gexp(peak_idx,:)));
    W = max(coh(peak_idx,:), epsc);

    r = [
        (mag_mod(:,1) - mag_exp(:,1)) .* W(:,1);
        (mag_mod(:,2) - mag_exp(:,2)) .* W(:,2);
    ];
end


function r = residual_C(theta)
    % Pull variables
    Gexp = evalin('base','Gexp');
    coh = evalin('base','coh_trim');

    % Fix M, J, K
    theta_hat_step1 = evalin('base','theta_hat_step1');
    theta(1:5) = theta_hat_step1(1:5);

    Gmod = frf_model(theta);

    epsc = 0.05;
    W = max(coh, epsc);

    mag_mod = 20*log10(abs(Gmod));
    mag_exp = 20*log10(abs(Gexp));
    phase_mod = angle(Gmod);
    phase_exp = angle(Gexp);

    phase_diff = mod(phase_mod - phase_exp + pi, 2*pi) - pi;

    % Weighting: magnitude and phase for damping
    r = [
        (mag_mod(:,1) - mag_exp(:,1)) .* W(:,1);
        (mag_mod(:,2) - mag_exp(:,2)) .* W(:,2);
        0.5 * phase_diff(:,1) .* W(:,1);
        0.5 * phase_diff(:,2) .* W(:,2);
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