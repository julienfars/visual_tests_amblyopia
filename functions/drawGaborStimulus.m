function [dstGab_center1, dstGab_center2] = drawGaborStimulus(window, gabortex, stereo, ...
    AMB_EYE, EYE_TEST, xCenter, yCenter, angular, propertiesMat, gaborDimPix, diff, ...
    FF1b, FF1w, FF2b, FF2w, black, white)

    if isempty(diff)
        diff = [0,0];
    end
    
    if ~isempty(stereo)
        % Draw on the left screen
        if stereo==100
            dstGab_center1 = CenterRectArrayOnPoint([0 0 1 0.5] .* gaborDimPix, xCenter, yCenter);
            dstGab_center2 = CenterRectArrayOnPoint([0 0 1 0.5] .* gaborDimPix, xCenter + diff(1), yCenter + diff(2));
        elseif stereo == 101 
            dstGab_center1 = CenterRectArrayOnPoint([0 0 0.5 1] .* gaborDimPix, xCenter, yCenter);
            dstGab_center2 = CenterRectArrayOnPoint([0 0 0.5 1] .* gaborDimPix, xCenter + diff(1), yCenter + diff(2));
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

        Screen('SelectStereoDrawBuffer', window, buffer_l);
        Screen('DrawTextures', window, gabortex, [], dstGab_center1, angular, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        if ~isempty(FF1w) && ~isempty(FF1b)
        Screen('FillRect', window, white, FF1w);
        Screen('FillRect', window, black, FF1b);
        end

        Screen('SelectStereoDrawBuffer', window, buffer_r);
        Screen('DrawTextures', window, gabortex, [], dstGab_center2, angular, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat'); 
        if ~isempty(FF2w) && ~isempty(FF2b)
        Screen('FillRect', window, white, FF2w);
        Screen('FillRect', window, black, FF2b);
        end
    else % used for debugging
        % Draw on a single screen
        dstGab_center1 = CenterRectArrayOnPoint([0 0 1 1] .* gaborDimPix, xCenter, yCenter);
        Screen('DrawTextures', window, gabortex, [], dstGab_center1, angular, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        if ~isempty(FF2w) && ~isempty(FF2b) && ~isempty(FF1w) && ~isempty(FF1b)
        Screen('FillRect', window, black, FF1b);
        Screen('FillRect', window, white, FF1w);
        Screen('FillRect', window, black, FF2b);
        Screen('FillRect', window, white, FF2w);
        end
    end
end