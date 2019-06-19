function [multiplier, center_wavelength_approx, wavelength_range, possible_peaks] = mcphersoncalib(grooves, center)
% mcphersoncalib: Calibrate SPE data from spectrometer.
%   grooves: how many grooves in the grating you're using.
%   center: approx. center wavelength from spectrometer dial.

% 512 pixels in SPE snapshot.

% 50 groove:  1 pixel = 0.706 nm, offset manually calibrated to 0 nm
% TODO: Double check offsets for all gratings
multiplier_50 = 0.706;
offset_50 = 9.69;

% 300 groove: 1 pixel = 0.114 nm, actual center shifted left 8.60 nm
%     this is a guess based on several manual fits that gave offsets of:
%     7.93, 6.51, 8.13, 10.63, 10.31, 9.4, 7.83, 7.29, 8.14, 7.82, 9.31, 8.68, 7.93, 7.93, 8.74, 8.85
multiplier_300 = 0.114;
offset_300 = 6.64;

%   TODO: other gratings

% The following is a list of peaks that should be resolvable by the very
% higher-groove gratings (union of all other lower-groove gratings)
% TODO: currently some locations are missing. See NIST database for more
% accurate data.
% use setdiff(some_vec, neon_peaks) to see values not in this vector
neon_peaks = [
    336.990, 341.790, 344.770, 346.658, 347.257, 352.047, 359.353, ...
    533.078, 534.109, 540.056, 585.249, 588.190, 594.483, 597.553, ...
    603.000, 607.434, 609.616, 614.306, 616.359, 621.728, 626.650, ...
    630.479, 633.443, 638.299, 640.225, 650.653, 653.288, 659.895, ...
    667.828, 671.704, 692.947, 702.405, 703.241, 705.911, 717.394, ...
    724.517, 747.244, 748.887, 753.577, 754.404, 783.906, 794.318, ...
    808.246, 811.855, 813.641, 825.938, 826.608, 830.033, 836.575, ...
    837.761, 849.536, 863.465, 865.438, 878.062, 878.375, 885.387, ...
    920.176, 1056.241, 1079.804, 1084.448];

% The following are locations of peaks that are definitely resolvable by
% each grating. Peaks composed of two spectral lines that have 'merged' are
% not included.
neon_peaks_50 = [
    614.306, 640.225, 650.653, 659.895, 667.828, 671.704, 692.947, ...
    703.241, 724.517, 743.890];

neon_peaks_300 = [
    585.249, 588.190, 594.483, 597.553, 603.000, 607.434, 609.616, ...
    614.306, 616.359, 621.728, 626.650, 630.479, 633.443, 638.299, ...
    640.225, 650.652, 653.288, 659.895, 667.828, 671.704, 692.947, ...
    703.241, 717.394, 724.517, 743.890, 748.890, 753.577, 754.404, ...
    808.246, 813.641, 830.033, 837.761, 841.843, 849.536, 859.126, ...
    863.465, 865.438, 868.192, 878.062, 885.387, 886.576, 891.950, ...
    914.867, 920.176, 922.006, 930.085, 932.651, 942.538, 953.416, ...
    954.741, 966.542];

if grooves == 50
    multiplier = multiplier_50;
    offset = offset_50;
    peak_locations = neon_peaks_50;
elseif grooves == 300
    multiplier = multiplier_300;
    offset = offset_300;
    peak_locations = neon_peaks_300;
end

center_wavelength_approx = 1800/grooves * center + offset;

% Range stretches (almost) across entire snapshot. This is configurable by
% adjusting the search area in the GUI.
left_bound = center_wavelength_approx - 250 * multiplier;
right_bound = center_wavelength_approx + 250 * multiplier;
wavelength_range = [left_bound, right_bound];

possible_peaks = peak_locations(peak_locations > wavelength_range(1) & peak_locations < wavelength_range(2));
end