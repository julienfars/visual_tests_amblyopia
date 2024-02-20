function [dstGab_center1, dstGab_center2] = drawSnellenStimulus(window, E_texture, xCenter, yCenter, opto_size, diff, stereo, EYE_TEST, AMB_EYE, E_shape)
    % Draw the Snellen stimulus on the screen.
    if isempty(diff)
            diff = [0,0];
    end
        filterMode = 0;
        [s1, s2] = size(E_shape);
    if ~isempty(stereo)
        % Draw on the left screen
        if stereo==100
            dstGab_center1 = CenterRectArrayOnPoint([0 0 s1*1 s2*0.5] .* opto_size, xCenter, yCenter);
            dstGab_center2 = CenterRectArrayOnPoint([0 0 s1*1 s2*0.5] .* opto_size, xCenter + diff(1), yCenter + diff(2));
        elseif stereo == 101 
            dstGab_center1 = CenterRectArrayOnPoint([0 0 s1*0.5 s2*1] .* opto_size, xCenter, yCenter);
            dstGab_center2 = CenterRectArrayOnPoint([0 0 s1*0.5 s2*1] .* opto_size, xCenter + diff(1), yCenter + diff(2));
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
        Screen('DrawTextures', window, E_texture, [], dstGab_center1, [], filterMode);
        
        Screen('SelectStereoDrawBuffer', window, buffer_r);
        Screen('DrawTextures', window, E_texture, [], dstGab_center2, [], filterMode);

    else % used for debugging
        % Draw on a single screen
        dstGab_center1 = CenterRectArrayOnPoint([0 0 s1*1 s2*1] .* opto_size, xCenter, yCenter);
        Screen('DrawTextures', window, E_texture, [], dstGab_center1, [], filterMode);
     end
end