function time_presentation_function(window, gaborDimPix, ...
xCenter, yCenter, diff, black, white, FF1b, FF1w, FF2b, ...
FF2w, current_test, debug, time)
    % This function represents the time presentation logic for a stereo Gabor stimulus.

    if contains(current_test, 'interocular_imbalance')
    % Wait (should be 0.2 seconds)
    WaitSecs(time);

    % Debug: Wait for a key press if debug_interocular_imbalance is true
    if debug
        KbStrokeWait;
    end

    rectColor = [1 1 1];
    
    % Draw Gabor stimulus for the first eye
    dstGab_center = [0 0 1 0.5] .* gaborDimPix;
    dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter, yCenter);
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('FillRect', window, rectColor*0.5, dstGab_center1);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);

    % Draw Gabor stimulus for the second eye
    dstGab_center = [0 0 1 0.5] .* gaborDimPix;
    dstGab_center2 = CenterRectArrayOnPoint(dstGab_center, xCenter + diff(1, :), yCenter + diff(2, :));
    Screen('SelectStereoDrawBuffer', window, 1);
    Screen('FillRect', window, rectColor*0.5, dstGab_center2);
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    elseif contains(current_test, 'dichoptic')
        
    WaitSecs(time);
    
    baseRect = [0 0 512 256];
    [xCenter, yCenter] = RectCenter(windowRect);
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    rectColor = [1 1 1];
    dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
    dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
    if contains(AMB_EYE, 'Left') 
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_center1);
    else 
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_center1);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);
    end
    Screen('DrawingFinished', window);
    end
end