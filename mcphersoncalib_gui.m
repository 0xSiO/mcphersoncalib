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
        'String', 'Adjust Fit', 'Callback', @adjust_fit);
    data.status_msg = uicontrol('Style', 'text', 'Position', [10, 0, 1000, 25], ...
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
        data.status_msg.String = 'Enter the number of grooves and an approximate center wavelength, then click "Adjust Fit".';
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
    [multiplier, center_wavelength_approx, wavelength_range, possible_peaks] = mcphersoncalib(num_grooves, approx_center)

    % Plot entire spectrum
    far_left_bound = center_wavelength_approx - 255 * multiplier;
    far_right_bound = center_wavelength_approx + 256 * multiplier;
    plot_data(linspace(far_left_bound, far_right_bound, 512), data.calibration_data);

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

    msg = ['Approximate scale created. Looking for ', num2str(length(possible_peaks)), ' peaks at: ', ...
        regexprep(num2str(possible_peaks), '\s+', ', '), '. Change left, right, and lower bounds of search area.'];
    data.status_msg.String = msg;
end
