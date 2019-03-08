% function mcphersoncalib_gui
f = figure('Visible', 'on', 'Position', [100, 100, 1200, 800]);

uicontrol('Style', 'text', 'String', '# of Grooves',  'Position', [10, 30, 80, 25]);
field_1 = uicontrol('Style', 'edit', 'String', '',    'Position', [15, 10, 70, 25]);
uicontrol('Style', 'text', 'String', 'Center (nm)',   'Position', [95, 30, 70, 25]);
field_2 = uicontrol('Style', 'edit', 'String', '',    'Position', [95, 10, 70, 25]);
fit_btn = uicontrol('Style', 'pushbutton', 'String', 'Try Fit', 'Position', [180, 10, 70, 25]);

ha = axes('Units', 'pixels', 'Position', [30,100,1140,680]);

% end