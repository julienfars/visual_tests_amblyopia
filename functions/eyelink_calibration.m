function [el] = eyelink_calibration(var_eye_link,window, stereoMode, CurrTest, width, height)
%EYELINK_CALIBRATION Summary of this function goes here
%   Detailed explanation goes here


%% EYE LINK - Calibration
if contains(var_eye_link, 'true')
%CALIBRATION SCREEN COLOURS/SOUNDS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE
    
% Provide EyeLink with some defaults, which are returned in the structure "el".
el = EyelinkInitDefaults(window);
% set calibration/validation/drift-check(or drift-correct) size as well as background and target colors. 
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based 
% pupil size changes (which can cause a drift in the eye movement data)
el.calibrationtargetsize = 3;% Outer target size as percentage of the screen
el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
el.backgroundcolour = [0.5 0.5 0.5];% RGB grey
el.calibrationtargetcolour = [0 0 0];% RGB black
% set "Camera Setup" instructions text colour so it is different from background colour
el.msgfontcolour = [0 0 0];% RGB black
    
% Use an image file instead of the default calibration bull's eye targets. 
% Commenting out the following two lines will use default targets:
el.calTargetType = 'image';

% we have to plan a special option for when we need to change the contrast 

if isempty(stereoMode)
    if exist(CurrTest, 'var')
        el.calImageTargetFilename = ['/home/pfr545_admin/software/scripts/CUTOFF_FREQ_AND_CONTRAST' '/' 'functions' '/' 'fixTargetBW.jpg'];
    else
        el.calImageTargetFilename = ['/home/pfr545_admin/software/scripts/CUTOFF_FREQ_AND_CONTRAST' '/' 'functions' '/' 'fixTarget.jpg'];
    end
elseif stereoMode == 100
    if exist(CurrTest, 'var')
        el.calImageTargetFilename = ['/home/pfr545_admin/software/scripts/CUTOFF_FREQ_AND_CONTRAST' '/' 'functions' '/' 'fixTargetBW_100.jpg'];
    else
        el.calImageTargetFilename = ['/home/pfr545_admin/software/scripts/CUTOFF_FREQ_AND_CONTRAST' '/' 'functions' '/' 'fixTarget_100.jpg'];
    end
elseif stereoMode == 101
    if exist(CurrTest, 'var')
        el.calImageTargetFilename = ['/home/pfr545_admin/software/scripts/CUTOFF_FREQ_AND_CONTRAST' '/' 'functions' '/' 'fixTargetBW_101.jpg'];
    else
        el.calImageTargetFilename = ['/home/pfr545_admin/software/scripts/CUTOFF_FREQ_AND_CONTRAST' '/' 'functions' '/' 'fixTarget_101.jpg'];
    end
end

% Set calibration beeps (0 = sound off, 1 = sound on)
el.targetbeep = 1;  % sound a beep when a target is presented
el.feedbackbeep = 1;  % sound a beep after calibration or drift check/correction

% You must call this function to apply the changes made to the el structure above
EyelinkUpdateDefaults(el);

% Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
% Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
% See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);    
% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV9'); % horizontal-vertical 9-points
% Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
Eyelink('Command', 'button_function 5 "accept_target_fixation"');
else 
    el = [];
end

end

