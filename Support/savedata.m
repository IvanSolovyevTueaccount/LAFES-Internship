clear all
load('u.mat');
u = ans;

load('y.mat');
y=ans;
fs = 250;    % sample frequency

N = length(u);


w = transpose(hann(N));
u_win = u(2,:) .* w;
y_win = y(2,:) .* w;

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
