function washDisplay(window, doubleScreen, windowRect, dstGab_center1, dstGab_center2, FF1b, FF1w, FF2b, FF2w)
    % 'Wash' the display
    % After the stimulus was displayed, we wash the screen by displaying a
    % background color surface on the stimulus area

    if doubleScreen
        rectColor = [1 1 1];
        % Draw on the left screen
        Screen('SelectStereoDrawBuffer', window, 0);
        Screen('FillRect', window, rectColor * 0.5, dstGab_center1);
        Screen('FillRect', window, black, FF1b);
        Screen('FillRect', window, white, FF1w);

        % Draw on the right screen
        Screen('SelectStereoDrawBuffer', window, 1);
        Screen('FillRect', window, rectColor * 0.5, dstGab_center2);
        Screen('FillRect', window, black, FF2b);
        Screen('FillRect', window, white, FF2w);

        Screen('Flip', window);
    else
        baseRect = [0 0 200 250];
        [xCenter, yCenter] = RectCenter(windowRect);
        rectColor = [1 1 1];

        % Draw on a single screen
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
        Screen('FillRect', window, rectColor * 0.5, centeredRect);
        Screen('FillRect', window, black, FF2b);
        Screen('FillRect', window, white, FF2w);

        Screen('Flip', window);
    end
end