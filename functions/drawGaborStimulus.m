function [dstGab_center1, dstGab_center2] = drawGaborStimulus(window, gabortex, doubleScreen, xCenter, yCenter, angular, propertiesMat, gaborDimPix, diff, FF1b, FF1w, FF2b, FF2w, black, white)
    if doubleScreen
        % Draw on the left screen
        dstGab_center1 = CenterRectArrayOnPoint([0 0 1 0.5] .* gaborDimPix, xCenter, yCenter);
        Screen('SelectStereoDrawBuffer', window, 1);
        Screen('DrawTextures', window, gabortex, [], dstGab_center1, angular, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        Screen('FillRect', window, black, FF2b);
        Screen('FillRect', window, white, FF2w);

        % Draw on the right screen
        dstGab_center2 = CenterRectArrayOnPoint([0 0 1 0.5] .* gaborDimPix, xCenter + diff(1,:), yCenter + diff(2,:));
        Screen('SelectStereoDrawBuffer', window, 0);
        Screen('DrawTextures', window, gabortex, [], dstGab_center2, angular, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat'); 
        Screen('FillRect', window, black, FF1b);
        Screen('FillRect', window, white, FF1w);

    else
        % Draw on a single screen
        dstGab_center1 = CenterRectArrayOnPoint([0 0 1 1] .* gaborDimPix, xCenter, yCenter);
        dstGab_center2 = CenterRectArrayOnPoint([0 0 1 1] .* gaborDimPix, xCenter, yCenter);
        Screen('DrawTextures', window, gabortex, [], [], angular, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');
        Screen('FillRect', window, black, FF2b);
        Screen('FillRect', window, white, FF2w);
    end
end