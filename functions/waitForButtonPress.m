function [rt, value, key, temps, counter_trial] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc, temp, counter_trial)
    if ~contains(current_test, 'interoculat_imbalance')
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
         % get the x-y shift from the center into the variable Stim_position 
        Stim_position = HC1(1:2,3) - HC2(1:2,3);
        Stim_position = Stim_position'; % transpose 
        Stim_position = num2str(Stim_position);
    
        %add stim position
        temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq,orientation, Stim_position, key, staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, contrast, value, rt, datetime('now'), EYE_TEST, AMB_EYE};
        counter_trial = counter_trial +1;
    else
           timeSecs = KbWait;
           [ keyIsDown, t, keyCode ] = KbCheck;
           keyCode = find(keyCode, 1);
           %think about changing the loops so if the participant choose a key that
           %is not defined, the trial does not change
           if keyIsDown
               rt = t - onsetTime;
               if contains(var_eye_link, 'true')
                Eyelink('Message', 'KEY_PRESSED');
               end
            if keyCode == escapeKey
                    break;
            elseif  keyCode==rightKey && angle_results_FE == 352.9  
        % It means that the AE is chosen instead fo the FE
               if ~contains(normal_testing, 'yes') % if normal testing = no
        % It means I must increase the FE contrast when testing amblyopes
                   staircaseArray(iSC).doResp(1); % HERE
               else
         % It means I must decrease the AE contrast when testing normal observers          
                   staircaseArray(iSC).doResp(0);
               end
               value = 'AE';
            elseif keyCode==leftKey && angle_results_FE == 7.1
                if ~contains(normal_testing, 'yes')
                    staircaseArray(iSC).doResp(1);
                else 
                    staircaseArray(iSC).doResp(0)
                end
                    value = 'AE';
            else
                if ~contains(normal_testing, 'yes')
                    staircaseArray(iSC).doResp(0);
                else
                    staircaseArray(iSC).doResp(1);
                end
                    value = 'FE';
            end
            KbReleaseWait;
            if keyCode==rightKey
                key = "right";
            elseif keyCode==leftKey
                key = "left";
            else
                key = "other";
            end
                % sending the Boolean (0 or 1) isCorrect to the staircase
                %staircaseArray(iSC).doResp(isSimCorrect); % calls "doResp" method of staircase
        
                % current rough estimate of threshold from staircase reversals
                % n.b. currently uses ALL reversals after the first reversal
                fprintf('Staircase %0.0f: current threshold from reversals: %0.2f +/- %0.2f\n\n', ...
                        iSC, staircaseArray(iSC).curReversalThresh, staircaseArray(iSC).curReversalError)
        
            % get the x-y shift from the center into the variable Stim_position 
            Stim_position = HC1(1:2,3) - HC2(1:2,3);
            Stim_position = Stim_position'; % transpose 
            Stim_position = num2str(Stim_position);
        
            
            temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq, angle_AE, angle_FE, Stim_position, key, staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, contrastAE, contrast, rt, datetime('now'), EYE_TEST, AMB_EYE};
            
            counter_trial = counter_trial +1;
           end
    end

end