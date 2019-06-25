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
    data.btn.apply_fit = uicontrol('Style', 'pushbutton', 'Position', [640, 35, 75, 25], ...
        'String', 'Apply Fit', 'Enable', 'off', 'Callback', @apply_fit);
    data.btn.save_data = uicontrol('Style', 'pushbutton', 'Position', [725, 35, 75, 25], ...
        'String', 'Save Data', 'Enable', 'off', 'Callback', @save_data);
    data.txt.status = uicontrol('Style', 'text', 'Position', [10, 5, 1360, 25], ...
        'HorizontalAlignment', 'left', 'String', 'Click "Load Spectrum" to begin.');
    data.axes = axes('Units', 'pixels', 'Position', [60, 120, 1100, 660]);

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
        xlabel('Pixels');
        ylabel('Counts');
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
    xlabel('Approx. Wavelength (nm)');
    ylabel('Counts');

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

    if ~isempty(possible_peaks)
        search_filter = new_axis > left_bound & new_axis < right_bound;
        [found_heights, found_peaks] = findpeaks(data.calibration_data(search_filter), new_axis(search_filter), ...
            'MinPeakHeight', lower_bound, 'NPeaks', length(possible_peaks), 'SortStr', 'descend');
        plot(found_peaks, found_heights, 'r.', 'MarkerSize', 10);

        % Convert approximate locations back to indices
        index_filter = ismember(new_axis, found_peaks);
        peak_locs = old_axis(index_filter);
    else
        % findpeaks complains if you tell it to find zero peaks
        peak_locs = [];
    end

    msg = ['Approximate scale created. Looking for ', num2str(length(possible_peaks)), ' peaks at: ', ...
        regexprep(num2str(possible_peaks), '\s+', ', '), '. Found ', num2str(length(peak_locs)), ...
        ' peaks. Change left, right, and lower bounds of search area, if needed.'];
    data.txt.status.String = msg;

    % Can make a fit if number of auto-fitted points matches number of
    % expected points, OR if we just have >= 2 manual points. If we have
    % the wrong number of auto-fitted points and no manual points, we're
    % out of luck.
    if length(peak_locs) == length(possible_peaks) && ~isempty(peak_locs)
        data.btn.apply_fit.Enable = 'on';
        data.auto_pixel_map = [peak_locs.', possible_peaks.'];
    elseif isempty(peak_locs) && size(data.manual_points, 1) >= 2
        data.btn.apply_fit.Enable = 'on';
        data.auto_pixel_map = [];
    else
        data.btn.apply_fit.Enable = 'off';
        data.auto_pixel_map = [];
    end

    data.approximate_axis = new_axis;

    guidata(data.fig, data);
end

function apply_fit(obj, event)
    map_manual_points_to_pixels(guidata(obj));
    upsert_manual_points(guidata(obj));
    data = guidata(obj);

    all_locs = data.all_points(:, 1);
    all_peaks = data.all_points(:, 2);

    coeffs = polyfit(all_locs, all_peaks, 1);
    fit = @(pixels) polyval(coeffs, pixels);
    percent_errors = abs(all_peaks - fit(all_locs))./all_peaks * 100;

    new_axis = fit(1:512);
    plot_data(new_axis, data.calibration_data);
    xlabel('Wavelength (nm)');
    ylabel('Counts');

    msg = ['Fit: Wavelength = ', num2str(coeffs(1)), '*Pixel + ', num2str(coeffs(2)), ...
        '. Average Error: ', num2str(mean(percent_errors)), '%'];
    data.btn.save_data.Enable = 'on';
    data.txt.status.String = msg;
    data.fit = fit;

    guidata(data.fig, data);
end

function save_data(obj, event)
    gui_data = guidata(obj);
    data = [gui_data.fit(1:512); gui_data.calibration_data].';
    [file, path] = uiputfile('*.mat', 'Save fitted data', '');
    if file == 0
        return;
    else
        save([path, file], 'data');
    end
end

% Add manual points to the peaks to be fitted. If there are manual points
% that coincide with auto-fitted points, just overwrite them. ("update-insert")
function upsert_manual_points(data)
    for n = 1:size(data.auto_pixel_map, 1)
        for m = 1:size(data.manual_pixel_map, 1)
            if data.auto_pixel_map(n, 1) == data.manual_pixel_map(m, 1)
                data.auto_pixel_map(m, :) = [0, 0];
            end
        end
    end

    if isempty(data.auto_pixel_map)
        % This will make the union() of auto and manual points work
        data.auto_pixel_map = [0, 0];
    end

    auto_and_manual_peaks = union(data.manual_pixel_map, data.auto_pixel_map, 'rows');
    % Remove rows of zeros and duplicates
    auto_and_manual_peaks = auto_and_manual_peaks(any(auto_and_manual_peaks, 2),:);
    data.all_points = unique(auto_and_manual_peaks, 'stable', 'rows');
    guidata(data.fig, data);
end

function manually_add_point(obj, event)
    data = guidata(obj);
    approx_wavelength = str2double(data.field.manual_add.approx_wavelength.String);
    actual_wavelength = str2double(data.field.manual_add.actual_wavelength.String);

    % This only works if approx_wavelength is not NaN; we'll check if
    % actual_wavelength is not NaN a bit later
    if ~isnan(approx_wavelength)
        % Upsert a point to manual points list, or remove if
        % actual_wavelength is NaN
        if ~isempty(data.manual_points)
            if ~ismember(approx_wavelength, data.manual_points(:, 1)) && ~isnan(actual_wavelength)
                % insert
                data.manual_points = [data.manual_points; approx_wavelength, actual_wavelength];
            else
                existing_point_loc = ismember(data.manual_points(:, 1), approx_wavelength);
                if ~isnan(actual_wavelength)
                    % update
                    data.manual_points(existing_point_loc, :) = [approx_wavelength, actual_wavelength];
                else
                    % remove
                    data.manual_points(existing_point_loc, :) = [];
                end
            end
        elseif ~isnan(actual_wavelength)
            data.manual_points = [approx_wavelength, actual_wavelength];
        end
        points = string(data.manual_points);
        data.txt.manual_points.String = "(" + points(:, 1) + ", " + points(:, 2) + ")";
        guidata(data.fig, data);
    end
end

% Convert manual points to pixel indexes: subtract manual wavelength value
% from all values on approximate axis, find the point at which the
% difference is the smallest, pick that index to use for the fit.
function map_manual_points_to_pixels(data)
    data.manual_pixel_map = zeros(size(data.manual_points));
    for n = 1:size(data.manual_points, 1)
        manual_location = data.manual_points(n, 1);
        manual_wavelength = data.manual_points(n, 2);
        [~, index] = min(abs(data.approximate_axis - manual_location));
        data.manual_pixel_map(n, :) = [index, manual_wavelength];
    end
    guidata(data.fig, data);
end
