%% Function to set up basic Gabor parameters
function [gaborDimPix, PixelPerDeg, size_stim_pix, FREQS] = setupBasicGaborParameters(windowRect, screen_size, distance, stim_size, FREQS_test, current_test)
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

    if contains(current_test, 'interocular_imbalance')
        pix_size = 1/DIM_Screen_hor; % the size of 1 pixel in cm 
        size_stim_pix = round(2*distance*tand(SIZE/2)/pix_size); % size of the stim in pixels, we round it so it is easier to display
        E_min_size_dva = 1;
        size_dva = 2*distance*tand(E_min_size_dva/2)/pix_size; % divide the freq in cpd by size_dva to obtain the size in cpp 
        FREQS = FREQS_test./size_dva; % here we convert cpd (cycles per dva) in cpp (cycles per pixels) 
    else
        FREQS = [];
        size_stim_pix = [];
    end
end
