function mcphersoncalib(type, grooves, center)
% mcphersoncalib: Calibrate SPE data from spectrometer.
%   type: 'neon', 'mercury'
%   grooves: how many grooves in the grating you're using.
%   center: approx. center wavelength from spectrometer dial.

% 512 pixels in SPE snapshot, 
%   300 groove: 1 pixel = 0.114 nm, actual center shifted left 
%       ~9.4, 7.83 nm
%   TODO: confirm this! 1200 groove: 1 pixel = 0.69981 nm
%   TODO: other gratings
multiplier = 0.114;
offset = 9.4;
center_wavelength_approx = 1800/grooves * center - offset

% Range stretches across entire snapshot.
wavelength_range = [center_wavelength_approx - 256 * multiplier, center_wavelength_approx + 256 * multiplier];

neon_peaks = [336.99, 341.790, 344.770, 346.658, 347.257, 352.047, 359.353, ...
              533.078, 534.109, 540.056, 585.249, 588.190, 594.483, 597.553, ...
              603.000, 607.434, 609.616, 614.306, 616.359, 621.728, 626.650, ...
              630.479, 633.443, 638.299, 640.225, 650.653, 653.288, 659.895, ...
              667.828, 671.704, 692.947, 702.405, 703.241, 705.911, 717.394, ...
              724.517, 747.244, 748.887, 753.577, 754.404, 783.906, 794.318, ...
              808.246, 811.855, 813.641, 825.938, 826.608, 830.033, 836.575, ...
              837.761, 849.536, 863.465, 865.438, 878.062, 878.375, 885.387, ...
              920.176, 1056.241, 1079.804, 1084.448];

neon_peaks_300 = [692.947, 703.241, 717.394, 724.517, 747.244, 794.318, ...
                  808.246, 813.641, 826.608, 830.033];
              
peak_locations = neon_peaks_300; % change depending on grating used
              
possible_peaks = peak_locations(peak_locations > wavelength_range(1) & peak_locations < wavelength_range(2))
end