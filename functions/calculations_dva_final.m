    
    windowRect = [0 0 1920 1080];
    % to put pixels in dva
    DISTANCE = 127.5; %asteroid program distance
    DIM_Screen_vert = windowRect(4)/51.86; % we get the number of pixels per cm using their screen size
    pix_size = 1/DIM_Screen_vert; % the size of 1 pixel in cm (for their screen)

    E_min_size = 830*pix_size; % size of the object in pixels (single dot)
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE); % calculation of dva


    %to put dva in cm 
    DISTANCE = 150; % our distance
    DIM_Screen_hor = windowRect(4)/(global_param.screen_size(2)/10); % we get the number of pixels per cm
    pix_size = 1/DIM_Screen_hor; % the size of 1 pixel in cm 
   % E_min_size_dva = 2;
   % E_min_size_pix = 2*DISTANCE*tand(E_min_size_dva/2)/pix_size;

    E_min_size = 1*pix_size; % size of the object in pixels (single dot)
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE); % calculation of dva


%0.0125 dva in 1 pix 
% 0.0048 cpp 
% 0.0048/0.0125 = 0.3840 cpd --> in 1 dva 
% 

    remained_screen_size_x = 1920 -722 -722;
    remained_screen_size_y = 1080 - 575 - 575; % this is a problem - need 
    % to reduce the size here! (and therefore, of the target as well)


    %4.6422 dva for liu et al. dichoptic noise


    windowRect = [0 0 1920 1080];
    % to put pixels in dva
    DISTANCE = 150; %asteroid program distance
    DIM_Screen_vert = windowRect(4)/39.2; % we get the number of pixels per cm using their screen size
    pix_size = 1/DIM_Screen_vert; % the size of 1 pixel in cm (for their screen)

    E_min_size = 116*pix_size; % size of the object in pixels (single dot)
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE); % calculation of dva



%% VR device 

    windowRect = [0 0 1832 1920];
    % to put pixels in dva
    DISTANCE = 2; %asteroid program distance
    DIM_Screen_hor = windowRect(3)/4.5; % we get the number of pixels per cm using their screen size
    pix_size = 1/DIM_Screen_hor; % the size of 1 pixel in cm (for their screen)

    E_min_size = 1651*pix_size; % size of the object in pixels (single dot) (the scale of the object is 1!!!)
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE); % calculation of dva

    E_min_size = 63*pix_size; % size of the object in pixels (single dot) (the scale of the object is 1!!!)
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE); % calculation of dva

