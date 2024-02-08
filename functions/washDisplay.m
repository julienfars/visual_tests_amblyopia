function washDisplay(window, AMB_EYE, EYE_TEST, HC1, HC2, doubleScreen, windowRect, dstGab_center1, dstGab_center2, FF1b, FF1w, FF2b, FF2w, black, white)
    % 'Wash' the display
    % After the stimulus was displayed, we wash the screen by displaying a
    % background color surface on the stimulus area

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

        washUpScreen(window, black, white, dstGab_center1, FF1w, FF1b, buffer_l) 
        washUpScreen(window, black, white, dstGab_center2, FF2w, FF2b, buffer_r)
    
    Screen('Flip', window);
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

%{
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
%}