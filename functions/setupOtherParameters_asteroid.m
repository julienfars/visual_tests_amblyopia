function [keycode, LEFT, RIGHT, DOWN, UP, SPACE, exit, top_leftKey, top_rightKey, bottom_leftKey, bottom_rightKey] = setupOtherParameters_asteroid()
    % This function sets up other parameters related to key presses for the asteroid experiment.

    % Keypresses that abort the expt
    ListenChar(2); % This line avoids writing in the code when pressing keys 
    
    keycode = zeros(1, 256);
    KbName('UnifyKeyNames');
    
    LEFT  = KbName('LeftArrow');
    RIGHT = KbName('RightArrow');
    DOWN  = KbName('DownArrow');
    UP    = KbName('UpArrow');
    SPACE = KbName('SPACE');

    exit = KbName('ESCAPE');
    top_leftKey = KbName('UpArrow'); % KbName('a'); % see if we can set up multiple keys on the same variable
    top_rightKey = KbName('k');
    bottom_leftKey = KbName('DownArrow'); %KbName('z'); % see if we can set up multiple keys on the same variable
    bottom_rightKey = KbName('m');
end