clear; clc; close all;

data.fig = figure('Visible', 'off', 'Position', [100, 100, 1400, 820]);
data.fig.Name = 'McPherson Calibation';
data = add_ui_components(data);

movegui(data.fig, 'center');
data.fig.Resize = false;
data.fig.Visible = 'on';

guidata(data.fig, data);

% TODO: Document accessible fields in the guidata structure
function new_data = add_ui_components(data)
    % Base UI to load and fit data
    data.btn.load = uicontrol('Style', 'pushbutton', 'Position', [10, 35, 90, 25], ...
    'String', 'Load Spectrum', 'Callback', @load_spe_file);
    uicontrol('Style', 'text', 'Position', [110, 50, 70, 25], 'String', '# of Grooves');
    data.field.groove_number = uicontrol('Style', 'edit', 'Position', [110, 35, 70, 25]);
    uicontrol('Style', 'text', 'Position', [195, 50, 60, 25], 'String', 'Center (nm)');
    data.field.approx_center = uicontrol('Style', 'edit', 'Position', [190, 35, 70, 25]);
    uicontrol('Style', 'text', 'Position', [270, 50, 80, 25], 'String', 'Left Bound (nm)');
    data.field.left_bound = uicontrol('Style', 'edit', 'Position', [270, 35, 80, 25]);
    uicontrol('Style', 'text', 'Position', [360, 50, 85, 25], 'String', 'Right Bound (nm)');
    data.field.right_bound = uicontrol('Style', 'edit', 'Position', [360, 35, 85, 25]);
    uicontrol('Style', 'text', 'Position', [455, 50, 95, 25], 'String', 'Lower Bound (nm)');
    data.field.lower_bound = uicontrol('Style', 'edit', 'Position', [455, 35, 90, 25]);
    data.btn.adjust_fit = uicontrol('Style', 'pushbutton', 'Position', [555, 35, 75, 25], ...
        'String', 'Adjust Fit', 'Enable', 'off', 'Callback', @adjust_fit);
    data.btn.try_fit = uicontrol('Style', 'pushbutton', 'Position', [640, 35, 75, 25], ...
        'String', 'Try Fit', 'Enable', 'off', 'Callback', @try_fit);
    data.txt.status = uicontrol('Style', 'text', 'Position', [10, 5, 1360, 25], ...
        'HorizontalAlignment', 'left', 'String', 'Click "Load Spectrum" to begin.');
    data.axes = axes('Units', 'pixels', 'Position', [40, 120, 1130, 660]);

    % UI to manually fit points
    uicontrol('Style', 'text', 'Position', [1220, 750, 120, 25], 'String', 'Manually Fit Points');
    uicontrol('Style', 'text', 'Position', [1180, 730, 200, 25], 'String', '(approx. wavelen , actual wavelen)');
    uicontrol('Style', 'text', 'Position', [1180, 710, 5, 25], 'String', '(', 'FontSize', 12);
    data.field.manual_add.approx_wavelength = uicontrol('Style', 'edit', 'Position', [1190, 715, 55, 20]);
    uicontrol('Style', 'text', 'Position', [1249, 710, 5, 25], 'String', ',', 'FontSize', 12);
    data.field.manual_add.actual_wavelength = uicontrol('Style', 'edit', 'Position', [1260, 715, 55, 20]);
    uicontrol('Style', 'text', 'Position', [1320, 710, 5, 25], 'String', ')', 'FontSize', 12);
    data.btn.manual_add.add = uicontrol('Style', 'pushbutton', 'Position', [1330, 715, 45, 20], 'String', 'Add', 'Callback', @manually_add_point);
    data.txt.manual_points = uicontrol('Style', 'text', 'Position', [1180, 30, 200, 680], 'String', '', 'FontSize', 10);
    data.manual_points = [];
    new_data = data;
end

function [num_grooves, approx_center, left_bound, right_bound, lower_bound] = load_parameters(data)
    num_grooves = str2double(data.field.groove_number.String);
    approx_center = str2double(data.field.approx_center.String);
    left_bound = str2double(data.field.left_bound.String);
    right_bound = str2double(data.field.right_bound.String);
    lower_bound = str2double(data.field.lower_bound.String);
    if isnan(lower_bound)
        lower_bound = 0;
    end
end

function load_spe_file(obj, event)
    [file, path] = uigetfile('*.spe');
    if file == 0
        return;
    else
        data = guidata(obj);
        data.calibration_data = double(readSPE(path, file));
        guidata(obj, data);
        plot_data(1:512, data.calibration_data);
        msg = ['Loaded ', file, '. Enter the number of grooves and an approximate center wavelength, then click "Adjust Fit".'];
        data.btn.adjust_fit.Enable = 'on';
        data.txt.status.String = msg;
    end
end

function plot_data(x, data)
    hold off
    plot(x, data);
    xlim([x(1), x(end)]);
    hold on
end

function adjust_fit(obj, event)
    data = guidata(obj);
    [num_grooves, approx_center, left_bound, right_bound, lower_bound] = load_parameters(data);
    [multiplier, center_wavelength_approx, wavelength_range, possible_peaks] = mcphersoncalib(num_grooves, approx_center);

    % Plot entire spectrum
    far_left_bound = center_wavelength_approx - 255 * multiplier;
    far_right_bound = center_wavelength_approx + 256 * multiplier;
    old_axis = 1:512;
    new_axis = linspace(far_left_bound, far_right_bound, 512);
    plot_data(new_axis, data.calibration_data);

    % Default left and right bounds for search area
    if isnan(left_bound)
        left_bound = wavelength_range(1);
    end
    if isnan(right_bound)
        right_bound = wavelength_range(2);
    end

    % Limit peak locations to within the search area
    possible_peaks = possible_peaks(possible_peaks > left_bound & possible_peaks < right_bound);

    % Plot search area
    top = data.axes.YLim(2);
    plot([left_bound, left_bound], [lower_bound, top], 'r--');
    plot([right_bound, right_bound], [lower_bound, top], 'r--');
    plot([left_bound, right_bound], [lower_bound, lower_bound], 'r--');

    search_filter = new_axis > left_bound & new_axis < right_bound;
    [found_heights, found_peaks] = findpeaks(data.calibration_data(search_filter), new_axis(search_filter), ...
        'MinPeakHeight', lower_bound, 'NPeaks', length(possible_peaks), 'SortStr', 'descend');
    plot(found_peaks, found_heights, 'r.', 'MarkerSize', 10);

    % Convert approximate locations back to indices
    index_filter = ismember(new_axis, found_peaks);
    peak_locs = old_axis(index_filter);

    msg = ['Approximate scale created. Looking for ', num2str(length(possible_peaks)), ' peaks at: ', ...
        regexprep(num2str(possible_peaks), '\s+', ', '), '. Found ', num2str(length(peak_locs)), ...
        ' peaks. Change left, right, and lower bounds of search area, if needed.'];
    data.txt.status.String = msg;

    % Can make a fit if number of auto-fitted points + manually fitted
    % points is >= number of peaks we're looking for, OR if we have 2 or
    % more manually fitted points.
    num_of_points = length(peak_locs) + length(data.manual_points);
    if num_of_points >= length(possible_peaks) || length(data.manual_points) >= 2
        data.btn.try_fit.Enable = 'on';
        data.possible_peaks = possible_peaks;
        data.found_peaks = found_peaks;
        data.peak_locs = peak_locs;
    else
        data.btn.try_fit.Enable = 'off';
    end

    data.approximate_axis = new_axis;

    guidata(data.fig, data);
end

function try_fit(obj, event)
    data = guidata(obj);
    possible_peaks = data.possible_peaks;
    peak_locs = data.peak_locs;

    % Combine these for final fit
    auto_pixel_map = [data.peak_locs.', data.possible_peaks.'];
    manual_pixel_map = map_manual_points_to_pixels(data);

    coeffs = polyfit(peak_locs, possible_peaks, 1);
    fit = @(pixels) polyval(coeffs, pixels);
    percent_errors = abs(possible_peaks - fit(peak_locs))./possible_peaks * 100;

    msg = ['Fit: Wavelength = ', num2str(coeffs(1)), '*Pixel + ', num2str(coeffs(2)), ...
        '. Average Error: ', num2str(mean(percent_errors)), '%'];
    data.txt.status.String = msg;
    data.fit = fit;

    guidata(data.fig, data);
end

% Add manual points to the peaks to be fitted. If there are manual points
% that coincide with auto-fitted points, just overwrite them. ("update-insert")
function auto_and_manual_peaks = upsert_manual_points(manual_pixel_map, auto_pixel_map)
end

function manually_add_point(obj, event)
    data = guidata(obj);
    approx_wavelength = str2double(data.field.manual_add.approx_wavelength.String);
    actual_wavelength = str2double(data.field.manual_add.actual_wavelength.String);

    if ~isnan(approx_wavelength) && ~isnan(actual_wavelength)
        data.manual_points = [data.manual_points; approx_wavelength, actual_wavelength];
        points = string(data.manual_points);
        data.txt.manual_points.String = "(" + points(:, 1) + ", " + points(:, 2) + ")";
        guidata(data.fig, data);
    end
end

% Convert manual points to pixel indexes: subtract manual wavelength value
% from all values on approximate axis, find the point at which the
% difference is the smallest, pick that index to use for the fit.
% Note this returns a matrix with doubles.
function manual_pixel_map = map_manual_points_to_pixels(data)
    manual_pixel_map = zeros(size(data.manual_points));
    for n = 1:length(data.manual_points)
        manual_location = data.manual_points(n, 1);
        manual_wavelength = data.manual_points(n, 2);
        [~, index] = min(abs(data.approximate_axis - manual_location));
        manual_pixel_map(n, :) = [index, manual_wavelength];
    end
end
