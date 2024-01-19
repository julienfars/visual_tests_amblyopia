%% Function to set up basic Gabor parameters
function [gaborDimPix, PixelPerDeg] = setupBasicGaborParameters(windowRect, screen_size, distance, stim_size)
    % Calculate pixels per mm for the screen's width and height
    DIM_Screen_hor = windowRect(3) / screen_size(1);
    DIM_Screen_ver = windowRect(4) / screen_size(2);

    % Convert the size of stim from dva to mm
    SIZE_mm = 2 * distance * tand(stim_size / 2);

    % Convert mm to pixels using the number of pixels per mm
    gaborDimPix1 = DIM_Screen_ver * SIZE_mm;
    gaborDimPix2 = DIM_Screen_hor * SIZE_mm;

    % Determine the Gabor dimension in pixels
    gaborDimPix = ceil(max([gaborDimPix1, gaborDimPix2]));

    % Calculate horizontal size in pixels per degree
    PixelPerDeg = gaborDimPix / stim_size;
end
