u = simoutu;      % input noise
y = simouty;      % system output
fs = 1 / mean(diff(t));    % sample frequency

N = length(u);
u = u(:);
y = y(:);

w = hann(N);
u_win = u .* w;
y_win = y .* w;

U = fft(u_win);
Y = fft(y_win);

H = Y ./ U;

f = (0:N-1)*(fs/N);

figure;
subplot(2,1,1);
semilogx(f,20*log10(abs(H)));
grid on;
xlabel('Frequency (Hz)');
ylabel('|H(f)| (dB)');
title('FRF Magnitude');

subplot(2,1,2);
semilogx(f,unwrap(angle(H)));
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
title('FRF Phase');
