load("input.mat")
load("torque.mat")
load("position1.mat")
load("position2.mat")

t = torque(1,:); 
u = input(2,:);
y = [position1(2,:); position2(2,:); position2(2,:) - position1(2,:)];
nOutputs = size(y,1);

dt = mean(diff(t));
fs = 1/dt;

idx_start = find(t >= 10, 1, 'first');

t = t(idx_start:end);
u = u(idx_start:end);
y = y(:, idx_start:end);

nfft = 2^nextpow2(length(u)/128);
noverlap = 0.5*nfft;
window = hann(nfft);

[Suu,f] = pwelch(u, window, noverlap, nfft, fs);

G = zeros(nOutputs,length(f));
coh = zeros(nOutputs,length(f));

for k = 1:nOutputs
    [Syy,~] = pwelch(y(k,:), window, noverlap, nfft, fs);
    [Syu,~] = cpsd(y(k,:), u, window, noverlap, nfft, fs);

    G(k,:) = Syu ./ Suu;
    coh(k,:) = abs(Syu).^2 ./ (Suu .* Syy);
end


figure(1)
clf
hold on
plot(t, u/1000);
for k = 1:nOutputs
    plot(t, y(k,:));
end
legend(["input" "x1" "x2" "x2-x1"])

figure(2); clf; hold on
for k = 1:nOutputs
    semilogx(f, coh(k,:));
end
grid on
xlabel('Frequency [Hz]');
ylabel('Coherence');
ylim([0 1]);
legend('Position1','Position2','Difference');
title('Coherence between Torque Input and Measured Positions');

figure(3);
clf
for k = 1:nOutputs
    subplot(2,1,1)
    semilogx(f,20*log10(abs(G(k,:)))); hold on
    ylabel('Magnitude [dB]'); grid on
    title('FRFs: Position / Torque')
    
    subplot(2,1,2)
    semilogx(f, wrapTo180(unwrap(angle(G(k,:)))*180/pi)); hold on;
    ylabel('Phase [rad]'); xlabel('Frequency [Hz]'); grid on

end
legend('Position1','Position2','Difference')