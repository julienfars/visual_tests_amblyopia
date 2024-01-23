function drawSnellenStimulus(window, doubleScreen, E_texture, xCenter, yCenter, opto_size, diff)
    % Draw the Snellen stimulus on the screen.

    if doubleScreen
        [s1, s2] = size(E_texture);
        dstRect = [0 0 s1 s2*0.5] .* opto_size;
        dstRect1 = CenterRectArrayOnPoint(dstRect, xCenter, yCenter);
        Screen('SelectStereoDrawBuffer', window, 1);
        filterMode = 0;
        Screen('DrawTextures', window, E_texture, [], dstRect1, [], filterMode);

        dstRect2 = CenterRectArrayOnPoint(dstRect, xCenter + diff(1, :), yCenter + diff(2, :));
        Screen('SelectStereoDrawBuffer', window, 0);
        Screen('DrawTextures', window, E_texture, [], dstRect2, [], filterMode);
    else
        [s1, s2] = size(E_texture);
        dstRect = [0 0 s1 s2] .* opto_size;
        dstRect = CenterRectArrayOnPoint(dstRect, xCenter, yCenter);
        filterMode = 0;
        Screen('DrawTextures', window, E_texture, [], dstRect, [], filterMode);
    end
end