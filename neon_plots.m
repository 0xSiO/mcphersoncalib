clc; clf; clear;

center = 137;
scale = 0.114;
data = double(readSPE(['300_groove_neon_spectra/', num2str(center), '.spe']));
plot(scale*(1:512), data);
xlim([scale, scale*512]);

known_peaks = [808.2460  813.6410  830.0330  837.7610  841.8430];

[peaks, locs] = findpeaks(data, 'MinPeakHeight', 250);
hold on
plot(scale*locs, peaks, 'rx');

locs = locs(end-length(known_peaks)+1:end);
peaks = peaks(end-length(known_peaks)+1:end);

fit_coeffs = polyfit(locs, known_peaks, 1)
fit = @(pixels) polyval(fit_coeffs, pixels);
percent_error = (known_peaks - fit(locs))./known_peaks * 100

hold off
plot(fit(1:512), data);
xlim([fit(1), fit(512)]);
hold on
plot(fit(locs), peaks, 'rx');