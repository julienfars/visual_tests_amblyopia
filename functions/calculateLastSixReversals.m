function [mrt,counter_mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, counter_mrt, var1, var2)
    % Calculate the last six reversals and record in the mrt table
    if contains(current_test, 'cutoff')
    
    if sc.trialCount > num_training + 1 % Only begins after the training trials
        if temps{sc.trialCount, 2} ~= temps{sc.trialCount - 1, 2} % Only records when the number of reversals change
            mrt(sc.revCount, :) = {sc.revCount, var1}; % Recorded in a table titled mrt
        end
    end
    elseif contains(current_test, 'contrast_interleaved')
        %here the calculation of the last six reversals FOR EACH STAIRCASE
         if sc.trialCount > 2 % add training trials + 2 to only begins after the training trials 
            if temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}} && sc.revCount ~= 0% only records when the number of reversals change 
                mrt(counter_mrt,:) = {sc.revCount, var1, iSC}; % recorded in a table titled mrt
                counter_mrt = counter_mrt +1;
            end
         end
    elseif contains(current_test, 'interocular_imbalance')
        %here the calculation of the last six reversals FOR EACH STAIRCASE
        if sc.trialCount > 1 % only begins after the first/training trials 
            if temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}} % only records when the number of reversals change 
                if contains(normal_testing, 'yes')
                 mrt(sc.revCount+1,:) = {sc.revCount, var1, iSC}; % recorded in a table titled mrt
                else   
                 mrt(sc.revCount+1,:) = {sc.revCount, var2, iSC}; % recorded in a table titled mrt
                end
            end
        end
    elseif contains(current_test, 'dichoptic')
         %here the calculation of the last six reversals
            if sc.trialCount > 1 % only begins after the training trials 
                if temps{sc.trialCount,2} ~= temps{sc.trialCount-1,2} % only records when the number of reversals change 
                    mrt(sc.revCount,:) = {sc.revCount, var1}; % recorded in a table titled mrt
                end
            end
    end

end