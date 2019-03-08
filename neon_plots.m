clc; clf; clear;

center = 105;
scale = 0.114;
data = double(readSPE(['300_groove_neon_spectra/', num2str(center), '.spe']));
plot(scale*(1:512), data);
xlim([scale, scale*512]);

known_peaks = [594.483, 597.553, 603.000, 607.434, 609.616, 614.306, 616.359, 621.728, ...
    626.6500  630.4790  633.4430  638.2990  640.2250  650.6520];

[peaks, locs] = findpeaks(data, 'MinPeakHeight', 500);
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