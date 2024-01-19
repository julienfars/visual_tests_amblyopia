% Function to set up other parameters
function [xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect)
    % Hide cursor
    HideCursor();

    % Set up keyboard for cross-platform compatibility of keynaming
    KbName('UnifyKeyNames');

    % Create and start keyboard queue
    KbQueueCreate;
    KbQueueStart;

    % Define keyboard keys used in the script
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');
    upKey = KbName('UpArrow');
    downKey = KbName('DownArrow');
    escapeKey = KbName('ESCAPE');
    spaceKey = KbName('SPACE');
    skipKey = KbName('a');

    % Find the center of the window
    [xCenter, yCenter] = RectCenter(windowRect);
end