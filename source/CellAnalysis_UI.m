% CellAnalysis
% Tool for the collection and evaluation of pixel saturation data in micrographs.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%
% This file is part of CellAnalysis.
%
% CellAnalysis_UI is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% CellAnalysis_UI is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with CellAnalysis_UI. If not, see http://www.gnu.org/licenses/.


function varargout = CellAnalysis_UI(varargin)
% CELLANALYSIS_UI MATLAB code for CellAnalysis_UI.fig
%      CELLANALYSIS_UI, by itself, creates a new CELLANALYSIS_UI or raises the existing
%      singleton*.
%
%      H = CELLANALYSIS_UI returns the handle to a new CELLANALYSIS_UI or the handle to
%      the existing singleton*.
%
%      CELLANALYSIS_UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CELLANALYSIS_UI.M with the given input arguments.
%
%      CELLANALYSIS_UI('Property','Value',...) creates a new CELLANALYSIS_UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CellAnalysis_UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CellAnalysis_UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CellAnalysis_UI

% Last Modified by GUIDE v2.5 23-May-2016 00:36:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CellAnalysis_UI_OpeningFcn, ...
    'gui_OutputFcn',  @CellAnalysis_UI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CellAnalysis_UI is made visible.
function CellAnalysis_UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CellAnalysis_UI (see VARARGIN)

% Choose default command line output for CellAnalysis_UI
handles.output = hObject;

handlesArray = [handles.pushbutton_discardLast, handles.pushbutton_saveData, handles.togglebutton_measure, handles.radiobutton_yeast, handles.radiobutton_plant];
set(handlesArray, 'Enable', 'off');

xlabel('ROI Length [px]', 'FontSize', 14)
ylabel('Pixel Intensity', 'FontSize', 14)
axes(handles.axes_profile);

% CHECK FOR UPDATES
% This program version
ThisVersion = '0.1';

% Get the latest version
[NewVersion,status] = urlread('https://raw.githubusercontent.com/s-bit/CellAnalysis/master/CurrentVersion');

% Check if latest version is newer than this version
if status ~=0 && str2double(ThisVersion)<str2double(NewVersion)
    msg_h = msgbox('A newer version of CellAnalysis is available! How to download:      "About" > "Download Update"', 'Update Notice');
    waitfor(msg_h)
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CellAnalysis_UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CellAnalysis_UI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_loadImage.
function pushbutton_loadImage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.counter = 1;
handles.delete_last = 0;

[DataSourceName, DataSourcePath] = uigetfile({'*.tif'; '*.png'; '*.jpg'}, 'Select File');

% Transform the image to grayscale and apply a Wiener filter to it
get_Image = rgb2gray(imread([DataSourcePath DataSourceName]));
my_Image = wiener2(get_Image, [10 10]);

% Initialize my_Adjust, then adjust contrast and brightness, then sharpen -
% do thrice
my_Adjust = my_Image;
for ii = 1:3
    my_Adjust = imsharpen(imadjust(my_Adjust, stretchlim(my_Adjust, [0.6 0.995]), []));
end

% Display image in the big axes window in the UI
axes(handles.axes_image);
imshow(my_Image);
hold on;

% Hand over these variables' contents
handles.Image = my_Image;
handles.Adjust = my_Adjust;
handles.title = strrep(DataSourceName, '.', '_');

handlesArray = [handles.radiobutton_yeast, handles.radiobutton_plant];
set(handlesArray, 'Enable', 'on');

guidata(hObject, handles);



% --- Executes on button press in pushbutton_discardLast.
function pushbutton_discardLast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_discardLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% When Discard Last Measurement ist pressed, decrease the counter by 1 and
% delete the line and number created most recently
handles.counter = handles.counter - 1;
delete(handles.line)
delete(handles.text)

% Disable this button and reset the Measure togglebutton
handlesArray = [handles.pushbutton_discardLast];
set(handlesArray, 'Enable', 'off');
set(handles.togglebutton_measure,'Value',0)
handles.measure = 0;

guidata(hObject, handles);


% --- Executes on button press in pushbutton_saveData.
function pushbutton_saveData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Choose save location
user_saved = false;
while user_saved == false
    save_dir = uigetdir('C:\', 'CellAnalysis - Select Save Location');
    if save_dir == 0
        quest_h = questdlg('Data has not been saved, yet! Really cancel?', 'Cancel? - Curve Fitting', 'No', 'Yes', 'No');
        waitfor(quest_h)
        if strcmp(quest_h, 'Yes') == 1
            return
        end
    else
        user_saved = true;
        handles.user_saved = user_saved;
        guidata(hObject, handles)
    end
end

waitbar_handle = waitbar(0, 'Saving Data...');
steps = length(handles.profiles) + 3;

my_path = [save_dir '\CellAnalysis_' handles.title '_Results'];
save_dir_exist = exist(my_path, 'dir');
waitbar(1/steps)
if save_dir_exist ~= 7
    mkdir(my_path)
    waitbar(1.5/steps)
end

% Copy micrograph with ROI-lines to a new figure window, save as tif
img = figure('Visible', 'off');
ax = axes;
clf;
new_handle = copyobj(handles.axes_image, img);
set(gca, 'ActivePositionProperty', 'outerposition')
set(gca, 'Units', 'normalized')
set(gca, 'OuterPosition', [0 0 1 1])
set(gca, 'position', [0.1300 0.1100 0.7750 0.8150])
colormap('gray')
whereToStore_cells = fullfile(my_path,[[handles.title '_CellAnalysis_modifiedOriginal'] '.tif']);
print(img, whereToStore_cells, '-dtiffn', '-r300')
waitbar(2/steps)

% Open txt for saving numerical values
whereToStore_txt = fullfile(my_path, [[handles.title '_CellAnalysis_Parameters'], '.txt']);
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
        set(gca,'XMinorTick','on','YMinorTick','on')
        grid on
        text(numel(data)*0.05, ceil(max(data)+10)*0.925, num2str(handles.profileNumber(jj)), 'FontSize', 16)
        
        % Save profiles as epsc and png at chosen location
        whereToStore_vec = fullfile(my_path,[[handles.title '_CellAnalysis_' num2str(handles.profileNumber(jj))] '.epsc']);
        print(fig, whereToStore_vec, '-depsc', '-tiff', '-painters')
        
        whereToStore_png = fullfile(my_path, [[handles.title '_CellAnalysis_' num2str(handles.profileNumber(jj))], '.png']);
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
close(waitbar_handle)

% --- Executes on button press in togglebutton_measure.
function togglebutton_measure_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_measure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton_measure

handles.measure = get(hObject,'Value');
handles.text = '';

while handles.measure == 1
    % Create roi-line in the image and wait until user double-clicks on the
    % line
    roi_line = imline();
    wait(roi_line);
    
    % Get the start and end position of the line
    pos = getPosition(roi_line);
    x = [pos(1, 1) pos(2, 1)];
    y = [pos(1, 2) pos(2, 2)];
    
    % Hand the image, the modified image and the coordinates of the
    % roi-line over to YeastAnalisis.m
    % Plot the pixel profile in the smaller axes window, mark peaks and
    % cellular signals, determine a value for membrane and cellular signals
    axes(handles.axes_profile);
    
    switch handles.celltype
        case 'yeast'
            [membrane_val, cytosol_val, mc_ratio, profile_pixels, gave_error] = YeastAnalysis(handles.Image, handles.Adjust, x, y);
        case 'plant'
            break
    end
    % Receive a numerical value for membrane signal, cellular signal,
    % membrane/ccllular ratio, an array containing the original (not
    % interpolated) pixel intensities along the roi-line, and a flag
    % telling whether an error occured while crunching the data
    
    axes(handles.axes_image);
    if gave_error == 0
        % If there was no error while analysing the pixel profile
        % store all obtained values for future use
        ii = handles.counter;
        handles.membrane(ii) = membrane_val;
        handles.cytosol(ii) = cytosol_val;
        handles.ratios(ii) = mc_ratio;
        handles.profiles{ii, :} = profile_pixels;
        handles.profileNumber(ii) = ii;
        handles.gaveError(ii) = gave_error;
        
        % Replace the roi-line with a nice red line and identify it by a number
        handles.line = plot(x, y, 'Color', [1 0 0], 'Linewidth', 1);
        handles.text = text(x(2), y(2), [' ' num2str(ii)], 'Color', [1 0 0]);
    else
        % If there was an error, replace the roi-line with a blue line
        handles.line = plot(x, y, 'Color', [0 0 1], 'Linewidth', 1);
        handles.text = text(x(2), y(2),' E', 'Color', [0 0 1]);
        ii = ii - 1;
    end
    % Delete the original roi-line
    delete(roi_line)
    
    ii = ii + 1;
    handles.counter = ii;
    guidata(hObject, handles)
    handlesArray = [handles.pushbutton_saveData, handles.pushbutton_discardLast];
    set(handlesArray, 'Enable', 'on');
    
end


% --- Executes on button press in radiobutton_plant.
function radiobutton_plant_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_plant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_plant
if get(hObject,'Value') == 1
    handles.celltype = 'plant';
    set(handles.radiobutton_yeast, 'Value', 0)
end

handlesArray = [handles.togglebutton_measure];
if get(handles.radiobutton_yeast, 'Value') == 0 && get(handles.radiobutton_plant, 'Value') == 0
    set(handlesArray, 'Enable', 'off');
else
    set(handlesArray, 'Enable', 'on');
end
guidata(hObject, handles)


% --- Executes on button press in radiobutton_yeast.
function radiobutton_yeast_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_yeast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_yeast
if get(hObject,'Value') == 1
    handles.celltype = 'yeast';
    set(handles.radiobutton_plant, 'Value', 0)
end

handlesArray = [handles.togglebutton_measure];
if get(handles.radiobutton_yeast, 'Value') == 0 && get(handles.radiobutton_plant, 'Value') == 0
    set(handlesArray, 'Enable', 'off');
else
    set(handlesArray, 'Enable', 'on');
end
guidata(hObject, handles)


% --------------------------------------------------------------------
function Menu_About_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Menu_About_License_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_About_License (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%# GUI with multi-line editbox

gpl_license_p1 = ...
    {'CellAnalysis' ...
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


% --------------------------------------------------------------------
function Menu_About_Update_Callback(hObject, eventdata, handles)
% hObject    handle to Menu_About_Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/s-bit/CellAnalysis', '-browser')
