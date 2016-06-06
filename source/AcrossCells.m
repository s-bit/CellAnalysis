% AcrossCells
% Function for the evaluation of pixel intensity data across cells in micrographs.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%
% This file is part of PixelAnalysis.
%
% AcrossCells is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% AcrossCells is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with AcrossCells.  If not, see http://www.gnu.org/licenses/.


function [membrane, cytosol, mem2cyto, get_pixels, pixel_data, data_error] = AcrossCells(my_Image, x, y, manual_analysis)
% Originally, there is no problem
data_error = 0;

% Initialize my_Adjust, then adjust contrast and brightness, then sharpen -
% do thrice
my_Adjust = my_Image;
for ii = 1:3
    my_Adjust = imsharpen(imadjust(my_Adjust, stretchlim(my_Adjust, [0.6 0.995]), []));
end

% Create a pixel profile on the line between the coordinates stored in x
% and y on my_Image
% Interpolate the image to a resolution ot 1/5 px using spline
% Plot the pixel profile to the smaller window
get_pixels = improfile(my_Image, x, y);
pixel_data = interp1(1:numel(get_pixels), get_pixels, 1:0.2:numel(get_pixels), 'spline');
plot(1:numel(pixel_data), pixel_data, '-b');
hold on;

try
    if isempty(manual_analysis)
        % Get the pixel profile and interpolate the sharpened and brightness/contrast adjusted picture as
        % well
        get_adjust = improfile(my_Adjust, x, y);
        pixel_adjust = interp1(1:numel(get_adjust), get_pixels, 1:0.2:numel(get_adjust), 'spline');
        
        % Compute fractional derivative of order 0.8 then integrate... in a weird
        % way - but it works!
        yd    = zeros(2, length(1:numel(pixel_adjust)) );
        yd(1,:) = fgl_deriv(0.8, pixel_adjust, 0.01 );
        working_pixel = trapz(yd);
        
        % Find Peaks
        [pval, pindex] = findpeaks(medfilt1(working_pixel, 2), 1);
        background = mean(pval);

        [pval1, pindex1] = findpeaks(working_pixel, 1, 'MinPeakHeight', background);
        [pval2, pindex2] = findpeaks(-working_pixel, 1, 'MinPeakHeight', background);
        
        [peak_val, peak_index] = findpeaks(pixel_adjust, 1, 'MinPeakHeight', mean(pixel_adjust), 'SortStr', 'descend', 'MinPeakProminence', 1);
        
        if length(peak_index) >= 2
            peak_start = min(pindex1);
            peak_end = numel(pixel_adjust);
            peak_steps = [];
            for ii = 1:length(peak_index)
                steps = 0;
                for find_peak = peak_start:peak_end
                    if find_peak == peak_index(ii)
                        peak_steps(ii, :) = steps;
                    end
                    steps = steps+1;
                end
            end
            for jj = 1:length(peak_index)
                if peak_steps(jj) == min(peak_steps)
                    left_peak_index = peak_index(jj)+1;
                end
            end
            
            peak_steps = [];
            for ii = 1:length(peak_index)
                steps = 0;
                for find_peak = peak_index(ii):peak_end
                    if find_peak == max(pindex2)
                        peak_steps(ii, :) = steps;
                    end
                    steps = steps+1;
                end
            end
            for jj = 1:length(peak_index)
                if peak_steps(jj) == min(peak_steps)
                    right_peak_index = peak_index(jj)+1;
                end
            end
            
            peak_vals = [pixel_data(left_peak_index) pixel_data(right_peak_index)];
            plot(left_peak_index, peak_vals(1), 'or')
            plot(right_peak_index, peak_vals(2), 'or')
            
            % "Guess" the cellular signal
            left_inside = false;
            ii = 1;
            while left_inside == false
                if pindex(ii) > left_peak_index
                    if pval(ii) < max(pval)*0.75
                        left_cellular = pindex(ii);
                        left_inside = true;
                    end
                end
                ii = ii + 1;
            end
            
            [pval, pindex] = findpeaks(medfilt1(-working_pixel, 2), 1);
            right_inside = false;
            ii = length(pindex);
            while right_inside == false
                if pindex(ii) < right_peak_index
                    if pval(ii) < max(pval)*0.75
                        right_cellular = pindex(ii);
                        right_inside = true;
                    end
                end
                ii = ii - 1;
            end
                         
        else % If less than 2 peaks were found
            text(numel(pixel_data)*0.05, 130, 'ERROR: Found only 1 peak!', 'Color', 'red', 'FontSize', 24)
            text(numel(pixel_data)*0.05, 100, 'Analysis was not saved.', 'Color', 'red', 'FontSize', 12)
            text(numel(pixel_data)*0.05, 80, 'Continue by clicking on "Analyze Cells".', 'Color', 'red', 'FontSize', 12)
            data_error = 1;
            mem2cyto = 0;
        end
        
    else % Executes when everything is manually selected
        left_peak_index = manual_analysis(1);
        right_peak_index = manual_analysis(2);
        left_cellular = manual_analysis(3);
        right_cellular = manual_analysis(4);
        
        plot(left_peak_index, pixel_data(left_peak_index), 'or')
        plot(right_peak_index, pixel_data(right_peak_index), 'or')
    end % of manual mode
    
    % Executes in any case
    plot(left_cellular:right_cellular, pixel_data(left_cellular:right_cellular), '-r', 'LineWidth', 1)

    membrane = mean([pixel_data(left_peak_index) pixel_data(right_peak_index)]);
    cytosol = mean(pixel_data(left_cellular:right_cellular));
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
set(gca, 'TickDir', 'out');
set(gca, 'YTick', 0:25:260)
grid on

hold off;
end % of function