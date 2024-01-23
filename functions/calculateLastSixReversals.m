function [mrt, counter_mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, counter_mrt, var1, var2)
    % Calculate the last six reversals and record in the mrt table
    
    recordReversal = sc.trialCount > num_training + 1;
    
    switch current_test
        case 'cutoff'
            recordReversal = recordReversal && (temps{sc.trialCount, 2} ~= temps{sc.trialCount - 1, 2});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % Recorded in a table titled mrt

        case 'contrast_interleaved'
            recordReversal = recordReversal && (sc.trialCount > 2) && (temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}}) && (sc.revCount ~= 0);
            mrt(counter_mrt, :) = {sc.revCount, var1, iSC}; % Recorded in a table titled mrt
            counter_mrt = counter_mrt + 1;

        case 'interocular_imbalance'
            recordReversal = recordReversal && (sc.trialCount > 1) && (temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}});
            mrt(sc.revCount + 1, :) = {sc.revCount, ifelse(contains(normal_testing, 'yes'), var1, var2), iSC}; % Recorded in a table titled mrt

        case 'dichoptic'
            recordReversal = recordReversal && (sc.trialCount > 1) && (temps{sc.trialCount, 2} ~= temps{sc.trialCount-1, 2});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % Recorded in a table titled mrt

        case 'snellen'
            recordReversal = recordReversal && (sc.trialCount > 1) && (sc.revCount > 0) && (temps{sc.trialCount, 2} ~= temps{sc.trialCount-1, 2});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % recorded in a table titled mrt
    end

end
