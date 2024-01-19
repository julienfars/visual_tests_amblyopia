%% displayStimulus_binocular_imbalance function
function [buffer_num_AE, buffer_num_FE, angle_AE, angle_FE, angle_results_AE, angle_results_FE] = displayStimulus_binocular_imbalance(window, gabortex, xCenter, yCenter, angular_1, angular_2, propertiesMatFE, propertiesMatAE, gaborDimPix, diff, FF1b, FF1w, FF2b, FF2w)
    % Display Gabor stimulus for binocular imbalance experiment

    if contains(AMB_EYE, 'Left') 
        buffer_num_AE = 0;
        buffer_num_FE = 1; 
        angle_AE = angular_2;
        angle_FE = angular_1;
        angle_results_AE = angular_1;
        angle_results_FE = angular_2;
    else
        buffer_num_AE = 1;
        buffer_num_FE = 0;
        angle_AE = angular_1;
        angle_FE = angular_2;
        angle_results_AE = angular_2;
        angle_results_FE = angular_1;
    end

    % Display stimulus for the first eye
    dstGab_center1 = CenterRectArrayOnPoint([0 0 1 0.5] .* gaborDimPix, xCenter, yCenter);
    Screen('SelectStereoDrawBuffer', window, buffer_num_FE);
    Screen('DrawTextures', window, gabortex, [], dstGab_center1, angle_FE, [], [], [], [], kPsychDontDoRotation, propertiesMatFE');
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);

    % Display stimulus for the second eye
    dstGab_center2 = CenterRectArrayOnPoint([0 0 1 0.5] .* gaborDimPix, xCenter + diff(1,:), yCenter + diff(2,:));
    Screen('SelectStereoDrawBuffer', window, buffer_num_AE);
    Screen('DrawTextures', window, gabortex, [], dstGab_center2, angle_AE, [], [], [], [], kPsychDontDoRotation, propertiesMatAE');
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    % Flip to the screen
    beep; % Use a sound to alert participants that the stimulus is shown
    Screen('Flip', window);
end