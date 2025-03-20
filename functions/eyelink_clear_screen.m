function eyelink_clear_screen(var_eye_link,el)
%EYELINK_CLEAR_SCREEN Summary of this function goes here
%   Detailed explanation goes here
%% EYE LINK - Clear screen before start
if contains(var_eye_link, 'true')
Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);
end

end

