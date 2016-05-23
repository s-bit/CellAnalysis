% YeastAnalysis
% Function for the collection and evaluation of pixel saturation data in yeast micrographs.
% Copyright (C) 2016, Sven T. Bitters
% Contact: sven.bitters@gmail.com
%
% This file is part of CellAnalysis.
%
% YeastAnalysis is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% YeastAnalysis is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with YeastAnalysis.  If not, see http://www.gnu.org/licenses/.


function [membrane, cytosol, mem2cyto, get_pixels, data_error] = analyse_yeast(my_Image, my_Adjust, x, y)

% Originally, there is no problem
cell_problem = false;
data_error = 0;

% Create a pixel profile on the line between the coordinates stored in x
% and y on my_Image
% Interpolate the image to a resolution ot 1/5 px using spline
% Plot the pixel profile to the smaller window
get_pixels = improfile(my_Image, x, y);
pixel_data = interp1(1:numel(get_pixels), get_pixels, 1:0.2:numel(get_pixels), 'spline');
plot(1:numel(pixel_data), pixel_data, '-b');
hold on;

% Get the pixel profile and interpolate the sharpened and brightness/contrast adjusted picture as
% well
get_adjust = improfile(my_Adjust, x, y);
pixel_adjust = interp1(1:numel(get_adjust), get_pixels, 1:0.2:numel(get_adjust), 'spline');

% Compute fractional derivative of order 0.8 then integrate... in a weird
% way - but it gives data!
yd    = zeros(2, length(1:numel(pixel_adjust)) );
yd(1,:) = fgl_deriv(0.8, pixel_adjust, 0.01 );
working_pixel = trapz(yd);

% figure(100)
% findpeaks(yi(1,:), 1);
% figure(25)


% Calculate the derivative of the adjusted image, then apply a median
% filter to the values, and eventually make all values below 0.2 equal to 0
% diff_pixel = diff(pixel_adjust);
% filtered_pixel = smooth(medfilt1(diff_pixel, 15));
% filtered_pixel(abs(filtered_pixel) < 0.2) = 0;

% Find Peaks
[pval, pindex] = findpeaks(medfilt1(working_pixel, 2), 1);
[pval1, pindex1] = findpeaks(working_pixel, 1, 'MinPeakHeight', mean(pval));
[pval2, pindex2] = findpeaks(-working_pixel, 1, 'MinPeakHeight', mean(pval));

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
    %     findpeaks(medfilt1(working_pixel, 2), 1)
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
    
    %     length_cell = right_peak_index - left_peak_index;
    %     zero_dist = round(length_cell*0.0625);
    %
    %     ii = left_peak_index;
    %     found_cyto = false;
    %     while found_cyto == false
    %         if working_pixel(ii:ii+zero_dist) == 0
    %             left_cellular = ii;
    %             found_cyto = true;
    %         end
    %         ii = ii + 1;
    %     end
    %
    %     ii = right_peak_index;
    %     found_cyto = false;
    %     while found_cyto == false
    %         if working_pixel(ii-zero_dist:ii) == 0
    %             right_cellular = ii;
    %             found_cyto = true;
    %         end
    %         ii = ii - 1;
    %     end
    %
    plot(left_cellular:right_cellular, pixel_data(left_cellular:right_cellular), '-r', 'LineWidth', 1)
    
    membrane = mean([pixel_data(left_peak_index) pixel_data(right_peak_index)]);
    cytosol = mean(pixel_data(left_cellular:right_cellular));
else
    cell_problem = true;
end

if cell_problem == false
    % Check plausibility
    for ii = left_peak_index:right_peak_index
        if pixel_data(ii) > max(peak_vals)
            cell_problem = true;
        end
    end
end

if cell_problem == true
    text(numel(pixel_data)/2, max(pixel_data)/2, 'ERROR', 'Color', 'red', 'FontSize', 24)
    data_error = 1;
    mem2cyto = 0;
else
    mem2cyto = membrane/cytosol;
end

xlabel('ROI Length [px]', 'FontSize', 14)
ylabel('Pixel Intensity', 'FontSize', 14)
ylim([0 260])
xlim([1 numel(pixel_data)])
set(gca, 'YTick', 0:25:260)
grid on

hold off;
end % of function


% findpeaks((pixel_data, 'moving'), 1, 'MinPeakHeight', background)
% % Find end of left peak
% ii = left_peak_index;
% found_inside = false;
% while found_inside == false
%     if abs(pixel_data(ii)-pixel_data(ii+1)) <= 0.25;
%         left_cellular = ii
%         found_inside = true;
%     end
%     ii = ii + 1;
% end
%
% % Find end of right peak
% ii = right_peak_index;
% found_inside = false;
% while found_inside == false
%     if abs(pixel_data(ii)-pixel_data(ii-1)) <= 0.25;
%         right_cellular = ii
%         found_inside = true;
%     end
%     ii = ii - 1;
% end


% figure(2)
% subplot(3,2,1)
% plot(1:numel(pixel_data), pixel_data, 'xk')
%
% subplot(3,2,2)
% plot(1:numel(pixel_data), (pixel_data), 'k')
%
% subplot(3,2,3)
% inter_pixel = interp1(1:numel(pixel_data), pixel_data, 1:0.25:numel(pixel_data))
% plot(1:numel(inter_pixel), inter_pixel, 'xb')
%
% subplot(3,2,4)
% plot(1:numel(inter_pixel), (inter_pixel), 'b')
%
% subplot(3,2,5)
% inter_pixel = interp1(1:numel(pixel_data), pixel_data, 1:0.25:numel(pixel_data), 'spline')
% plot(1:numel(inter_pixel), inter_pixel, 'xr')
%
% subplot(3,2,6)
% plot(1:numel(inter_pixel), (inter_pixel), 'r')
