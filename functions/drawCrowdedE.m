function drawCrowdedE(window, doubleScreen, E_shape, E_rand_orientation, opto_size, xCenter, yCenter, crowd, diff)
    % Draw the crowded E shapes on the screen
    
    [s1, s2] = size(E_shape);

    for i = 1:5
        if E_rand_orientation(i) == 180 || E_rand_orientation(i) == 0
            dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size;
            dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter);
            dstRect_center(i,1:4) = dstRect_center_s;
        else
            dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size;
            dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter);
            dstRect_center(i,1:4) = dstRect_center_s;
        end
    end

    if doubleScreen
        Left = round(xCenter - 5 * opto_size * 2 * 0.75);
        Right = round(xCenter + 5 * 2 * opto_size * 0.75);
        Bottom = round(yCenter - 5 * opto_size * 0.75);
        Up = round(yCenter + 5 * opto_size * 0.75);

        dstRect_left = CenterRectArrayOnPoint(dstRect_center(2,:), Left, yCenter);
        dstRect_right = CenterRectArrayOnPoint(dstRect_center(3,:), Right, yCenter);
        dstRect_bottom = CenterRectArrayOnPoint(dstRect_center(4,:), xCenter, Bottom);
        dstRect_top = CenterRectArrayOnPoint(dstRect_center(5,:), xCenter, Up);

        if opto_size <= 2
            dstRect_top = dstRect_top + [0 -1 0 -1];
        end

        Screen('SelectStereoDrawBuffer', window, 1);
        Screen('DrawTextures', window, crowd(1), [], dstRect_center(1,:), [], filterMode);
        Screen('DrawTextures', window, crowd(2), [], dstRect_left, [], filterMode);
        Screen('DrawTextures', window, crowd(3), [], dstRect_top, [], filterMode);
        Screen('DrawTextures', window, crowd(4), [], dstRect_bottom, [], filterMode);
        Screen('DrawTextures', window, crowd(5), [], dstRect_right, [], filterMode);

        [s1, s2] = size(E_shape);

        for i = 1:5
            if E_rand_orientation(i) == 180 || E_rand_orientation(i) == 0
                dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter + diff(1,:), yCenter + diff(2,:));
                dstRect_center(i,1:4) = dstRect_center_s;
            else
                dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter + diff(1,:), yCenter + diff(2,:));
                dstRect_center(i,1:4) = dstRect_center_s;
            end
        end

        Left = round(xCenter - 5 * opto_size * 2 * 0.75);
        Right = round(xCenter + 5 * 2 * opto_size * 0.75);
        Bottom = round(yCenter - 5 * opto_size * 0.75);
        Up = round(yCenter + 5 * opto_size * 0.75);

        dstRect_left = CenterRectArrayOnPoint(dstRect_center(2,:), Left + diff(1,:), yCenter + diff(2,:));
        dstRect_right = CenterRectArrayOnPoint(dstRect_center(3,:), Right + diff(1,:), yCenter + diff(2,:));
        dstRect_bottom = CenterRectArrayOnPoint(dstRect_center(4,:), xCenter + diff(1,:), Bottom + diff(2,:));
        dstRect_top = CenterRectArrayOnPoint(dstRect_center(5,:), xCenter + diff(1,:), Up + diff(2,:));

        if opto_size <= 2
            dstRect_top = dstRect_top + [0 -1 0 -1];
        end

        Screen('SelectStereoDrawBuffer', window, 0);
        Screen('DrawTextures', window, crowd(1), [], dstRect_center(1,:), [], filterMode);
        Screen('DrawTextures', window, crowd(2), [], dstRect_left, [], filterMode);
        Screen('DrawTextures', window, crowd(3), [], dstRect_top, [], filterMode);
        Screen('DrawTextures', window, crowd(4), [], dstRect_bottom, [], filterMode);
        Screen('DrawTextures', window, crowd(5), [], dstRect_right, [], filterMode);
    else
        [s1, s2] = size(E_shape);

        for i = 1:5
            if E_rand_orientation(i) == 180 || E_rand_orientation(i) == 0
                dstRect_center_s = [0 0 s1 s2] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter);
                dstRect_center(i,1:4) = dstRect_center_s;
            else
                dstRect_center_s = [0 0 s1 s2] .* opto_size;
                dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter);
                dstRect_center(i,1:4) = dstRect_center_s;
            end
        end

        Left = xCenter - 5 * opto_size * 2 * 0.75;
        Right = xCenter + 5 * 2 * opto_size * 0.75;
        Bottom = yCenter - 5 * opto_size * 1.5;
        Up = yCenter + 5 * opto_size * 1.5;

        dstRect_left = CenterRectArrayOnPoint(dstRect_center(2,:), Left, yCenter);
        dstRect_top = CenterRectArrayOnPoint(dstRect_center(3,:), Right, yCenter);
        dstRect_bottom = CenterRectArrayOnPoint(dstRect_center(4,:), xCenter, Bottom);
        dstRect_right = CenterRectArrayOnPoint(dstRect_center(5,:), xCenter, Up);

        Screen('DrawTextures', window, crowd(1), [], dstRect_center(1,:), [], filterMode);
        Screen('DrawTextures', window, crowd(2), [], dstRect_left, [], filterMode);
        Screen('DrawTextures', window, crowd(3), [], dstRect_top, [], filterMode);
        Screen('DrawTextures', window, crowd(4), [], dstRect_bottom, [], filterMode);
        Screen('DrawTextures', window, crowd(5), [], dstRect_right, [], filterMode);
    end
end
