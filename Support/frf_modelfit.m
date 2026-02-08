%% ===================== USER CONFIG =====================

% ---- Time trimming ----
t_start = 10;        % [s]
t_end   = 8000;      % [s]

% ---- Known time delays ----
Nd_x1 = 7;           % motor encoder delay [samples]
Nd_x2 = 6;           % linear encoder delay [samples]

% ---- Welch / FRF parameters ----
frf_nfft_div   = 2^10;    % nfft = length(u)/this
frf_overlap    = 0.5;
frf_window_fun = @hann;

% ---- Frequency limits for fitting ----
fmin = 2;            % [Hz]
fmax = 500;          % [Hz]

%% ===================== LOAD DATA =====================

load("input.mat")
load("torque.mat")
load("position1.mat")
load("position2.mat")

% pull data
t  = input(1,:);
u  = input(2,:) - torque(2,:);
x1 = position1(2,:);
x2 = position2(2,:);

% sample time
dt = mean(diff(t));
fs = 1/dt;

%% ===================== TIME TRIMMING =====================

idx_start = find(t >= t_start, 1, 'first');
idx_end   = find(t >= min(t_end, t(end)), 1, 'first');

t  = t(idx_start:idx_end);
u  = u(idx_start:idx_end);
x1 = x1(idx_start:idx_end);
x2 = x2(idx_start:idx_end);

%% ===================== APPLY DELAYS =====================

x1 = x1(Nd_x1+1:end);
x2 = x2(Nd_x2+1:end);

N = min([length(x1), length(x2), length(u), length(t)]);
x1 = x1(1:N);
x2 = x2(1:N);
u  = u(1:N);
t  = t(1:N);

%% ===================== FINAL FRF ESTIMATION =====================

y = [x1; x2; x2 - x1];
nOutputs = size(y,1);

nfft     = 2^nextpow2(length(u)/frf_nfft_div);
noverlap = frf_overlap * nfft;
window   = frf_window_fun(nfft);

[Suu,f] = pwelch(u, window, noverlap, nfft, fs);

G   = zeros(nOutputs, length(f));
coh = zeros(nOutputs, length(f));

for k = 1:nOutputs
    [Syy,~] = pwelch(y(k,:), window, noverlap, nfft, fs);
    [Syu,~] = cpsd(y(k,:), u, window, noverlap, nfft, fs);

    G(k,:)   = Syu ./ Suu;
    coh(k,:) = abs(Syu).^2 ./ (Suu .* Syy);
end

%% ===================== FITTING DATA PREP =====================

w    = 2*pi*f(:);                % [rad/s]
Gexp = transpose(G(1:2,:));      % x1 and x2 FRFs
r    = 0.038;

idx = f >= fmin & f <= fmax;

f        = f(idx);
w        = w(idx);
Gexp     = Gexp(idx,:);
coh_trim = transpose(coh(1:2,idx));

%% ===================== INITIAL PARAMETERS =====================

m1 = 0.5;
m2 = 1;
J0 = 1e-3;
k_b = 1e6;
k_l = 1e4;
c_b = 10;
c_l = 1;

%% ===================== NORMALISATION =====================

scale.m = 1;
scale.k = 1e4;
scale.w = sqrt(scale.k/scale.m);
scale.c = 1e1;
scale.J = 1e-4;

w_n = w / scale.w;

theta_n = [
    m1/scale.m
    m2/scale.m
    J0/scale.J
    k_b/scale.k
    k_l/scale.k
    c_b/scale.c
    c_l/scale.c
];

lb = [
    0.1/scale.m
    0.5/scale.m
    0
    1e5/scale.k
    1e3/scale.k
    0
    0
];

ub = [
    0.5/scale.m
    5/scale.m
    1e-2/scale.J
    1e7/scale.k
    1e5/scale.k
    1e3/scale.c
    1e3/scale.c
];

%% ===================== OPTIMISATION =====================

opts = optimoptions('lsqnonlin', ...
    'Display','iter', ...
    'MaxIterations',1000, ...
    'MaxFunctionEvaluations',1e3, ...
    'FunctionTolerance',1e-12, ...
    'StepTolerance',1e-12, ...
    'FiniteDifferenceStepSize',0.1);

theta_hat = lsqnonlin(@residual, theta_n, lb, ub, opts);

%% ===================== RESULTS =====================

names = {'m1','m2','J0','k_b','k_l','c_b','c_l'};
theta_phys = theta_hat .* ...
    [scale.m, scale.m, scale.J, scale.k, scale.k, scale.c, scale.c];

fprintf('\nFitted physical parameters:\n');
for i = 1:numel(theta_phys)
    fprintf('  %-3s = %.4e\n', names{i}, theta_phys(i));
end

Gfit = frf_model(theta_hat);
G0   = frf_model(theta_n);

%% ===================== PLOTTING =====================

figure(1); clf
sgtitle('Initial Guess FRF')

subplot(2,2,1)
semilogx(f,20*log10(abs(Gexp(:,1))), f,20*log10(abs(G0(:,1))))
grid on
legend('x_{pulley} meas','x_{pulley} init')

subplot(2,2,2)
semilogx(f,20*log10(abs(Gexp(:,2))), f,20*log10(abs(G0(:,2))))
grid on
legend('x_2 meas','x_2 init')

subplot(2,2,3)
semilogx(f,wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi), ...
         f,wrapTo180(unwrap(angle(G0(:,1)))*180/pi))
grid on

subplot(2,2,4)
semilogx(f,wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi), ...
         f,wrapTo180(unwrap(angle(G0(:,2)))*180/pi))
grid on

figure(2); clf
sgtitle('Fitted FRF')

subplot(2,2,1)
semilogx(f,20*log10(abs(Gexp(:,1))), f,20*log10(abs(Gfit(:,1))))
grid on
ylabel('Magnitude [dB]')
title('x_{pulley}/\tau')

subplot(2,2,2)
semilogx(f,20*log10(abs(Gexp(:,2))), f,20*log10(abs(Gfit(:,2))))
grid on
ylabel('Magnitude [dB]')
title('x_2/\tau')

subplot(2,2,3)
semilogx(f,wrapTo180(unwrap(angle(Gexp(:,1)))*180/pi), ...
         f,wrapTo180(unwrap(angle(Gfit(:,1)))*180/pi))
grid on
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')

subplot(2,2,4)
semilogx(f,wrapTo180(unwrap(angle(Gexp(:,2)))*180/pi), ...
         f,wrapTo180(unwrap(angle(Gfit(:,2)))*180/pi))
grid on
xlabel('Frequency [Hz]')
ylabel('Phase [deg]')

%% ===================== FUNCTIONS =====================

function r = residual(theta)

    Gexp = evalin('base','Gexp');
    coh  = evalin('base','coh_trim');

    Gmod = frf_model(theta);
    Grel = (Gmod - Gexp) ./ (abs(Gexp) + 1e-6);

    epsc = 0.01;
    W = max(coh.^0.8, epsc);

    r = [
        real(W(:,1).*Grel(:,1))
        imag(W(:,1).*Grel(:,1))
        real(W(:,2).*Grel(:,2))
        imag(W(:,2).*Grel(:,2))
    ];
end

function G = frf_model(theta)

    w_n   = evalin('base','w_n');
    r     = evalin('base','r');
    scale = evalin('base','scale');

    m1 = theta(1)*scale.m;
    m2 = theta(2)*scale.m;
    J0 = theta(3)*scale.J;

    k_b = theta(4)*scale.k;
    k_l = theta(5)*scale.k;
    c_b = theta(6)*scale.c;
    c_l = theta(7)*scale.c;

    M = diag([J0/r^2, m1, m2]);

    K = [ k_b  -k_b          0
         -k_b   k_b+k_l   -k_l
          0    -k_l        k_l ];

    C = [ c_b  -c_b          0
         -c_b   c_b+c_l   -c_l
          0    -c_l        c_l ];

    B = [1/r; 0; 0];

    G = zeros(length(w_n),2);

    for i = 1:length(w_n)
        w = w_n(i)*scale.w;
        D = -w^2*M + 1i*w*C + K;
        x = D\B;
        G(i,:) = [x(1), x(3)];
    end
end