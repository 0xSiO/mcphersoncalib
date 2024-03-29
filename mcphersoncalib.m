function [multiplier, center_wavelength_approx, wavelength_range, possible_peaks] = mcphersoncalib(grooves, center)
% mcphersoncalib: Calibrate SPE data from spectrometer.
%   grooves: how many grooves in the grating you're using.
%   center: approx. center wavelength from spectrometer dial.

% 512 pixels in SPE snapshot.

% 50 groove:  1 pixel = 0.706 nm, actual center shifted right ~9.69 nm
multiplier_50 = 0.706;
offset_50 = 9.69;

% 300 groove: 1 pixel = 0.114 nm, actual center shifted right ~6.64 nm
multiplier_300 = 0.114;
offset_300 = 6.64;

% 1200 groove: 1 pixel = 0.024 nm, actual center shifted right ~5.63 nm
multiplier_1200 = 0.024;
offset_1200 = 5.30;

% TODO: other gratings

% The following is a list of peaks that should be resolvable by the
% 1200-groove grating. This is pulled directly from the NIST spectral
% lines database and includes most wavelengths that have a minimum
% "relative intensity" of 3000. Pairs of wavelengths that are too closely
% spaced have been replaced by the one that is more intense.
neon_peaks_1200 = [
    336.99069, 341.79031, 347.25706, 352.04714, 359.35263, ...
    442.25205, 442.48065, 448.80926, 453.77545, ...
    457.50620, 464.5418, 465.63936, 467.8218, 470.43949, ...
    470.88594, 471.20633, 471.5344, 474.95754, 475.2732, ...
    478.0338, 478.89258, 481.76386, 482.19218, 482.7338, ...
    483.73139, 488.4917, 489.209, 495.70335, 500.51587, ...
    503.77512, 514.49384, 533.07775, 534.10938, 534.32834, ...
    540.05616, 556.27662, 565.66588, 571.92248, 574.82985, 576.44188, ...
    580.44496, 581.14066, 582.01558, 585.24878, 587.28275, 588.1895, ...
    594.4834, 596.5471, 597.55343, 602.99968, 607.43376, ...
    609.6163, 614.30627, 616.35937, 621.72812, 626.64952, 632.81646, ...
    633.44276, 638.29914, 640.2248, 650.65277, 653.28824, 659.89528, 667.82766, ...
    692.94672, 702.405, 703.24128, 705.91079, 717.3938, 724.51665, ...
    743.88981, 747.24383, 748.88712, 753.57739, 754.40439, 794.31805, ...
    808.24576, 811.85495, 813.64061, 825.93795, 826.60769, 830.03248, ...
    836.57464, 837.7607, 841.84265, 846.33569, 849.53591, ...
    859.12583, 863.46472, 864.70412, 865.43828, 867.94936, ...
    868.19216, 877.16575, 878.06223, 878.37539, 885.38669, 886.57562, ...
    891.95007, 914.8672, 920.17588, 922.00598, 930.08532, 932.65072, ...
    942.53797, 948.66825, 953.4164, 966.542, 1056.24089, 1079.8043, ...
    1084.44774];

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
elseif grooves == 1200
    multiplier = multiplier_1200;
    offset = offset_1200;
    peak_locations = neon_peaks_1200;
end

center_wavelength_approx = 1800/grooves * center + offset;

% Range stretches (almost) across entire snapshot. This is configurable by
% adjusting the search area in the GUI.
left_bound = center_wavelength_approx - 250 * multiplier;
right_bound = center_wavelength_approx + 250 * multiplier;
wavelength_range = [left_bound, right_bound];

possible_peaks = peak_locations(peak_locations > wavelength_range(1) & peak_locations < wavelength_range(2));
end