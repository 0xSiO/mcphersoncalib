clc; clf; clear;

center = 160;
scale = 0.114;
data = double(readSPE(['300_groove_neon_spectra/', num2str(center), '.spe']));
plot(scale*(1:512), data);
xlim([scale, scale*512]);

known_peaks = [930.085, 931.058, 931.397, 932.651, 942.538, 945.921, ...
    953.416, 954.741, 966.542];

[peaks, locs] = findpeaks(data, 'MinPeakHeight', 130);
hold on
plot(scale*locs, peaks, 'rx');

locs = locs(2:length(known_peaks)+1);
peaks = peaks(2:length(known_peaks)+1);

fit_coeffs = polyfit(locs, known_peaks, 1)
fit = @(pixels) polyval(fit_coeffs, pixels);
percent_error = (known_peaks - fit(locs))./known_peaks * 100

hold off
plot(fit(1:512), data);
xlim([fit(1), fit(512)]);
hold on
plot(fit(locs), peaks, 'rx');