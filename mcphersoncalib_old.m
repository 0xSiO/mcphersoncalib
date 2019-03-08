clear; clc; close all;

% This uses data from the 50 groove grating
calibration_data = double(readSPE('calibration.SPE'));

% Minimum peak intensity: 600
[peaks, peak_locations] = findpeaks(calibration_data, 'MinPeakHeight', 600);
peak_values = calibration_data(peak_locations);

figure(1);
subplot(2, 1, 1);
plot_calibration_peaks(calibration_data, peak_locations);

% This gives us 6 peaks. Let's match to known corresponding wavelengths.
known_peak_wavelengths = [640.225, 650.653, 670, 692.947, 703.241, 724.517];

% Find a fit to convert pixels to wavelengths
coeffs = polyfit(peak_locations, known_peak_wavelengths, 1);
get_wavelength = @(pixel) coeffs(1)*pixel + coeffs(2);

% Plot corrected data
subplot(2, 1, 2);
plot(get_wavelength(1:512), calibration_data);
xticks(550:10:900);
xlim([550, 900]);
box off
xlabel('Wavelength (nm)');
ylabel('Intensity (counts)');

disp(['wavelength = ', num2str(coeffs(1)), ' * pixel + ', num2str(coeffs(2))]);

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


