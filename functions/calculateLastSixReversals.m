function [mrt,counter_mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, contrast_interleaved, counter_mrt)
    % Calculate the last six reversals and record in the mrt table
    if sc.trialCount > num_training + 1 % Only begins after the training trials
        if temps{sc.trialCount, 2} ~= temps{sc.trialCount - 1, 2} % Only records when the number of reversals change
            mrt(sc.revCount, :) = {sc.revCount, freq}; % Recorded in a table titled mrt
        end
    end

    if contrast_interleaved
        %here the calculation of the last six reversals FOR EACH STAIRCASE
     if staircaseArray(iSC).trialCount > 2 % add training trials + 2 to only begins after the training trials 
        if temps{staircaseArray(iSC).trialCount,{'Reversal'}} ~= temps{staircaseArray(iSC).trialCount-1,{'Reversal'}} && staircaseArray(iSC).revCount ~= 0% only records when the number of reversals change 
            mrt(counter_mrt,:) = {staircaseArray(iSC).revCount, contrast, iSC}; % recorded in a table titled mrt
            counter_mrt = counter_mrt +1;
        end
    end

    end
end