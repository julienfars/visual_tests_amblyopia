%% Function to set up screen parameters
function [window, windowRect, width, height] = setupScreen(stereo, debug)
    % Check platform for sync tests
    if ismac || isunix
        Screen('Preference', 'SkipSyncTests', 0);
    elseif ispc
        oldSyncLevel = Screen('Preference', 'SkipSyncTests', 1);
    else
        disp('Platform not supported')
        return
    end

    % Here we call some default settings for setting up Psychtoolbox
    PsychDefaultSetup(2);

    % Get the screen numbers
    screens = Screen('Screens');
    screenNumber = max(screens); % set the experiment on the last screen (will not change anything if you only have one screen)

    % Define black and white
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);

    % Do a simple calculation to calculate the luminance value for grey.
    % This will be half the luminance value for white
    grey = white / 2;

    if ~isempty(stereo) && ~debug
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], [], [], stereo);
    elseif ~isempty(stereo) && debug
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        % Open a small PsychImaging window in the corner for debugging
        [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 400 400], [], [], stereo);
    elseif isempty(stereo) && ~debug
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], [], []);
    elseif isempty(stereo) && debug
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 400 400], [], []);
    end

    % Instead of returning width and height of the graphics window/screen in pixels
    % using this [width, height] = Screen('WindowSize', window); 
    % we do 
    width = windowRect(3);
    height = windowRect(4);
end
