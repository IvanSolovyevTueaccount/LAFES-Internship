%% ===================== USER CONFIG =====================

% ---- Time trimming ----
t_start = 20;        % [s]
t_end   = 1e5;       % [s]

% ---- Welch / CPSD parameters (delay estimation) ----
delay_nfft_div   = 2^5;    % nfft = length(u)/this
delay_overlap    = 0.5;
delay_window_fun = @hann;

% ---- Delay estimation frequency band ----
delay_f_min = 25;   % [Hz]
delay_f_max = 50;   % [Hz]
coh_limit   = 0.1;

% ---- Welch / CPSD parameters (final FRF) ----
frf_nfft_div     = 2^10;   % nfft = length(u)/this
frf_overlap      = 0.5;
frf_window_fun   = @hann;
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
idx_end   = find(t >= t_end,   1, 'first');
if isempty(idx_end)
    idx_end = length(t);
end

t  = t(idx_start:idx_end);
u  = u(idx_start:idx_end);
x1 = x1(idx_start:idx_end);
x2 = x2(idx_start:idx_end);

%% ===================== DELAY ESTIMATION =====================

nfft_d     = 2^nextpow2(length(u)/delay_nfft_div);
noverlap_d = delay_overlap * nfft_d;
window_d   = delay_window_fun(nfft_d);

[Suu_d,f_d] = pwelch(u, window_d, noverlap_d, nfft_d, fs);
[Sx1u,~]    = cpsd(x1, u, window_d, noverlap_d, nfft_d, fs);
[Sx2u,~]    = cpsd(x2, u, window_d, noverlap_d, nfft_d, fs);

[Sx1x1,~]   = pwelch(x1, window_d, noverlap_d, nfft_d, fs);
[Sx2x2,~]   = pwelch(x2, window_d, noverlap_d, nfft_d, fs);

Gx1 = Sx1u ./ Suu_d;
Gx2 = Sx2u ./ Suu_d;

coh_x1 = abs(Sx1u).^2 ./ (Suu_d .* Sx1x1);
coh_x2 = abs(Sx2u).^2 ./ (Suu_d .* Sx2x2);

idx1 = f_d > delay_f_min & f_d < delay_f_max & coh_x1 > coh_limit;
idx2 = f_d > delay_f_min & f_d < delay_f_max & coh_x2 > coh_limit;

w = 2*pi*f_d;

p1 = polyfit(w(idx1), unwrap(angle(Gx1(idx1))), 1);
p2 = polyfit(w(idx2), unwrap(angle(Gx2(idx2))), 1);

tau_x1 = -p1(1);
tau_x2 = -p2(1);

Nd_x1 = max(0, round(tau_x1 * fs));
Nd_x2 = max(0, round(tau_x2 * fs));

fprintf('Estimated delays: x1 = %d samples, x2 = %d samples\n', Nd_x1, Nd_x2);

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

G   = zeros(nOutputs,length(f));
coh = zeros(nOutputs,length(f));

for k = 1:nOutputs
    [Syy,~] = pwelch(y(k,:), window, noverlap, nfft, fs);
    [Syu,~] = cpsd(y(k,:), u, window, noverlap, nfft, fs);

    G(k,:)   = Syu ./ Suu;
    coh(k,:) = abs(Syu).^2 ./ (Suu .* Syy);
end

%% ===================== PLOTTING =====================

% --- Raw data ---
figure(1); clf; hold on
plot(t,u)
plot(t,y.')
legend(["input","x_{pulley}","x_2","x_2-x_{pulley}"])
title('Raw Time Data')

% --- Coherence ---
figure(2); clf;
for k = 1:nOutputs
    semilogx(f,coh(k,:)); hold on
end
grid on
ylim([0 1])
xlabel('Frequency [Hz]')
ylabel('Coherence')
legend('x_{pulley}','x_2','x_2-x_{pulley}')
title('Coherence')

% --- FRFs ---
figure(3); clf
titles = {'x_{pulley}','x_2','x_2 - x_{pulley}'};

for k = 1:nOutputs
    % Magnitude
    subplot(2,3,k)
    semilogx(f,20*log10(abs(G(k,:))),'LineWidth',1.2)
    grid on
    ylabel('Magnitude [dB]')
    title(titles{k})

    % ----- Phase -----
    subplot(2,3,k+3)
    
    phase = wrapTo180(unwrap(angle(G(k,:))) * 180/pi);
    
    semilogx(f, phase, 'LineWidth', 1.2);
    grid on
    ylabel('Phase [deg]')
    xlabel('Frequency [Hz]')

end

sgtitle('FRFs: Position / Torque');

figure(4); clf

titles = {'x_{pulley}','x_2','x_2 - x_{pulley}'};

% ----- Magnitude -----
subplot(2,1,1);
for k = 1:nOutputs
    semilogx(f, 20*log10(abs(G(k,:))), 'LineWidth', 1.2); hold on;
end
grid on
ylabel('Magnitude [dB]')
title('FRFs: Position / Torque')
lgd = legend(titles, 'Location', 'best');
lgd.AutoUpdate = 'off';
lines = findall(gca,'Type','line');
uistack(lines(end),'top')

% ----- Phase (wrapped, continuous) -----
subplot(2,1,2);
for k = 1:nOutputs
    phase = wrapTo180(unwrap(angle(G(k,:))) * 180/pi);
    semilogx(f, phase, 'LineWidth', 1.2); hold on;
end

grid on
ylabel('Phase [deg]')
xlabel('Frequency [Hz]')
lgd = legend(titles, 'Location', 'best');
lgd.AutoUpdate = 'off';
lines = findall(gca,'Type','line');
uistack(lines(end),'top')