clear; clc; close all;

% wavelength = 0.023886 * pixel + 696.6008
% offset: +5.66
calibration_data = double(readSPE('1200_groove_neon_spectra/calibration_1200gv_06252019_centeredat_464.7.SPE'));

% wavelength = 0.023738 * pixel + 691.9743
% offset: +5.50
%calibration_data = double(readSPE('1200_groove_neon_spectra/calibration_1200gv_06252019_centeredat_461.7.SPE'));

% wavelength = 0.024247 * pixel + 649.2049
% offset: +5.16
%calibration_data = double(readSPE('1200_groove_neon_spectra/calibration_1200gv_06252019_centeredat_433.5.SPE'));

% wavelength = 0.024798 * pixel + 606.0208
% offset: +4.87
%calibration_data = double(readSPE('1200_groove_neon_spectra/calibration_1200gv_06252019_centeredat_405.SPE'));

[peaks, peak_locations] = findpeaks(calibration_data, 'MinPeakHeight', 415);
peak_values = calibration_data(peak_locations);

figure(2);
subplot(2, 1, 1);
% Plot raw spectrometer data with given peaks
hold on
plot(calibration_data, 'b');
plot(peak_locations, calibration_data(peak_locations), 'r.', 'MarkerSize', 15);
xticks(0:20:512);
xlim([0, 512]);
hold off

xlabel('Pixels');
ylabel('Intensity (counts)');

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
actual_data_1 = readSPE('other_data/NDTBMulti_10mW_532_600LP_30s.SPE');
actual_data_2 = readSPE('other_data/NDTBMulti_10mW_532_747BP_30s.SPE');

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
