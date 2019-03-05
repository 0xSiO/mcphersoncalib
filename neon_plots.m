clc; clf; clear;

center = 120;
data = readSPE(['300_groove_neon_spectra/', num2str(center), '.spe']);
plot((1:512)*0.11, data);
% xlim([0, 512]);   

known_peaks = [794.318, 808.246, 813.641, 826.608, 830.033];
pixel_peaks = findpeaks_dumb(data, 190, 0);

% fit_coeffs = polyfit(pixel_peaks, known_peaks, 1)
% fit = @(pixels) polyval(fit_coeffs, pixels);
% 
% plot(fit(1:512), data);
% hold on
% plot(fit(pixel_peaks), data(pixel_peaks), 'rx');