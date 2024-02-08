function [HC1, HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, ...
    escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, doubleScreen, AMB_EYE, EYE_TEST, ...
    HC1, HC2, FF1w, FF1b, FF2w, FF2b, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, ...
    black, white, ifi, current_test)

% FIX_CROSS Summary 
% This function displays the fix cross. The same kind of step is done
% with the visual training (see Liu et al. 2019). At the moment, the fix cross is only shown
% once. But with a slight modification, we can display it before each
% trial.

 if ~fixCross
    [HC1, HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = deal([],[],[],[],[],[],[],[]);
 else
    % Define black and white
    if ~contains(current_test, 'snellen') || ~contains(current_test, 'snellen_crowded')
        while fixCross
            vbl = Screen('Flip', window);
            waitframes = 1;
            exitFixCross = false;
    
            while ~exitFixCross % If I want to display the cross at every trial -> I just need to set the variable = false at the end of the staircase loop
                % Check the keyboard to see if a button has been pressed
                [keyIsDown, ~, keyCode] = KbCheck;
    
                % Depending on the button press, either move the position of the square
                % or exit the demo
                if keyCode(escapeKey) % if the escape key is used, then the half cross is set, this will be confirmed by the experimenter (the participant notifies when the cross/frame is at the right spot=fusion)
                    exitFixCross = true; % I doubled the while loop just to be sure it goes to the next step - must change later
                    fixCross = false;
                    doubleScreen = true;
                elseif keyCode(leftKey) || keyCode(rightKey) || keyCode(upKey) || keyCode(downKey) % each short press of the key moves the cross+frame of one pixel
                    if keyCode(leftKey)
                        direction = 'left';
                    elseif keyCode(rightKey)
                        direction = 'right';
                    elseif keyCode(upKey)
                        direction = 'up';
                    elseif keyCode(downKey)
                        direction = 'down';
                    end
                    HC1 = moveCross(HC1, direction, pixelsPerPress);
                    FF1w = moveCross(FF1w, direction, pixelsPerPress);
                    FF1b = moveCross(FF1b, direction, pixelsPerPress);
                elseif keyCode(spaceKey) % if the spacekey is pressed, then the cross+frame go back to the center of the display
                    [HC1, HC2, FF1w, FF1b, FF2w, FF2b] = resetCross(AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb);
                end
    
               switch true
                    case contains(EYE_TEST, 'Left')
                        buffer_r = 0;
                        buffer_l = 0;
                    case contains(EYE_TEST, 'Right')
                        buffer_r = 1;
                        buffer_l = 1;
                    case contains(AMB_EYE, 'Left') && contains(EYE_TEST, 'Both')
                        buffer_r = 1;
                        buffer_l = 0;
                    case contains(AMB_EYE, 'Right') && contains(EYE_TEST, 'Both')
                        buffer_r = 0;
                        buffer_l = 1;
                    otherwise
                        disp('Other combination of x and y');
                end
                drawHalfCross(window, black, white, HC1, FF1w, FF1b, buffer_l);
                drawHalfCross(window, black, white, HC2, FF2w, FF2b, buffer_r);
                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
                % here we calculate the difference between the position of the half
                % cross and the center of the screen, this value will be used when
                % displaying the Stimuli
                if contains(AMB_EYE, 'Left') 
                    diff(:, 1) = HC1(:, 1) - HCl(:, 1);
                else
                    diff(:, 1) = HC1(:, 1) - HCr(:, 1);
                end
            end
    
            % this part is "washing up" the screen, it removes the crosses from the
            % display but leaves the frame
            switch true
                case contains(EYE_TEST, 'Left')
                    buffer_r = 0;
                    buffer_l = 0;
                case contains(EYE_TEST, 'Right')
                    buffer_r = 1;
                    buffer_l = 1;
                case contains(AMB_EYE, 'Left') && contains(EYE_TEST, 'Both')
                    buffer_r = 1;
                    buffer_l = 0;
                case contains(AMB_EYE, 'Right') && contains(EYE_TEST, 'Both')
                    buffer_r = 0;
                    buffer_l = 1;
                otherwise
                    disp('Other combination of x and y');
            end
                washUpScreen(window, black, white, HC1, FF1w, FF1b, buffer_l) 
                washUpScreen(window, black, white, HC2, FF2w, FF2b, buffer_r)
           
            Screen('Flip', window);
            WaitSecs(1);
       end
    else
        while fixCross
            vbl = Screen('Flip', window);
            waitframes = 1;
            exitFixCross = false;
    
            while ~exitFixCross
                % Check the keyboard to see if a button has been pressed
                [keyIsDown, ~, keyCode] = KbCheck;
    
                % Depending on the button press, either move the position of the square
                % or exit the demo
                if keyCode(escapeKey) % if the escape key is used, then the half cross is set, this will be confirmed by the experimenter (the participant notifies when the cross/frame is at the right spot=fusion)
                    exitFixCross = true; % I doubled the while loop just to be sure it goes to the next step - must change later
                    fixCross = false;
                    doubleScreen = true;
                elseif keyCode(leftKey) || keyCode(rightKey) || keyCode(upKey) || keyCode(downKey) % each short press of the key moves the cross+frame of one pixel
                    if keyCode(leftKey)
                        direction = 'left';
                    elseif keyCode(rightKey)
                        direction = 'right';
                    elseif keyCode(upKey)
                        direction = 'up';
                    elseif keyCode(downKey)
                        direction = 'down';
                    end
                    HC1 = moveCross(HC1, direction, pixelsPerPress);
                elseif keyCode(spaceKey) % if the spacekey is pressed, then the cross+frame go back to the center of the display
                    [HC1, HC2, FF1w, FF1b, FF2w, FF2b] = resetCross(AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb);
                end
    
                % Draw the half crosses to the screen
                if contains(AMB_EYE, 'Left')
                drawHalfCross(window, black, white, HC1, [], [], 0);
                drawHalfCross(window, black, white, HC2, [], [], 1);
                Screen('Flip', window);
                else
                drawHalfCross(window, black, white, HC2, [], [], 1);
                drawHalfCross(window, black, white, HC1, [], [], 0);
                Screen('Flip', window);
                end
    
                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
                if contains(AMB_EYE, 'Left')
                    diff(:, 1) = HC1(:, 1) - HCl(:, 1);
                else
                    diff(:, 1) = HC1(:, 1) - HCr(:, 1);
                end
            end
    
            % this part is "washing up" the screen, it removes the crosses from the
            % display but leaves the frame
            washUpScreen(window, HC1);
            washUpScreen(window, HC2);
        end
    end
    
  end
end
    
function cross = moveCross(cross, direction, pixelsPerPress)
    % Moves the cross based on the key press
    
    if contains(direction,'left') % Left arrow key
        cross(1, :) = cross(1, :) - pixelsPerPress;
        cross(3, :) = cross(3, :) - pixelsPerPress;
    elseif contains(direction,'right') % Right arrow key
        cross(1, :) = cross(1, :) + pixelsPerPress;
        cross(3, :) = cross(3, :) + pixelsPerPress;
    elseif contains(direction,'up') % Up arrow key
        cross(2, :) = cross(2, :) - pixelsPerPress;
        cross(4, :) = cross(4, :) - pixelsPerPress;
    elseif contains(direction,'down') % Down arrow key
        cross(2, :) = cross(2, :) + pixelsPerPress;
        cross(4, :) = cross(4, :) + pixelsPerPress;
    end
    
    end
    
    function drawHalfCross(window, black, white, HC, FFa, FFb, EYE)
        % Draws the half cross to the screen
        if ~nargin < 7
        Screen('SelectStereoDrawBuffer', window, EYE);
        end
    
        Screen('FillRect', window, black, HC);
        if ~isempty(FFa)
            Screen('FillRect', window, white, FFa);
        end
        if ~isempty(FFb)
            Screen('FillRect', window, black, FFb);
        end    
    end
    
    function washUpScreen(window, black, white, HC, FFa, FFb, EYE)
        % Washes up the screen, removing the crosses but leaving the frame
        rectColor = [1 1 1];
    
        if ~nargin < 7
        Screen('SelectStereoDrawBuffer', window, EYE);
        end
    
        Screen('FillRect', window, rectColor*0.5, HC);
        if ~isempty(FFa)
            Screen('FillRect', window, white, FFa);
        end
        if ~isempty(FFb)
            Screen('FillRect', window, black, FFb);
        end   
     end


