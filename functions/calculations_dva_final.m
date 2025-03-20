function E_min_size_dva = calculations_dva_final(windowRect, DISTANCE, screen_size, object_size_pixels)
    % Calculate the minimum object size in degrees of visual angle (dva)

    % Get the number of pixels per mm
    DIM_Screen_hor = windowRect(3) / screen_size(2);
    pix_size = 1 / DIM_Screen_hor;

    % Calculate the minimum object size in pixels
    E_min_size = object_size_pixels * pix_size;

    % Calculate the size in degrees of visual angle (dva)
    E_min_size_dva = 2 * atand((E_min_size / 2) / DISTANCE);
end



%{
% Example 1 (Personal Laptop)
windowRect1 = [0 0 1920 1080];
DISTANCE1 = 127.5;
screen_size_cm1 = 51.86;
object_size_pixels1 = 1080;
E_min_size_dva1 = calculations_dva_final(windowRect1, DISTANCE1, screen_size_cm1, object_size_pixels1);

% Example 2 (Experimental Setup)
windowRect2 = [0 0 1920 1080];
DISTANCE2 = 1500;
screen_size = [700, 392]; % Screen size in mm (width, height)
object_size_pixels2 = 552;
E_min_size_dva2 = calculations_dva_final(windowRect2, DISTANCE2, screen_size, object_size_pixels2);

% Example 3 (VR device)
windowRect3 = [0 0 1832 1920];
DISTANCE3 = 2;
screen_size_cm3 = 4.5;
object_size_pixels3 = 1651;
E_min_size_dva3 = calculations_dva_final(windowRect3, DISTANCE3, screen_size_cm3, object_size_pixels3);
%}