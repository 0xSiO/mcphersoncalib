clear; clc; close all;

data.fig = figure('Visible', 'off', 'Position', [100, 100, 1200, 820]);
data.fig.Name = 'McPherson Calibation';
data = add_ui_components(data);

movegui(data.fig, 'center');
data.fig.Resize = false;
data.fig.Visible = 'on';

guidata(data.fig, data);

function new_data = add_ui_components(data)
    data.load_btn = uicontrol('Style', 'pushbutton', 'Position', [10, 30, 90, 25], ...
    'String', 'Load Spectrum', 'Callback', @load_spe_file);
    uicontrol('Style', 'text', 'Position', [110, 50, 70, 25], 'String', '# of Grooves');
    data.groove_number_field = uicontrol('Style', 'edit', 'Position', [110, 30, 70, 25]);
    uicontrol('Style', 'text', 'Position', [195, 50, 60, 25], 'String', 'Center (nm)');
    data.approx_center_field = uicontrol('Style', 'edit', 'Position', [190, 30, 70, 25]);
    uicontrol('Style', 'text', 'Position', [270, 50, 80, 25], 'String', 'Left Bound (nm)');
    data.left_bound_field = uicontrol('Style', 'edit', 'Position', [270, 30, 80, 25]);
    uicontrol('Style', 'text', 'Position', [360, 50, 85, 25], 'String', 'Right Bound (nm)');
    data.right_bound_field = uicontrol('Style', 'edit', 'Position', [360, 30, 85, 25]);
    uicontrol('Style', 'text', 'Position', [455, 50, 95, 25], 'String', 'Lower Bound (nm)');
    data.lower_bound_field = uicontrol('Style', 'edit', 'Position', [455, 30, 90, 25]);
    data.adjust_fit_btn = uicontrol('Style', 'pushbutton', 'Position', [555, 30, 75, 25], ...
        'String', 'Adjust Fit', 'Enable', 'off', 'Callback', @adjust_fit);
    data.try_fit_btn = uicontrol('Style', 'pushbutton', 'Position', [640, 30, 75, 25], ...
        'String', 'Try Fit', 'Enable', 'off', 'Callback', @try_fit);
    data.status_msg = uicontrol('Style', 'text', 'Position', [10, 5, 1100, 25], ...
        'HorizontalAlignment', 'left', 'String', 'Click "Load Spectrum" to begin.');
    data.axes = axes('Units', 'pixels', 'Position', [50, 120, 1130, 660]);
    new_data = data;
end

function [num_grooves, approx_center, left_bound, right_bound, lower_bound] = load_parameters(data)
    num_grooves = str2double(data.groove_number_field.String);
    approx_center = str2double(data.approx_center_field.String);
    left_bound = str2double(data.left_bound_field.String);
    right_bound = str2double(data.right_bound_field.String);
    lower_bound = str2double(data.lower_bound_field.String);
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
        data.adjust_fit_btn.Enable = 'on';
        data.status_msg.String = msg;
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
    data.status_msg.String = msg;

    if length(peak_locs) == length(possible_peaks)
        % We're ready to try a fit
        data.try_fit_btn.Enable = 'on';
        data.possible_peaks = possible_peaks;
        data.found_peaks = found_peaks;
        data.peak_locs = peak_locs;
    else
        data.try_fit_btn.Enable = 'off';
    end

    guidata(data.fig, data);
end

function try_fit(obj, event)
    data = guidata(obj);
    possible_peaks = data.possible_peaks;
    peak_locs = data.peak_locs;
    coeffs = polyfit(peak_locs, possible_peaks, 1);
    fit = @(pixels) polyval(coeffs, pixels);
    percent_errors = abs(possible_peaks - fit(peak_locs))./possible_peaks * 100;

    msg = ['Fit: Wavelength = ', num2str(coeffs(1)), '*Pixel + ', num2str(coeffs(2)), ...
        '. Confidence: ', num2str(100 - mean(percent_errors)), '%'];
    data.status_msg.String = msg;
end
