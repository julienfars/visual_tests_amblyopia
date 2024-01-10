function [HC1,HC2, FF1w, FF1b, FF2w, FF2b] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress)

%FIX_CROSS Summary 
%   This function is running the fix cross. The same kind of step is done
%   witht the visual training (see Liu et al. 2019). At the moment, the fix cross is only showed
%   once. But with a slight modification, we can display it before each
%   trial. 


% will determine which side of the crosses will be moving (along with one copy of the fusion frame)
    if contains(AMB_EYE, 'Left') 
            HC1 = HCl;
            HC2 = HCr;
            FF1w = FFLw;
            FF1b = FFLb;
            FF2w = FFRw;
            FF2b = FFRb;
        else
            HC1 = HCr;
            HC2 = HCl;
            FF1w = FFRw;
            FF1b = FFRb;
            FF2w = FFLw;
            FF2b = FFLb;
    end


    while fixCross == true
    
    vbl = Screen('Flip', window);
    waitframes = 1; 
    exitFixCross = false;

    while exitFixCross == false % If I want to display the cross at every trial -> I just need to set the variable = false at the end of the staircase loop 

    % Check the keyboard to see if a button has been pressed
    [keyIsDown, secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey) % if the escape key is used, then the half cross is set, this will be confirmed by the experimenter (the participant notifies when the cross/frame is at the right spot=fusion)
        exitFixCross = true; %I doubled the while loop just to be sure it goes to the next step - must change later
        fixCross = false;
        doubleScreen = true;
    elseif keyCode(leftKey) % each short press of the key moves the cross+frame of one pixel
        HC1(1,:)  = HC1(1,:)  - pixelsPerPress;
        HC1(3,:)  = HC1(3,:)  - pixelsPerPress;
        FF1w(1,:) = FF1w(1,:) - pixelsPerPress;
        FF1w(3,:) = FF1w(3,:) - pixelsPerPress;
        FF1b(1,:) = FF1b(1,:) - pixelsPerPress;
        FF1b(3,:) = FF1b(3,:) - pixelsPerPress;
    elseif keyCode(rightKey)
        HC1(1,:)  = HC1(1,:)  + pixelsPerPress;
        HC1(3,:)  = HC1(3,:)  + pixelsPerPress;
        FF1w(1,:) = FF1w(1,:) + pixelsPerPress;
        FF1w(3,:) = FF1w(3,:) + pixelsPerPress;
        FF1b(1,:) = FF1b(1,:) + pixelsPerPress;
        FF1b(3,:) = FF1b(3,:) + pixelsPerPress;
    elseif keyCode(upKey)
        HC1(2,:)  = HC1(2,:)  - pixelsPerPress;
        HC1(4,:)  = HC1(4,:)  - pixelsPerPress;
        FF1w(2,:) = FF1w(2,:) - pixelsPerPress;
        FF1w(4,:) = FF1w(4,:) - pixelsPerPress;
        FF1b(2,:) = FF1b(2,:) - pixelsPerPress;
        FF1b(4,:) = FF1b(4,:) - pixelsPerPress;
    elseif keyCode(downKey)
        HC1(2,:)  = HC1(2,:)  + pixelsPerPress;
        HC1(4,:)  = HC1(4,:)  + pixelsPerPress;
        FF1w(2,:) = FF1w(2,:) + pixelsPerPress;
        FF1w(4,:) = FF1w(4,:) + pixelsPerPress;
        FF1b(2,:) = FF1b(2,:) + pixelsPerPress;
        FF1b(4,:) = FF1b(4,:) + pixelsPerPress;
    elseif keyCode(spaceKey) % if the spacekey is pressed, then the cross+frame go back to the centre of the display
         if contains(AMB_EYE, 'Left') 
            HC1 = HCl;
            HC2 = HCr;
            FF1w = FFLw;
            FF2w = FFRw;
            FF1b = FFLb;
            FF2b = FFRb;
            else
            HC1 = HCr;
            HC2 = HCl;
            FF1w = FFRw;
            FF2w = FFLw;
            FF1b = FFRb;
            FF2b = FFLb; 
         end
    end
    
    % Draw the half crosses to the screen
    %first half cross
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, black, HC1);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);
    %second half cross
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, HC2);
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % here we calculate the difference between the position of the half
    % cross and the center of the screen, this value will be used when
    % displaying the Stimuli
        if contains(AMB_EYE, 'Left') 
            diff(:,1) = HC1(:,1)-HCl(:,1); %
        else
            diff(:,1) = HC1(:,1)-HCr(:,1); %
        end
    end

    % this part is "washing up" the screen, it removes the crosses from the
    % display but leaves the frame
    rectColor = [1 1 1];

    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC2);
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    Screen('Flip', window);
    WaitSecs(1);

    end

end

