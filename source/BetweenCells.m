% BetweenCells
% Function for the evaluation of pixel intensity data between cells in micrographs.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%
% This file is part of PixelAnalysis.
%
% BetweenCells is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% BetweenCells is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with BetweenCells.  If not, see http://www.gnu.org/licenses/.


function [membrane, cytosol, mem2cyto, get_pixels, pixel_data, data_error] = BetweenCells(my_Image, x, y, manual_analysis)
% Originally, there is no problem
data_error = 0;

for ii = 1:6
    my_Adjust = wiener2(my_Image, [15 15]);
end

my_Adjust = imsharpen(imadjust(my_Adjust, stretchlim(my_Adjust, [0.6 0.995]), []));

get_pixels = improfile(my_Image, x, y);
pixel_data = interp1(1:numel(get_pixels), get_pixels, 1:0.2:numel(get_pixels), 'spline');
plot(1:numel(pixel_data), pixel_data, '-b');
hold on;

try
    if isempty(manual_analysis)
        
        % Get the pixel profile and interpolate the sharpened and brightness/contrast adjusted picture as
        % well
        get_adjust = improfile(my_Adjust, x, y);
        pixel_adjust = interp1(1:numel(get_adjust), get_adjust, 1:0.2:numel(get_adjust), 'spline');
        
        
        % Compute fractional derivative of order 0.8 then integrate... in a weird
        % way - but it gives data!
        % working_pixel = pixel_adjust;
        yd    = zeros(2, length(1:numel(pixel_adjust)) );
        yd(1,:) = fgl_deriv(0.01, pixel_adjust, 0.01 );
        working_pixel = trapz(yd);
        background = mean(working_pixel)+max(working_pixel)*0.1;
        working_pixel(abs(working_pixel) < background) = 0;
        working_pixel = smooth(working_pixel);
        
%         plot(1:numel(working_pixel), working_pixel, '-k')
        
        [peak_val, peak_index] = findpeaks(working_pixel, 1, 'MinPeakHeight', background, 'SortStr', 'descend', 'MinPeakProminence', 1);
        
        % Find
        for ii = 1:peak_index(1)
            pos = peak_index(1) - ii;
            if working_pixel(pos) == 0
                if working_pixel((pos-round(numel(pixel_data)*0.005)):pos) == 0
                    peak_left = pos - 1;
                    break
                end
            end
        end
        
        for jj = 1:peak_left
            pos = peak_left - jj;
            if pixel_data(pos) < pixel_data(pos-1) && pixel_data(pos) < pixel_data(pos-2)
                cell_left = pos;
                break
            end
        end
        
        for ii = peak_index(1):numel(working_pixel)
            if working_pixel(ii) == 0
                if working_pixel(ii:(ii+round(numel(pixel_data)*0.005))) == 0
                    peak_right = ii;
                    break
                end
            end
        end
        
        for jj = peak_right: numel(working_pixel)
            pos = jj;
            if pixel_data(jj) < pixel_data(jj+1) && pixel_data(jj) < pixel_data(jj+2)
                cell_right = pos;
                break
            end
        end
        
    else % Executes when everything is manually selected
        cell_left = manual_analysis(1);
        cell_right = manual_analysis(2);
    end % of manual mode
    
    % Executes in any case
    plot(cell_left:cell_right, pixel_data(cell_left:cell_right), '-b', 'LineWidth', 1)
    
    plot(1:cell_left, pixel_data(1:cell_left), '-r', 'LineWidth', 1)
    plot(cell_right:numel(pixel_data), pixel_data(cell_right:numel(pixel_data)), '-r', 'LineWidth', 1)
 
    membrane = mean(pixel_data(cell_left:cell_right));
    cytosol = mean([pixel_data(1:cell_left) pixel_data(cell_right:numel(pixel_data))]);
    mem2cyto = membrane/cytosol;
    
catch
    text(numel(pixel_data)*0.25, 130, 'Unknown ERROR', 'Color', 'red', 'FontSize', 24)
    text(numel(pixel_data)*0.25, 100, 'Analysis was not saved.', 'Color', 'red', 'FontSize', 12)
    text(numel(pixel_data)*0.25, 80, 'Continue by clicking on "Analyze Cells".', 'Color', 'red', 'FontSize', 12)
    data_error = 1;
end    

xlabel('ROI Length [px]', 'FontSize', 14)
ylabel('Pixel Intensity', 'FontSize', 14)
ylim([0 260])
xlim([1 numel(pixel_data)])
set(gca, 'TickLength', [0.01 0.002])
set(gca, 'TickDir','out');
set(gca, 'YTick', 0:25:260)
grid on

hold off;
end % of function

%
% get_pixels = improfile(my_Image, x, y);
% pixel_data = interp1(1:numel(get_pixels), get_pixels, 1:0.2:numel(get_pixels), 'spline');
% plot(1:numel(pixel_data), pixel_data, '-b');
% hold on;