function [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, ...
    mrt, maxNumReversals, freq, Stim_position, EYE_TEST, AMB_EYE, ...
    current_test, counter_trial, mt, iSC, FREQS_test)

    % Calculate mean of reversals from the mrt table when the staircase is finished
    if sc.isFinished
        idx = any(mrt{:, 1} > maxNumReversals - 6, 2);
        mrt_extracted = mrt(idx, :);
        mean_reversals = mean(mrt_extracted{:, 2});
        if isnan(mean_reversals) % In the case of having no reversals at all (get the last result)
            mean_reversals = freq;
        end

        % Record the mean of reversals at the end of the table
        temps(sc.trialCount + 1, :) = {sc.trialCount + 1, sc.revCount, mean_reversals, 'MEAN', 'none', 0, Stim_position, EYE_TEST, AMB_EYE, 0, datetime('now')};
    end

    if ~contains(current_test, 'cutoff') 
        if sc.isFinished
    % check if this part keeps the previous plots open
        idx = any(mrt{:,1} > maxNumReversals-6,2); %alternative is to get all of the reversals and THEN remove some from the total in mrt_extracted                                   
        mrt_extracted = mrt(idx,:);
        idx2 = any(mrt_extracted{:,1} == iSC,2); 
        mrt_extracted = mrt_extracted(idx2,:);
        mean_reversals = mean(mrt_extracted{:,2});
            if isnan(mean_reversals) % in the case of having no reversals at all (get the last result)
                if contains(current_test, 'interocular_imbalance')
                    if contains(normal_testing, 'yes')
                        mean_reversals = contrastAE;
                    else
                        mean_reversals = contrast;
                    end
                else        
                    mean_reversals = contrast;
                end
            end
        % the mean of reversals is then recorded on a new table 
        mt(iSC,:) = {iSC, FREQS_test(iSC), freq, mean_reversals};
        counter_trial = counter_trial+1;
        temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq,0, 'mean', 'reversals', sc.trialCount, sc.revCount, mean_reversals, 'mean', 0, datetime('now'), EYE_TEST, AMB_EYE};
        counter_trial = counter_trial+1;
        end
    end
end

