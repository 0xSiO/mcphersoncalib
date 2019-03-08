function mcphersoncalib(type, grooves, center)
% mcphersoncalib: Calibrate SPE data from spectrometer.
%   type: 'neon', 'mercury'
%   grooves: how many grooves in the grating you're using.
%   center: approx. center wavelength from spectrometer dial.
% TODO: Make the range used to narrow down possible wavelengths
% configurable, currently it searches +-256 pixels.

% 512 pixels in SPE snapshot, 
%   300 groove: 1 pixel = 0.114 nm, actual center shifted left 
%     on average of:
%     9.4, 7.83, 7.29, 8.14, 7.82, 9.31, 8.68, 7.93, 7.93, 8.74 nm
%       (based on several manual tests)
%   TODO: confirm this! 1200 groove: 1 pixel = 0.69981 nm
%   TODO: other gratings
multiplier = 0.114;
offset = 9.4;
center_wavelength_approx = 1800/grooves * center - offset

% Range stretches across entire snapshot.
wavelength_range = [center_wavelength_approx - 256 * multiplier, center_wavelength_approx + 256 * multiplier];

% TODO: currently some locations are missing. See NIST database for more
% accurate data.
neon_peaks = [336.99, 341.790, 344.770, 346.658, 347.257, 352.047, 359.353, ...
              533.078, 534.109, 540.056, 585.249, 588.190, 594.483, 597.553, ...
              603.000, 607.434, 609.616, 614.306, 616.359, 621.728, 626.650, ...
              630.479, 633.443, 638.299, 640.225, 650.653, 653.288, 659.895, ...
              667.828, 671.704, 692.947, 702.405, 703.241, 705.911, 717.394, ...
              724.517, 747.244, 748.887, 753.577, 754.404, 783.906, 794.318, ...
              808.246, 811.855, 813.641, 825.938, 826.608, 830.033, 836.575, ...
              837.761, 849.536, 863.465, 865.438, 878.062, 878.375, 885.387, ...
              920.176, 1056.241, 1079.804, 1084.448];

% These are locations of moderate to large peaks that are definitely 
% resolvable by the 300 groove grating.
neon_peaks_300 = [692.947, 703.241, 717.394, 724.517, 743.890, 748.890, ...
                  753.577, 754.404, ...
                  794.318, 808.246, 811.855, 813.641, 826.608, 830.033, ...
                  837.761, 841.843, 849.536, 859.126, ...
                  863.465, 865.438, 868.192, 878.062, 885.387, 886.576, ...
                  891.950, 914.867, 920.176, ...
                  922.006, 930.085, 932.651, 942.538, ...
                  953.416, ...
                  954.741, 966.542, ...
                  ];
              
peak_locations = neon_peaks_300; % change depending on grating used
              
possible_peaks = peak_locations(peak_locations > wavelength_range(1) & peak_locations < wavelength_range(2))
end