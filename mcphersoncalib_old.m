clear;

% This uses data from the 1200 groove grating
%calibration_data = double(readSPE('50_groove_neon_spectra/calibration_50grv_06192019_centered_at_18.SPE'));

% wavelength = 0.023886 * pixel + 700.0164
calibration_data = double(readSPE('1200_groove_neon_spectra/calibration_1200gv_06212019_centeredat_467.SPE'));
%calibration_data = double(readSPE('1200_groove_neon_spectra/calibration_1200gv_06212019_centeredat_440.3.SPE'));

[peaks, peak_locations] = findpeaks(calibration_data, 'MinPeakHeight', 415);
peak_values = calibration_data(peak_locations);

figure(2);
subplot(2, 1, 1);
plot_calibration_peaks(calibration_data, peak_locations);

% This gives us some peaks. Let's match to known corresponding wavelengths.
known_peak_wavelengths = [702.405, 703.241]

% Find a fit to convert pixels to wavelengths
coeffs = polyfit(peak_locations, known_peak_wavelengths, 1);
get_wavelength = @(pixel) coeffs(1)*pixel + coeffs(2);

% Plot corrected data
subplot(2, 1, 2);
plot(get_wavelength(1:512), calibration_data);
xticks(600:10:730);
xlim([600, 730]);
box off
xlabel('Wavelength (nm)');
ylabel('Intensity (counts)');

disp(['wavelength = ', num2str(coeffs(1)), ' * pixel + ', num2str(coeffs(2))]);
avg_pcnt_err = mean(abs(known_peak_wavelengths - get_wavelength(peak_locations)) ./ known_peak_wavelengths .* 100)

%% Example client program
actual_data_1 = readSPE('NDTBMulti_10mW_532_600LP_30s.SPE');
actual_data_2 = readSPE('NDTBMulti_10mW_532_747BP_30s.SPE');

figure(2);
subplot(2, 1, 1);
hold on
title('NDTBMulti\_10mW\_532\_600LP\_30s');
plot(get_wavelength(1:512), actual_data_1);
xticks(550:10:900);
xlim([550, 900]);
xlabel('Wavelength (nm)');
ylabel('Intensity (counts)');

subplot(2, 1, 2);
hold on
title('NDTBMulti\_10mW\_532\_747BP\_30s');
plot(get_wavelength(1:512), actual_data_2);
xticks(550:10:900);
xlim([550, 900]);
xlabel('Wavelength (nm)');
ylabel('Intensity (counts)');


