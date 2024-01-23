function [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, ...
    mrt, maxNumReversals, freq, Stim_position, EYE_TEST, AMB_EYE, ...
    current_test, counter_trial, mt, iSC, FREQS_test)

    % Check if the staircase is finished
    if sc.isFinished
        % Extract relevant rows from mrt table
        idx = any(mrt{:, 1} > maxNumReversals - 6, 2);
        mrt_extracted = mrt(idx, :);
        
        % Calculate mean of reversals
        mean_reversals = mean(mrt_extracted{:, 2});
        
        % Handle the case of no reversals
        if isnan(mean_reversals)
            mean_reversals = freq;
        end

        % Record the mean of reversals at the end of the table
        temps(sc.trialCount + 1, :) = {sc.trialCount + 1, sc.revCount, mean_reversals, 'MEAN', 'none', 0, Stim_position, EYE_TEST, AMB_EYE, 0, datetime('now')};
        
    else
        % Check if the staircase is finished
        if sc.isFinished
            % Extract relevant rows from mrt table for the specified staircase
            idx = any(mrt{:, 1} > maxNumReversals - 6, 2); 
            mrt_extracted = mrt(idx, :);
            
            % Further filter for the specific staircase (iSC)
            idx2 = mrt_extracted{:, 1} == iSC;
            mrt_extracted = mrt_extracted(idx2, :);
            
            % Calculate mean of reversals
            mean_reversals = mean(mrt_extracted{:, 2});
            
            % Handle the case of no reversals
            if isnan(mean_reversals)
                % Set the mean_reversals based on the test type
                if contains(current_test, 'interocular_imbalance')
                    if contains(normal_testing, 'yes')
                        mean_reversals = contrastAE;
                    else
                        mean_reversals = contrast;
                    end
                else
                    mean_reversals = freq;
                end
            end
            
            % Record the mean of reversals on the mt table
            mt(iSC, :) = {iSC, FREQS_test(iSC), freq, mean_reversals};
            
            % Update counter_trial
            counter_trial = counter_trial + 1;
            
            % Record the mean of reversals in the temps table
            temps(counter_trial, :) = {iSC, FREQS_test(iSC), freq, 0, 'mean', 'reversals', sc.trialCount, sc.revCount, mean_reversals, 'mean', 0, datetime('now'), EYE_TEST, AMB_EYE};
            
            % Update counter_trial again
            counter_trial = counter_trial + 1;
        end
    end
end

