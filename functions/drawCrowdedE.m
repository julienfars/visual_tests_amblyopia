function [dstRect_center_1, dstRect_center_2] = drawCrowdedE(window, E_shape, opto_size, xCenter, yCenter, crowd, diff, stereo, EYE_TEST, AMB_EYE)
% Draw the crowded E shapes on the screen
    if isempty(diff)
            diff = [0,0];
    end
        filterMode = 0;
        [s1, s2] = size(E_shape);
    if ~isempty(stereo)
        if stereo==100
            for i = 1:5
                dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter);
                dstRect_center_1(i,1:4) = dstRect_center_s;
            end
            for i = 1:5
                dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter+ diff(1), yCenter+ diff(2));
                dstRect_center_2(i,1:4) = dstRect_center_s;
            end
        elseif stereo == 101 
            for i = 1:5
                dstRect_center_s = [0 0 s1*0.5 s2] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter);
                dstRect_center_1(i,1:4) = dstRect_center_s;
            end
            for i = 1:5
                dstRect_center_s = [0 0 s1*0.5 s2] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter+ diff(1), yCenter+ diff(2));
                dstRect_center_2(i,1:4) = dstRect_center_s;
            end
        end
        Left = round(xCenter - 5 * opto_size * 2 * 0.75);
        Right = round(xCenter + 5 * 2 * opto_size * 0.75);
        Bottom = round(yCenter - 5 * opto_size * 0.75);
        Up = round(yCenter + 5 * opto_size * 0.75);

        dstRect_1_left = CenterRectArrayOnPoint(dstRect_center_1(2,:), Left, yCenter);
        dstRect_1_right = CenterRectArrayOnPoint(dstRect_center_1(3,:), Right, yCenter);
        dstRect_1_bottom = CenterRectArrayOnPoint(dstRect_center_1(4,:), xCenter, Bottom);
        dstRect_1_top = CenterRectArrayOnPoint(dstRect_center_1(5,:), xCenter, Up);
        dstRect_2_left = CenterRectArrayOnPoint(dstRect_center_2(2,:), Left + diff(1), yCenter + diff(2));
        dstRect_2_right = CenterRectArrayOnPoint(dstRect_center_2(3,:), Right + diff(1), yCenter + diff(2));
        dstRect_2_bottom = CenterRectArrayOnPoint(dstRect_center_2(4,:), xCenter + diff(1), Bottom + diff(2));
        dstRect_2_top = CenterRectArrayOnPoint(dstRect_center_2(5,:), xCenter + diff(1), Up + diff(2));
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
        Screen('DrawTextures', window, crowd(1), [], dstRect_center_1(1,:), [], filterMode);
        Screen('DrawTextures', window, crowd(2), [], dstRect_1_left, [], filterMode);
        Screen('DrawTextures', window, crowd(3), [], dstRect_1_top, [], filterMode);
        Screen('DrawTextures', window, crowd(4), [], dstRect_1_bottom, [], filterMode);
        Screen('DrawTextures', window, crowd(5), [], dstRect_1_right, [], filterMode);

        Screen('SelectStereoDrawBuffer', window, buffer_r);
        Screen('DrawTextures', window, crowd(1), [], dstRect_center_2(1,:), [], filterMode);
        Screen('DrawTextures', window, crowd(2), [], dstRect_2_left, [], filterMode);
        Screen('DrawTextures', window, crowd(3), [], dstRect_2_top, [], filterMode);
        Screen('DrawTextures', window, crowd(4), [], dstRect_2_bottom, [], filterMode);
        Screen('DrawTextures', window, crowd(5), [], dstRect_2_right, [], filterMode);
%     else % used for debugging
%         % Draw on a single screen
%         dstGab_center1 = CenterRectArrayOnPoint([0 0 s1*1 s2*1] .* opto_size, xCenter, yCenter);
%         Screen('DrawTextures', window, E_texture, [], dstGab_center1, [], filterMode);
    end
end
