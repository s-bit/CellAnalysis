% PixelAnalysis
% Tool for the collection and evaluation of pixel intensity data in micrographs.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%
% This file is part of PixelAnalysis.
%
% PixelAnalysis is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% PixelAnalysis is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with PixelAnalysis. If not, see http://www.gnu.org/licenses/.


function [] = PixelAnalysis(hObject, eventdata)
% Initialize
close all

screen_size = get(0,'ScreenSize');
screen_width = screen_size(3);
screen_height = screen_size(4);

window_width = screen_width*0.3;
window_height = screen_height*0.4;

% CHECK FOR UPDATES
% This program version
ThisVersion = '0.2';

% Get the latest version
[NewVersion,status] = urlread('https://raw.githubusercontent.com/s-bit/PixelAnalysis/master/CurrentVersion');

% Check if latest version is newer than this version
if status ~=0 && str2double(ThisVersion)<str2double(NewVersion)
    msg_h = msgbox('A newer version of PixelAnalysis is available! How to download:      "About" > "Download Update"', 'Update Notice');
    waitfor(msg_h)
end

% Construct Components
btn_width = screen_width*0.07;
btn_height = screen_height*0.04;

ui_window = figure(...
    'NumberTitle', 'off', ...
    'Name', 'PixelAnalysis - Main', ...
    'Tag', 'ui_window', ...
    'Menubar', 'none', ...
    'Visible','off', ...
    'Resize', 'off', ...
    'CloseRequestFcn', {@button_quit_Callback}, ...
    'Position',[screen_width*0.64, screen_height*0.046, window_width, window_height]);

main_menu = uimenu(ui_window,...
    'Label', 'About');
main_menu_license = uimenu(main_menu,...
    'Label', 'License',...
    'Callback', {@main_menu_license_Callback});
main_menu_update = uimenu(main_menu,...
    'Label', 'Download Update',...
    'Callback', {@main_menu_dlUpdate_Callback});

hload = uicontrol(...
    'Style', 'pushbutton', ...
    'String', 'Load Image', ...
    'Tag', 'hload', ...
    'FontSize', 10, ...
    'Position', [window_width*0.05, window_height*0.825, btn_width, btn_height],...
    'TooltipString', '<html><p>Import an <b>image file</b> for analysis.</p><p><b>Any image file format is allowed</b>.</p></html>', ...
    'Callback',{@button_load_Callback});

hmeasure = uicontrol(...
    'Style', 'togglebutton', ...
    'String', 'Analyze Cells', ...
    'Tag', 'hmeasure', ...
    'FontSize', 10, ...
    'Position', [window_width*0.05, window_height*0.585, btn_width, btn_height],...
    'TooltipString', char({'<html><p>Lets you draw a ROI line into the image which will then be used as an</p><p>axis in order to create a pixel intensity profile. Next, the pixel profile</p><p>will be <b>analyzed automatically</b>. The algorithm tries to identify cell</p><p>content and membranes (peaks) and will return the respective mean</p><p>intensities - additionally, the <b>membrane/cell ratio</b> will be returned.</p><p>If you like to, you can determine the position of membranes and cell</p><p>contents manually by clicking on "Analyze Manually".</p></html>'}), ...
    'Callback',{@toggle_measure_Callback}, ...
    'BusyAction', 'cancel');

hdiscard = uicontrol(...
    'Style', 'pushbutton', ...
    'String', 'Discard Last', ...
    'Tag', 'hdiscard', ...
    'FontSize', 10, ...
    'Position', [window_width*0.05, window_height*0.425, btn_width, btn_height],...
    'TooltipString', '<html><p>Discard your very latest analysis. <b>All data gathered during the</b></p><p><b>last analysis will be overwritten permanently!</b></p></html>', ...
    'Callback',{@button_discard_Callback});

hsave = uicontrol(...
    'Style', 'pushbutton', ...
    'String', 'Save Data', ...
    'Tag', 'hsave', ...
    'FontSize', 10, ...
    'Position', [window_width*0.05, window_height*0.075, btn_width, btn_height],...
    'TooltipString', '<html><p>Save all data collected in this session.</p><p>All intensitiy profiles will be saved as <b>png and epsc</b>; membrane/cell</p><p>ratios etc. will be saved as <b>txt</b> (can then be imported in Excel easily),</p><p>and the image with the ROI lines will be saved as <b>tif</b>. <b>You will be</b></p><p><b>asked to choose a save location, everything else is then done</b></p><p><b>automatically (i.e. file names, etc.)</b>.</p></html>', ...
    'Callback',{@button_save_Callback});

hquit = uicontrol(...
    'Style', 'pushbutton', ...
    'String', 'Quit', ...
    'Tag', 'hquit', ...
    'FontSize', 10, ...
    'Position', [window_width*0.72, window_height*0.075, btn_width, btn_height],...
    'TooltipString', '<html><p>Quit this program. All windows will be closed.</p><p><b>Everything not saved will be lost.</b></p></html>', ...
    'Callback',{@button_quit_Callback});

pnl_mode = uipanel(ui_window,...
    'Title', 'Analysis Mode', ...
    'FontSize', 11, ...
    'Position', [0.35 0.745 0.6 0.2]);

rb_across = uicontrol(pnl_mode, ...
    'Style','radiobutton',...
    'String','Across Cells',...
    'Tag', 'rb_across', ...
    'FontSize', 11, ...
    'Units','normalized',...
    'Position',[.075 .4 .5 .2],...
    'TooltipString', '<html><p>Draw a <b>ROI line across a whole cell (passing two plasma membranes)</b></p><p>and analyze the ratio between the two membrane peaks and the average</p><p>pixel intensity of the cell content.</p></html>', ...
    'Callback',{@rb_across_Callback});

rb_between = uicontrol(pnl_mode, ...
    'Style','radiobutton',...
    'String','Between Cells',...
    'Tag', 'rb_between', ...
    'FontSize', 11, ...
    'Units','normalized',...
    'Position',[.6 .4 .5 .2],...
    'TooltipString', '<html><p>Draw a <b>ROI line that starts inside a cell and passes two plasma</b></p><p><b>membranes in order to end in the neighboring cell´s cytoplasm</b>.</p></html>', ...
    'Callback',{@rb_between_Callback});

pnl_manual = uipanel(ui_window,...
    'Title', 'Manual Mode', ...
    'FontSize', 11, ...
    'Position', [0.35 0.25 0.6 0.45]);

hmanual = uicontrol(pnl_manual,...
    'Style', 'pushbutton', ...
    'String', 'Analyze Manually', ...
    'Tag', 'hmanual', ...
    'FontSize', 10, ...
    'Position', [window_width*0.05, window_height*0.22, btn_width, btn_height],...
    'TooltipString', '<html><p>Interactively set the location of the membrane and the beginning/end</p><p>of cell content in the pixel profile plot window. Further analyses</p><p>will then be conducted with your selection. Subsequent analyses will</p><p>be automatic, unless you click this button again.</p></html>', ...
    'Callback',{@button_manual_Callback});

hmanual_accept = uicontrol(pnl_manual,...
    'Style', 'pushbutton', ...
    'String', 'Accept', ...
    'Tag', 'hmanual_accept', ...
    'FontSize', 10, ...
    'Position', [window_width*0.315, window_height*0.29, btn_width, btn_height*0.9],...
    'TooltipString', '<html><p>Accept your selection and proceed with analysis. <b>Results of the</b></p><p><b>previous automatic analysis will be replaced.</b></p></html>', ...
    'Callback',{@button_manualAccept_Callback});

hmanual_reset = uicontrol(pnl_manual,...
    'Style', 'pushbutton', ...
    'String', 'Reset', ...
    'Tag', 'hmanual_reset', ...
    'FontSize', 10, ...
    'Position', [window_width*0.315, window_height*0.17, btn_width, btn_height*0.9],...
    'TooltipString', '<html><p>Reset your selection. By clicking on "Analyze Manually" you can start</p><p>over. Alternatively, you can keep the results of the automatic analysis.</p><p><b>No changes have been made so far.</b></p></html>', ...
    'Callback',{@button_manualReset_Callback});

hmanual_auto = uicontrol(pnl_manual,...
    'Style', 'pushbutton', ...
    'String', 'Redo Automatic', ...
    'Tag', 'hmanual_auto', ...
    'FontSize', 10, ...
    'Position', [window_width*0.155, window_height*0.04, btn_width*1.2, btn_height*0.9],...
    'TooltipString', '<html><p>Redo the automatic analysis and discard your manual analysis. <b>All data</b></p><p><b>collected during your manual analysis will be permanently overwritten.</b></p></html>', ...
    'Callback',{@button_manual_backToAuto_Callback});

% Show constructed UI
set(ui_window,'Visible','on')

% Hand over variables and handles, refresh guidata
setappdata(ui_window, 'screen_width', screen_width);
setappdata(ui_window, 'screen_height', screen_height);
handles = guihandles(ui_window);
guidata(ui_window, handles)

% Set default values
setappdata(handles.ui_window, 'user_saved', true)
setappdata(handles.ui_window, 'manual_analysis', [])
setappdata(handles.ui_window, 'pixprof_mod', false);

% Disable everything except hload
handlesArray = [handles.hmeasure, handles.hdiscard, handles.hsave, handles.rb_across, handles.rb_between, handles.hmanual, hmanual_accept, hmanual_reset, hmanual_auto];
set(handlesArray, 'Enable', 'off');

% Create figure for pixel profiles
handles.profile_window = figure(...
    'NumberTitle', 'off', ...
    'Name', 'PixelAnalysis - Pixel Intensity Profile', ...
    'Tag', 'profile_window', ...
    'Visible','off', ...
    'Resize', 'on', ...
    'CloseRequestFcn', '', ...
    'Position',[screen_width*0.64, screen_height*0.5475, window_width, window_height]);
handles.profile_axes = axes();
guidata(ui_window, handles)
end % of function



% C A L L B A C K S
% =========================================================================
function button_load_Callback(hObject, eventdata)
% Import image loop
cancel_import = false;
while 1 == 1
    [DataSourceName, DataSourcePath] = uigetfile({'*.tif; *.bmp; *.jpg; *.gif; *.png', 'Image Files'; '*.*', 'All Files'}, 'Select an Image File');
    
    % if image import is canceled nothing happens
    if DataSourcePath == 0
        cancel_import = true; 
        break
    % else it is checked whether the file is actually an image file
    else
        % if no image file information can be retrieved from the file it
        % possibly is not an image file --> error --> message --> next 
        % round of the import loop
        try 
            imfinfo([DataSourcePath DataSourceName]);
            break
        catch
            msg_h = errordlg('Please select an image file.', 'ERROR - wrong file format');
            waitfor(msg_h)
        end
    end
end

% if an image was imported successfully...
if cancel_import == false 
    % Initialize fundamental variables
    setappdata(hObject.Parent, 'counter', 1);
    setappdata(hObject.Parent, 'delete_last', 0);
    
    % Call stored variables
    handles = guidata(gcbo);
    screen_width = getappdata(hObject.Parent, 'screen_width');
    screen_height = getappdata(hObject.Parent, 'screen_height');
    
    % Transform the image to grayscale and apply a Wiener filter to it
    get_Image = imread([DataSourcePath DataSourceName]);
    img_format = size(get_Image);
    if length(img_format) > 2
        my_Image = rgb2gray(get_Image);
    else
        my_Image = get_Image;
    end
          
    % Set up image display
    set(0,'Showhidden','on')
    image_window = figure(...
        'Name', ['PixelAnalysis - Image: ' DataSourceName ' (8 bit)'], ...
        'NumberTitle', 'off', ...
        'Tag', 'image_window', ...
        'Resize', 'on', ...
        'CloseRequestFcn', '', ...
        'Position',[screen_width*0.075, screen_height*0.046, screen_width*0.55, screen_height*0.9]);
    handles.image_axes = axes();
    axis('image');
    
    % Modify image_window ToolBar
    % Author: Amir, see http://de.mathworks.com/matlabcentral/newsreader/view_thread/259504#916245
    ch = get(image_window, 'children');
    chtags = get(ch, 'Tag');
    ftb_ind = find(strcmp(chtags, 'FigureToolBar'));
    UT = get(ch(ftb_ind), 'children');
    delete(UT((end-4):end)); % deletes new, open, save and print
    delete(UT((1:8))); % deletes everything else except for zoom and pan
    set(image_window, 'MenuBar', 'none');
    set(image_window, 'ToolBar', 'figure');
    
    % Display image
    % InitialMagnification prevents MATLAB from resizing the image
    % automatically
    imshow(my_Image, 'InitialMagnification', 'fit');
    hold on;
    
    % Hand over variables
    img_title = strrep(DataSourceName, '.', '_');
    
    setappdata(hObject.Parent, 'img_title', img_title);
    setappdata(hObject.Parent, 'my_Image', my_Image);
    
    % Enable next step
    handles;
    handlesArray = [handles.rb_across, handles.rb_between];
    set(handlesArray, 'Enable', 'on');
    
    % Refresh handles
    handles.image_window = image_window;
    guidata(gcbo, handles)
end
end % of function


function toggle_measure_Callback(hObject, eventdata)
handles = guidata(gcbo);
measure = get(hObject, 'Value');

handles.text = '';

% Modify profile_window ToolBar when this button is pressed for the very 
% first time
% Author: Amir, see http://de.mathworks.com/matlabcentral/newsreader/view_thread/259504#916245
pixprof_mod = getappdata(handles.ui_window, 'pixprof_mod');
if pixprof_mod == false
    ch = get(handles.profile_window, 'children');
    chtags = get(ch, 'Tag');
    ftb_ind = find(strcmp(chtags, 'FigureToolBar'));
    UT = get(ch(ftb_ind), 'children');
    delete(UT((end-4):end)) % deletes new, open, save and print
    delete(UT((1:6))); % deletes everything else except for zoom and pan
    delete(UT(8)); % deletes everything else except for zoom and pan
    set(handles.profile_window, 'MenuBar', 'none');
    set(handles.profile_window, 'ToolBar', 'figure');
    setappdata(handles.ui_window, 'pixprof_mod', true);
end

while measure == 1
    try
        set(handles.image_window, 'CurrentAxes', handles.image_axes)
        % Create roi-line in the image and wait until user double-clicks on the
        % line
        roi_line = imline(handles.image_axes);
        wait(roi_line);
        
        % Get the start and end position of the line
        pos = getPosition(roi_line);
        x = [pos(1, 1) pos(2, 1)];
        y = [pos(1, 2) pos(2, 2)];
        
        setappdata(handles.ui_window, 'x_vals', x);
        setappdata(handles.ui_window, 'y_vals', y);
        
        % Hand all input over to analyze_pixel
        % Plot the pixel profile in a new window, mark peaks and
        % cellular signals, determine a value for membrane and cellular signals
        [ii, handles] = analyze_pixel();
        
        % Delete the original roi-line
        delete(roi_line)
        
        ii = ii + 1;
        setappdata(hObject.Parent, 'counter', ii);
        
        setappdata(handles.ui_window, 'user_saved', false);
        
        guidata(hObject, handles)
        handlesArray = [handles.hsave, handles.hdiscard, handles.hmanual];
        set(handlesArray, 'Enable', 'on');
        
        set(handles.hmanual_auto, 'Enable', 'off');
        
    % As soon as the user quits the application an error occurs;
    % additionally there is the possibility that an error occurs in
    % analyze_pixel
    catch
        % In case there was an error in analyze pixel, the 'try' segment 
        % will be executed; if the user has closed the application, there
        % will be another error when axes is called thus the 'catch'
        % segment will be executed which results in a smooth exit 
        try
            delete(roi_line)
            axes(handles.image_axes)
            handles.line = plot(x, y, 'Color', [0 0 1], 'Linewidth', 1);
            handles.text = text(x(2), y(2),' E', 'Color', [0 0 1]);
            lasterror
        catch
            break
        end
    end % of try
end % of while
end % of function


function button_discard_Callback(hObject, eventdata)
% If the last measurement is discardes, the counter will be decremented
% which results in the data on which the discard was ordered being 
% overwritten when the next measurement is performed. If a save is ordered
% saving will not be performed on the discarded data.
handles = guidata(gcbo);
counter = getappdata(hObject.Parent, 'counter');
setappdata(hObject.Parent, 'counter', counter-1);
setappdata(hObject.Parent, 'measure', 0);

% All traces of the last measurement will be deleted
delete(handles.line)
delete(handles.text)

% Disable this button and reset the Measure togglebutton
set(handles.hdiscard, 'Enable', 'off');
set(handles.hmeasure,'Value',0)

guidata(hObject, handles);
end % of function


function button_save_Callback(hObject, eventdata)
handles = guidata(gcbo);

% Choose save location
user_saved = false;
while user_saved == false
    save_dir = uigetdir('C:\', 'PixelAnalysis - Select Save Location');
    if save_dir == 0
        quest_h = questdlg('Data has not been saved, yet! Really cancel?', 'Cancel? - Curve Fitting', 'No', 'Yes', 'No');
        waitfor(quest_h)
        if strcmp(quest_h, 'Yes') == 1
            return
        end
    else
        user_saved = true;
    end
end

% Initialize a progress bar
waitbar_handle = waitbar(0, 'Saving data...');
steps = length(handles.profiles) + 3;

% Create a new folder for saving the data
img_title = getappdata(hObject.Parent, 'img_title');
my_path = [save_dir '\PixelAnalysis_' img_title '_Results'];
save_dir_exist = exist(my_path, 'dir');
waitbar(1/steps)
if save_dir_exist ~= 7
    mkdir(my_path)
else
    aa = 1;
    while save_dir_exist == 7
        aa = aa + 1;
        my_path = [save_dir '\PixelAnalysis_' img_title '_Results_' num2str(aa)];
        save_dir_exist = exist(my_path, 'dir');
    end
    mkdir(my_path)
end
waitbar(1.5/steps)

% Copy micrograph with ROI-lines to a new figure window, save as tif
img = figure('Visible', 'off');
ax = axes;
clf;
new_handle = copyobj(handles.image_axes, img);
set(gca, 'ActivePositionProperty', 'outerposition')
set(gca, 'Units', 'normalized')
set(gca, 'OuterPosition', [0 0 1 1])
set(gca, 'position', [0.1300 0.1100 0.7750 0.8150])
colormap('gray')
whereToStore_cells = fullfile(my_path,[[img_title '_PixelAnalysis_modOrig'] '.tif']);
print(img, whereToStore_cells, '-dtiffn', '-r300')
waitbar(2/steps)

% Open txt for saving numerical values
whereToStore_txt = fullfile(my_path, [[img_title '_PixelAnalysis_Parameters'], '.txt']);
loc_txt = fopen(whereToStore_txt, 'w');
fprintf(loc_txt, 'Cell Number; Membrane Signal; Cytoplasm Signal; Ratio\r\n');
waitbar(3/steps)

% Save all pixel profiles and numerical values (membrane/cellular signals +
% ratios)
for jj = 1:length(handles.profiles)
    if handles.gaveError(jj) == 0
        
        % Recreate the pixel profile in an invisible figure window, add the
        % number of the cell
        data = handles.profiles{jj, :};
        fig = figure('Visible', 'off');
        ax = axes;
        plot(1:numel(data), data, '-k')
        xlim([1 numel(data)])
        ylim([0 ceil(max(data)+10)])
        xlabel('ROI Length [px]', 'FontSize', 14)
        ylabel('Pixel Intensity', 'FontSize', 14)
        set(gca,'XMinorTick', 'on', 'YMinorTick', 'on')
        set(gca, 'TickLength', [0.01 0.002])
        set(gca, 'TickDir', 'out');
        grid on
        text(numel(data)*0.05, ceil(max(data)+10)*0.925, num2str(handles.profileNumber(jj)), 'FontSize', 16)
        
        % Save profiles as epsc and png at chosen location
        whereToStore_vec = fullfile(my_path,[[img_title '_PixelAnalysis_' num2str(handles.profileNumber(jj))] '.epsc']);
        print(fig, whereToStore_vec, '-depsc', '-tiff', '-painters')
        
        whereToStore_png = fullfile(my_path, [[img_title '_PixelAnalysis_' num2str(handles.profileNumber(jj))], '.png']);
        print(fig, whereToStore_png, '-dpng', '-r300')
        
        % Export numerical values
        membrane_val = handles.membrane(jj);
        cytosol_val = handles.cytosol(jj);
        mc_ratios = handles.ratios(jj);
        data_export_point = [num2str(handles.profileNumber(jj)) '; ' num2str(membrane_val) '; ' num2str(cytosol_val) '; ' num2str(mc_ratios)];
        data_export = strrep(data_export_point, '.', ',');
        fprintf(loc_txt, '%s\r\n', data_export);
        
        if jj == length(handles.profiles)
            fclose(loc_txt);
        end
    end
    waitbar((jj+3)/steps)
end
waitbar(1, waitbar_handle, 'Saving successful!');
pause(1)
close(waitbar_handle)

setappdata(hObject.Parent, 'user_saved', user_saved)
end % of function


function rb_across_Callback(hObject, evendata)
handles = guidata(gcbo);

if get(hObject,'Value') == 1
    setappdata(handles.ui_window, 'measure_type', 'across');
    set(handles.rb_between, 'Value', 0)
end

if get(handles.rb_across, 'Value') == 0 && get(handles.rb_between, 'Value') == 0
    set(handles.hmeasure, 'Enable', 'off');
else
    set(handles.hmeasure, 'Enable', 'on');
end

guidata(handles.ui_window, handles)
end % of function


function rb_between_Callback(hObject, eventdata)
handles = guidata(gcbo);

if get(hObject,'Value') == 1
    setappdata(handles.ui_window, 'measure_type', 'between');
    set(handles.rb_across, 'Value', 0)
end

if get(handles.rb_across, 'Value') == 0 && get(handles.rb_between, 'Value') == 0
    set(handles.hmeasure, 'Enable', 'off');
else
    set(handles.hmeasure, 'Enable', 'on');
end

guidata(handles.ui_window, handles)
end % of function


function button_manual_Callback(hObject, eventdata)
handles = guidata(gcbo);

ii = getappdata(handles.ui_window, 'counter')-1;
pixels = cell2mat(handles.pixel_plot(ii, :));

axes(handles.profile_axes)
x_lim = get(gca, 'XLim');
hold on
if strcmp(getappdata(handles.ui_window, 'measure_type'), 'across') == 1
    my_text = text(x_lim(2)*0.05, 240, 'Select left peak!', 'FontSize', 14);
    [left_peak, y_coord] = ginput(1);
    left_peak = round(left_peak);
    delete(my_text)
    handles.p_left = plot(left_peak, pixels(left_peak), 'sk', 'LineWidth', 1);
    
    my_text = text(x_lim(2)*0.05, 240, 'Select right peak!', 'FontSize', 14);
    [right_peak, y_coord] = ginput(1);
    right_peak = round(right_peak);
    delete(my_text)
    handles.p_right = plot(right_peak, pixels(right_peak), 'sk', 'LineWidth', 1);
    
    my_text = text(x_lim(2)*0.05, 240, 'Select left end of cytoplasm!', 'FontSize', 14);
    [left_cell, y_coord] = ginput(1);
    left_cell = round(left_cell);
    delete(my_text)
    a = plot(left_cell, pixels(left_cell), 'xk');
    
    my_text = text(x_lim(2)*0.05, 240, 'Select right end of cytoplasm!', 'FontSize', 14);
    [right_cell, y_coord] = ginput(1);
    right_cell = round(right_cell);
    delete(my_text)
    b = plot(right_cell, pixels(right_cell), 'xk');
    
    delete(a), delete(b)
    handles.cell_line = plot(left_cell:right_cell, pixels(left_cell:right_cell), '-k', 'LineWidth', 2);
    
    manual_analysis = [left_peak right_peak left_cell right_cell];
else
    my_text = text(x_lim(2)*0.05, 240, 'Select where the cytoplasm of the left cell ends!', 'FontSize', 14);
    [left_cell, y_coord] = ginput(1);
    left_cell = round(left_cell);
    delete(my_text)
    handles.c_left = plot(left_cell, pixels(left_cell), 'sk', 'LineWidth', 1);
    
    my_text = text(x_lim(2)*0.05, 240, 'Select where the cytoplasm of the right cell ends!', 'FontSize', 14);
    [right_cell, y_coord] = ginput(1);
    right_cell = round(right_cell);
    delete(my_text)
    handles.c_right = plot(right_cell, pixels(right_cell), 'sk', 'LineWidth', 1);
    
    handles.between_cells_text = text(x_lim(2)*0.05, 240, 'The membrane is marked in black:', 'FontSize', 14);
    handles.membrane_line = plot(left_cell:right_cell, pixels(left_cell:right_cell), '-k', 'LineWidth', 2);
    
    manual_analysis = [left_cell right_cell];
end

setappdata(handles.ui_window, 'manual_analysis', manual_analysis)

handlesArray = [handles.hmanual_accept, handles.hmanual_reset];
set(handlesArray, 'Enable', 'on');

guidata(handles.ui_window, handles)
end % of function


function button_manualAccept_Callback(hObject, eventdata)
handles = guidata(gcbo);

ii = getappdata(handles.ui_window, 'counter')-1;
setappdata(handles.ui_window, 'counter', ii)

[ii, handles] = analyze_pixel();

setappdata(handles.ui_window, 'counter', ii+1)
setappdata(handles.ui_window, 'manual_analysis', []);

handlesArray = [handles.hmanual_accept, handles.hmanual_reset];
set(handlesArray, 'Enable', 'off');
set(handles.hmanual_auto, 'Enable', 'on');

guidata(handles.ui_window, handles)
end % of function


function button_manualReset_Callback(hObject, eventdata)
handles = guidata(gcbo);

if strcmp(getappdata(handles.ui_window, 'measure_type'), 'across') == 1
    delete(handles.p_left)
    delete(handles.p_right)
    delete(handles.cell_line)
else
    delete(handles.c_left)
    delete(handles.c_right)
    delete(handles.membrane_line)
    delete(handles.between_cells_text)
end

setappdata(handles.ui_window, 'manual_analysis', [])

handlesArray = [handles.hmanual_accept, handles.hmanual_reset];
set(handlesArray, 'Enable', 'off');

guidata(handles.ui_window, handles)
end % of function


function button_manual_backToAuto_Callback(hObject, eventdata)
handles = guidata(gcbo);
setappdata(handles.ui_window, 'manual_analysis', []);

ii = getappdata(handles.ui_window, 'counter')-1;
setappdata(handles.ui_window, 'counter', ii)

[ii, handles] = analyze_pixel();

setappdata(handles.ui_window, 'counter', ii+1)

set(handles.hmanual_auto, 'Enable', 'off');

guidata(handles.ui_window, handles)
end % of function


function button_quit_Callback(hObject, eventdata)
handles = guidata(gcbo);

save_status = getappdata(handles.ui_window, 'user_saved');

h =  findobj('type','figure');
n = length(h);

if save_status == true
    for ii = 1:n
        close force
    end
    %     quit
else
    quest_h = questdlg('Data has not been saved, yet! Really quit?', 'Quit? - Curve Fitting', 'No', 'Yes', 'No');
    waitfor(quest_h)
    if strcmp(quest_h, 'Yes') == 1
        for ii = 1:n
            close force
        end
        %         quit
    end
end

end % of function


function main_menu_license_Callback(hObject, eventdata)
gpl_license_p1 = ...
    {'PixelAnalysis' ...
    'Tool for the collection and evaluation of pixel saturation data in micrographs.' ...
    '' ...
    'Copyright (C) 2016, Sven T. Bitters' ...
    'Contact: sven.bitters@gmail.com' ...
    ''};

gpl_license_p3 = ...
    {'-------------------------------------------------------------------' ...
    ''...
    'fgl_deriv.m' ...
    'Computes the fractional derivative of order alpha (a) for the function y sampled on a regular grid with spacing h, using the Grunwald-Letnikov formulation.' ...
    '' ...
    'Available at http://www.mathworks.com/matlabcentral/fileexchange/45982-fractional-derivative/content/fgl_deriv.m' ...
    '' ...
    'Copyright (C) 2014, Jonathan Hadida' ...
    'Contact: jonathan dot hadida [a] dtc.ox.ac.uk' ...
    'All rights reserved.' ...
    '' ...
    'Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:' ...
    '' ...
    '1. Redistributions of source code must retain the above copyright' ...
    '   notice, this list of conditions and the following disclaimer.' ...
    '2. Redistributions in binary form must reproduce the above copyright' ...
    '   notice, this list of conditions and the following disclaimer in' ...
    '   the documentation and/or other materials provided with the' ...
    '   distribution.' ...
    '' ...
    'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.' ...
    '' ...
    'The views and conclusions contained in the software and documentation are those of the authors and should not be interpreted as representing official policies, either expressed or implied, of the FreeBSD Project.'...
    };

GNU_GPL_License(gpl_license_p1, gpl_license_p3)
end % of function


function main_menu_dlUpdate_Callback(hObject, eventdata)
web('https://github.com/s-bit/PixelAnalysis/releases', '-browser')
end % of function


% NORMAL FUNCTIONS
function [ii, handles] = analyze_pixel()
handles = guidata(gcbo);

measure_type = getappdata(handles.ui_window, 'measure_type');
x = getappdata(handles.ui_window, 'x_vals');
y = getappdata(handles.ui_window, 'y_vals');
manual_analysis = getappdata(handles.ui_window, 'manual_analysis');

axes(handles.profile_axes)
cla
hold on
switch measure_type
    case 'across'
        [membrane_val, cytosol_val, mc_ratio, profile_pixels, interpolated_pixels, gave_error] = AcrossCells(...
            getappdata(handles.ui_window, 'my_Image'), x, y, manual_analysis);
    case 'between'
        [membrane_val, cytosol_val, mc_ratio, profile_pixels, interpolated_pixels, gave_error] = BetweenCells(...
            getappdata(handles.ui_window, 'my_Image'), x, y, manual_analysis);
end

x_lim = get(gca, 'XLim');
ratio_text = text(x_lim(2)*0.7, 270, ['M/C ratio: ' num2str(round(mc_ratio,3))], 'FontSize', 14);

set(handles.profile_window, 'Visible', 'on')

% Receive a numerical value for membrane signal, cellular signal,
% membrane/ccllular ratio, an array containing the original (not
% interpolated) pixel intensities along the roi-line, and a flag
% telling whether an error occured while crunching the data

axes(handles.image_axes)
if gave_error == 0
    % If there was no error while analysing the pixel profile
    % store all obtained values for future use
    ii = getappdata(handles.ui_window, 'counter');
    
    handles.membrane(ii) = membrane_val;
    handles.cytosol(ii) = cytosol_val;
    handles.ratios(ii) = mc_ratio;
    handles.profiles{ii, :} = profile_pixels;
    handles.profileNumber(ii) = ii;
    handles.pixel_plot{ii, :} = interpolated_pixels;
    handles.gaveError(ii) = gave_error;
    
    if isempty(manual_analysis)
        % Replace the roi-line with a nice red line and identify it by a number
        handles.line = plot(x, y, 'Color', [1 0 0], 'Linewidth', 1);
        if x(1) < x(2)
            handles.text = text(x(2), y(2), [' ' num2str(ii)], 'Color', [1 0 0]);
        else
            img_size = size(getappdata(handles.ui_window, 'my_Image'));
            handles.text = text(x(2)-(img_size(1)*0.02), y(2), num2str(ii), 'Color', [1 0 0]);
        end
    end
else
    if isempty(manual_analysis)
        % If there was an error, replace the roi-line with a blue line
        handles.line = plot(x, y, 'Color', [0 0 1], 'Linewidth', 1);
        handles.text = text(x(2), y(2),' E', 'Color', [0 0 1]);
        ii = ii - 1;
    end
end

end % of function
