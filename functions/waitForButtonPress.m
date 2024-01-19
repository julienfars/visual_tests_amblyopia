function [rt, value, key] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc)
    % Wait for a button press
    timeSecs = KbWait;
    [keyIsDown, t, keyCode] = KbCheck;
    keyCode = find(keyCode, 1);
    
    rt = 0;
    value = 'NO_RESPONSE';
    key = '';

    if keyIsDown
        rt = t - onsetTime; % Record the response time (rt)
        if contains(var_eye_link, 'true')
            Eyelink('Message', 'KEY_PRESSED');
        end

        if keyCode == escapeKey % We can always leave the test (if glitch)
            value = 'ESCAPE';
        else
            if (keyCode == rightKey && angular == 315) || (keyCode == leftKey && angular == 45)
                sc.doResp(1);
                value = 'TRUE';
            else
                sc.doResp(0);
                value = 'FALSE';
            end
        end

        KbReleaseWait;

        % Record the key
        if keyCode == rightKey
            key = 'right';
        elseif keyCode == leftKey
            key = 'left';
        else
            key = 'other';
        end

        fprintf('Current threshold from reversals: %0.2f +/- %0.2f\n\n', ...
            sc.curReversalThresh, sc.curReversalError); % Left it for debug purposes
    end
end