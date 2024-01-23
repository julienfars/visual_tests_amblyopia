function [el] = eyelink_calibration(var_eye_link, window, stereoMode, CurrTest, width, height)
    % EYELINK_CALIBRATION - Perform EyeLink calibration
    %   var_eye_link: Flag indicating whether to use EyeLink ('true' or 'false')
    %   window: Psychtoolbox window handle
    %   stereoMode: Stereo mode (if applicable)
    %   CurrTest: Current test identifier
    %   width: Width of the screen
    %   height: Height of the screen

    %% EYE LINK - Calibration
    if contains(var_eye_link, 'true')
        % CALIBRATION SCREEN COLOURS/SOUNDS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE

        % Provide EyeLink with some defaults, returned in the structure "el".
        el = EyelinkInitDefaults(window);

        % Set calibration/validation/drift-check size as well as background and target colors.
        el.calibrationtargetsize = 3; % Outer target size as percentage of the screen
        el.calibrationtargetwidth = 0.7; % Inner target size as percentage of the screen
        el.backgroundcolour = [0.5 0.5 0.5]; % RGB grey
        el.calibrationtargetcolour = [0 0 0]; % RGB black

        % Set "Camera Setup" instructions text color so it is different from the background color
        el.msgfontcolour = [0 0 0]; % RGB black

        % Use an image file instead of the default calibration bull's eye targets.
        el.calTargetType = 'image';

        % Set the calibration image target filename based on stereoMode and CurrTest
        el.calImageTargetFilename = getCalibrationImageFilename(stereoMode, CurrTest);

        % Set calibration beeps (0 = sound off, 1 = sound on)
        el.targetbeep = 1; % Sound a beep when a target is presented
        el.feedbackbeep = 1; % Sound a beep after calibration or drift check/correction

        % You must call this function to apply the changes made to the el structure above
        EyelinkUpdateDefaults(el);

        % Set display coordinates for EyeLink data
        Eyelink('Command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width - 1, height - 1);

        % Write DISPLAY_COORDS message to EDF file
        Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width - 1, height - 1);

        % Set number of calibration/validation dots and spread
        Eyelink('Command', 'calibration_type = HV9'); % Horizontal-vertical 9-points

        % Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
        Eyelink('Command', 'button_function 5 "accept_target_fixation"');
    else
        el = [];
    end
end

function filename = getCalibrationImageFilename(stereoMode, CurrTest)
    % GETCALIBRATIONIMAGEFILENAME - Get the calibration image filename based on stereoMode and CurrTest
    %   stereoMode: Stereo mode
    %   CurrTest: Current test identifier
    if isempty(stereoMode)
        filename = getFilename(CurrTest, 'fixTarget');
    elseif stereoMode == 100
        filename = getFilename(CurrTest, 'fixTarget_100');
    elseif stereoMode == 101
        filename = getFilename(CurrTest, 'fixTarget_101');
    else
        filename = '';
    end
end

function filename = getFilename(CurrTest, baseName)
    % GETFILENAME - Get the full filename based on CurrTest and a base name
    %   CurrTest: Current test identifier
    %   baseName: Base name of the file
    filepath=fileparts(which('eyelink_calibration.m'));

    if exist(CurrTest, 'var')
        filename = [filepath '/' 'targets' '/' baseName 'BW.jpg'];
    else
        filename = [filepath '/' 'targets' '/' baseName '.jpg'];
    end
end


