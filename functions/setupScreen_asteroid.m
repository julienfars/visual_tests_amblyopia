function [window, windowRect, expt, blueRectLeftOn, blueRectLeftOff, ...
    blueRectRightOn, blueRectRightOff, width, height, white, ...
    black, screenNumber, stereoMode, SIZE_X, SIZE_Y]  = setupScreen_asteroid(fixCross, expt)
    % This function initializes the experiment parameters and creates the
    % Psychtoolbox window.

    AssertOpenGL % NLP 6/7/2016
    PsychDefaultSetup(2);
    scrnNum = max(Screen('Screens'));
    rand('twister', sum(100 * clock));

    white = WhiteIndex(scrnNum);
    black = BlackIndex(scrnNum);
    
    if ismac || ispc % Skip sync tests for Mac and PC (for testing purposes)
        oldSyncLevel = Screen('Preference', 'SkipSyncTests', 1);
    elseif isunix
        Screen('Preference', 'SkipSyncTests', 0);
    else
        disp('Platform not supported')
        return
    end
    
    screens = Screen('Screens');
    screenNumber = max(screens);

    if fixCross
        stereoMode = 100; % 100; %will fix later, need to do diagnostics first 
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
        [window, windowRect] = PsychImaging('OpenWindow', 0, expt.bgcol, [], [], 2, [], expt.multisample, stereoMode);
    else
        stereoMode = [];
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        [window, windowRect] = PsychImaging('OpenWindow', 0, expt.bgcol, [], [], 2, [], expt.multisample, 0);
    end

    blueRectLeftOn = [0, windowRect(4) - 1, windowRect(3) / 4, windowRect(4)];
    blueRectLeftOff = [windowRect(3) / 4, windowRect(4) - 1, windowRect(3), windowRect(4)];
    blueRectRightOn = [0, windowRect(4) - 1, windowRect(3) * 3 / 4, windowRect(4)];
    blueRectRightOff = [windowRect(3) * 3 / 4, windowRect(4) - 1, windowRect(3), windowRect(4)];

    % Screen('FillRect', window, 0.5);
    Screen('Flip', window);
    % 6/7/2016
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Work out timing
    ifi = Screen('GetFlipInterval', window);
    expt.framespersec = round(1 / ifi); % framerate HZ

    SIZE_X = expt.nx; % expt.sizeimageX;
    SIZE_Y = expt.ny; % expt.sizeimageY;

    % Instead of returning width and height of the graphics window/screen in pixels
    % using this [width, height] = Screen('WindowSize', window);
    % we do
    width = windowRect(3);
    height = windowRect(4);
end