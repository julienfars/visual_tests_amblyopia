function [rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey,...
    angular, sc, temps, counter_trial, orientation, current_test, fixCross, HC1, HC2)
    
    timeSecs = KbWait;
    % Wait for a button press
    [keyIsDown, t, keyCode] = KbCheck;

    rt = 0;
    value = 'NO_RESPONSE';
    key = '';

    if keyIsDown
        rt = t - onsetTime; % Record the response time (rt)
        
        % Record the key
        keyCode = find(keyCode, 1);
        key = KbName(keyCode);
        
        if contains(var_eye_link, 'true')
            Eyelink('Message', 'KEY_PRESSED');
        end
        
        % Handle different test conditions
        if ~contains(current_test, {'interocular_imbalance', 'snellen', 'snellen_crowded', 'dichoptic'})
            [value, sc] = handleNonTestConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, angular, sc);
            % change it here, change the contains to choose from each
            % current test + add the temps in the choices
        elseif contains(current_test, 'interocular_imbalance')
            [value, sc] = handleInterocularImbalanceConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, angle_results_FE, normal_testing, sc);
        elseif contains(current_test, 'dichoptic')
            [value, sc] = handleDichopticConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, acc_resp, att_test, sc);
        else
            [value, sc] = handleOtherTestConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, orientation, sc);
        end
        
        fprintf('Current threshold from reversals: %0.2f +/- %0.2f\n\n', sc.curReversalThresh, sc.curReversalError);
        
        if fixCross
            % get the x-y shift from the center into the variable Stim_position 
            Stim_position = HC1(1:2,3) - HC2(1:2,3);
            Stim_position = Stim_position'; % transpose 
            Stim_position = num2str(Stim_position);
        else 
            Stim_position = [''];
        end
    end
    counter_trial = counter_trial+1;
end

% Define helper functions for each test condition
function [value, sc] = handleNonTestConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, angular, sc)
    value = 'WRONG_RESPONSE';
    
    if keyCode == escapeKey
        value = 'ESCAPE';
    elseif (keyCode == rightKey && angular == 315) || (keyCode == leftKey && angular == 45)
        sc.doResp(1);
        value = 'TRUE';
    else
        sc.doResp(0);
        value = 'FALSE';
    end
end

function [value, sc] = handleInterocularImbalanceConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, angle_results_FE, normal_testing, sc)
    value = 'WRONG_RESPONSE';
    
    if keyCode == escapeKey
        value = 'ESCAPE';
    elseif keyCode == rightKey && angle_results_FE == 352.9
        handleInterocularImbalanceResponse(~contains(normal_testing, 'yes'), sc);
    elseif keyCode == leftKey && angle_results_FE == 7.1
        handleInterocularImbalanceResponse(contains(normal_testing, 'yes'), sc);
    else
        handleInterocularImbalanceResponse(contains(normal_testing, 'yes'), sc);
    end
end

function [value, sc] = handleDichopticConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, acc_resp, att_test, sc)
    value = 'WRONG_RESPONSE';
    
    if keyCode == escapeKey
        value = 'ESCAPE';
    elseif keyCode == upKey && contains(acc_resp, 'top')
        handleDichopticResponse(sc, 1);
        value = 'TRUE';
    elseif keyCode == downKey && contains(acc_resp, 'bottom')
        handleDichopticResponse(sc, 1);
        value = 'TRUE';
    else
        handleDichopticResponse(sc, 0);
        value = 'FALSE';
    end
end

function [value, sc] = handleOtherTestConditions(keyCode, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, orientation, sc)
    value = 'WRONG_RESPONSE';
    
    if keyCode == escapeKey
        value = 'ESCAPE';
    elseif keyCode == rightKey && orientation == 0
        sc.doResp(1);
        value = 'TRUE';
    elseif keyCode == upKey && orientation == 270
        sc.doResp(1);
        value = 'TRUE';
    elseif keyCode == downKey && orientation == 90
        sc.doResp(1);
        value = 'TRUE';
    elseif keyCode == leftKey && orientation == 180
        sc.doResp(1);
        value = 'TRUE';
    else
        sc.doResp(0);
        value = 'FALSE';
    end
end

function handleInterocularImbalanceResponse(normalTesting, sc)
    if normalTesting
        sc.doResp(0);
    else
        sc.doResp(1);
    end
end

function handleDichopticResponse(sc, response)
    if ~repeatNoise
        sc.doResp(response);
    else
        sc.trialCount = sc.trialCount + 1;
    end
end