function [rt, value, key, temps, counter_trial] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc, temps, counter_trial, orientation)
    
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
            [value, sc] = handleNonTestConditions(keyCode, escapeKey, rightKey, leftKey, angular, sc);
        elseif contains(current_test, 'interocular_imbalance')
            [value, sc] = handleInterocularImbalanceConditions(keyCode, escapeKey, rightKey, leftKey, angle_results_FE, normal_testing, sc);
        elseif contains(current_test, 'dichoptic')
            [value, sc] = handleDichopticConditions(keyCode, escapeKey, upKey, downKey, acc_resp, att_test, sc);
        else
            [value, sc] = handleOtherTestConditions(keyCode, escapeKey, rightKey, leftKey, upKey, downKey, orientation, sc);
        end
        
        fprintf('Current threshold from reversals: %0.2f +/- %0.2f\n\n', sc.curReversalThresh, sc.curReversalError);
        
        % get the x-y shift from the center into the variable Stim_position 
        Stim_position = HC1(1:2,3) - HC2(1:2,3);
        Stim_position = Stim_position'; % transpose 
        Stim_position = num2str(Stim_position);

        temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq, orientation, Stim_position, key, sc.trialCount, sc.revCount, contrast, value, rt, datetime('now'), EYE_TEST, AMB_EYE};
        counter_trial = counter_trial + 1;
    end
end

% Define helper functions for each test condition
function [value, sc] = handleNonTestConditions(keyCode, escapeKey, rightKey, leftKey, angular, sc)
    value = 'NO_RESPONSE';
    
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

function [value, sc] = handleInterocularImbalanceConditions(keyCode, escapeKey, rightKey, leftKey, angle_results_FE, normal_testing, sc)
    value = 'NO_RESPONSE';
    
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

function [value, sc] = handleDichopticConditions(keyCode, escapeKey, upKey, downKey, acc_resp, att_test, sc)
    value = 'NO_RESPONSE';
    
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

function [value, sc] = handleOtherTestConditions(keyCode, escapeKey, rightKey, leftKey, upKey, downKey, orientation, sc)
    value = 'NO_RESPONSE';
    
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