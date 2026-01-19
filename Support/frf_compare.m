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

% time window for pwelch
nfft_d = 2^nextpow2(length(u)/2^5);
noverlap_d = 0.5*nfft_d;
window_d = hann(nfft_d);

% input PSD
[Suu_d,f_d] = pwelch(u, window_d, noverlap_d, nfft_d, fs);

% cross PSDs
[Sx1u,~] = cpsd(x1, u, window_d, noverlap_d, nfft_d, fs);
[Sx2u,~] = cpsd(x2, u, window_d, noverlap_d, nfft_d, fs);

% output PSDs (for coherence)
[Sx1x1,~] = pwelch(x1, window_d, noverlap_d, nfft_d, fs);
[Sx2x2,~] = pwelch(x2, window_d, noverlap_d, nfft_d, fs);

% FRFs
Gx1 = Sx1u ./ Suu_d;
Gx2 = Sx2u ./ Suu_d;

% coherence
coh_x1 = abs(Sx1u).^2 ./ (Suu_d .* Sx1x1);
coh_x2 = abs(Sx2u).^2 ./ (Suu_d .* Sx2x2);

% frequency range where delay dominates (adjust if needed)
f_d_min = 50; f_d_max = 70; coh_lim = 0.1;
idx1 = f_d > f_d_min & f_d < f_d_max & coh_x1 > coh_lim;
idx2 = f_d > f_d_min & f_d < f_d_max & coh_x2 > coh_lim;

% phase slope to delay
w = 2*pi*f_d;

p1 = polyfit(w(idx1), unwrap(angle(Gx1(idx1))), 1);
p2 = polyfit(w(idx2), unwrap(angle(Gx2(idx2))), 1);

tau_x1 = -p1(1);   % seconds
tau_x2 = -p2(1);   % seconds

Nd_x1 = round(tau_x1 * fs);
Nd_x2 = round(tau_x2 * fs);

fprintf('Estimated delays: x1 = %d samples, x2 = %d samples\n', Nd_x1, Nd_x2);

Nd_x1 = max(0, Nd_x1); Nd_x2 = max(0, Nd_x2);

% Apply delays
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
coh = zeros(nOutputs,length(f));

for k = 1:nOutputs
    [Syy,~] = pwelch(y(k,:), window, noverlap, nfft, fs);
    [Syu,~] = cpsd(y(k,:), u, window, noverlap, nfft, fs);

    G(k,:) = Syu ./ Suu;
    coh(k,:) = abs(Syu).^2 ./ (Suu .* Syy);
end

% Ask FRF label
answer = inputdlg('Label for this FRF:','FRF label',1,{'Run 1'});
if isempty(answer)
    frfLabel = sprintf('Run %d', now);  % fallback
else
    frfLabel = answer{1};
end

figure(10);

k = 1; % Which frf to show?

% Create figure only once
if isempty(findobj(gcf,'Type','axes'))
    clf
end

subplot(2,1,1)
semilogx(f,20*log10(abs(G(k,:))), ...
    'DisplayName', frfLabel);
hold on
ylabel('Magnitude [dB]');
grid on
title('FRF comparison:')

legend('show','Location','best')

subplot(2,1,2)
semilogx(f, wrapTo180(unwrap(angle(G(k,:)))*180/pi), ...
    'DisplayName', frfLabel);
hold on
ylabel('Phase [deg]');
xlabel('Frequency [Hz]');
grid on

legend('show','Location','best')