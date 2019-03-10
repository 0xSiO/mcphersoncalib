f = figure('Visible', 'off', 'Position', [100, 100, 1200, 800]);
f.Name = 'McPherson Calibation';

load_btn = uicontrol('Style', 'pushbutton', 'Position', [10, 10, 90, 25], ...
    'String', 'Load Spectra', 'Callback', @load_spe_file);
uicontrol('Style', 'text', 'Position', [110, 30, 70, 25], ...
    'String', '# of Grooves');
groove_number = uicontrol('Style', 'edit', 'Position', [110, 10, 70, 25]);
uicontrol('Style', 'text', 'Position', [200, 30, 70, 25], ...
    'String', 'Center (nm)');
approx_center = uicontrol('Style', 'edit', 'Position', [200, 10, 70, 25]);
fit_btn = uicontrol('Style', 'pushbutton', 'Position', [290, 10, 70, 25], ...
    'String', 'Try Fit');

ha = axes('Units', 'pixels', 'Position', [50,100,1140,680]);

movegui(f, 'center');
f.Visible = 'on';

function load_spe_file(obj, event, handles)
    [file, path] = uigetfile('*.spe');
    if file == 0
        return;
    else
        setappdata(gcf, 'calibration_data', readSPE(path, file));
        plot_calibration_data;
    end
end

function plot_calibration_data
    plot(getappdata(gcf, 'calibration_data'));
    xlim([1, 512]);
end