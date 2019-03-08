clc; clf; clear;

center = 155;
scale = 0.114;
data = double(readSPE(['300_groove_neon_spectra/', num2str(center), '.spe']));
plot(scale*(1:512), data);
xlim([scale, scale*512]);

known_peaks = [914.867, 920.176, 922.006, 930.085, 932.651, 942.538];

[peaks, locs] = findpeaks(data, 'MinPeakHeight', 160);
hold on
plot(scale*locs, peaks, 'rx');

locs = locs(1:length(known_peaks));
peaks = peaks(1:length(known_peaks));

fit_coeffs = polyfit(locs, known_peaks, 1)
fit = @(pixels) polyval(fit_coeffs, pixels);
percent_error = (known_peaks - fit(locs))./known_peaks * 100

hold off
plot(fit(1:512), data);
xlim([fit(1), fit(512)]);
hold on
plot(fit(locs), peaks, 'rx');