function plot_calibration_peaks(calibration_data, peak_locations)
% Plot raw spectrometer data with given peaks
hold on
plot(calibration_data, 'b');
plot(peak_locations, calibration_data(peak_locations), 'r.', 'MarkerSize', 15);
xticks(0:20:512);
xlim([0, 512]);
hold off

xlabel('Pixels');
ylabel('Intensity (counts)');

end