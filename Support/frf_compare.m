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
Nd_x2 = 5;   % delay of linear encoder [samples]

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

outputNames = {'x_{pulley}','x_2','x_2 - x_{pulley}'};

for k = 1:nOutputs
    figure(10+k);
    
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
    title(['FRF comparison: ' outputNames{k} ' / Torque'])
    
    legend('show','Location','best')
    
    subplot(2,1,2)
    semilogx(f, wrapTo180(unwrap(angle(G(k,:)))*180/pi), ...
        'DisplayName', frfLabel);
    hold on
    ylabel('Phase [deg]');
    xlabel('Frequency [Hz]');
    grid on
    
    legend('show','Location','best')
end