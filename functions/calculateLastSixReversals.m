function [mrt, counter_mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, counter_mrt, var1, var2, iSC, normal_testing)
    % Calculate the last six reversals and record in the mrt table
    
    recordReversal = sc.trialCount > num_training + 1;
    if sc.revCount

    switch current_test
        case 'cutoff'
            recordReversal = recordReversal && (temps{sc.trialCount, 2} ~= temps{sc.trialCount - 1, 2});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % Recorded in a table titled mrt

        case 'contrast_interleaved'
            % Example usage
            trial_num = 'Trial'; % Specify the name of the column you want to search
            value = sc.trialCount; % Specify the value you want to find
            
            % Find the row number of the last row where the value in column X matches the specified value
            trialCount = findLastRowIndexWithValue(temps, trial_num, value);
            
            % Retrieve the value from the specified column using the row number
            trialCount_2 = findLastRowIndexWithValue(temps, trial_num, value-1);

            recordReversal = recordReversal && (sc.trialCount > 2) && (temps{trialCount, 4}) ~= (temps{trialCount_2, 4}) && (sc.revCount ~= 0);
            mrt(counter_mrt, :) = {sc.revCount, var1, iSC}; % Recorded in a table titled mrt
            counter_mrt = counter_mrt + 1;

        case 'interocular_imbalance'
            recordReversal = recordReversal && (sc.trialCount > 1) && (temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}});
            if normal_testing
                value = var1;
            else
                value = var2;
            end
            mrt(sc.revCount, :) = {sc.revCount, value, iSC}; % Recorded in a table titled mrt

        case 'dichoptic'
            recordReversal = recordReversal && (sc.trialCount > 1) && (temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % Recorded in a table titled mrt

        case 'snellen'
            recordReversal = recordReversal && (sc.trialCount > 1) && (temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}});
            %recordReversal = recordReversal && (sc.trialCount > 1) && (sc.revCount > 0) && (temps{sc.trialCount, 2} ~= temps{sc.trialCount-1, 2});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % recorded in a table titled mrt
        
        case 'snellen_crowded'
            recordReversal = recordReversal && (sc.trialCount > 1) && (temps{sc.trialCount,{'Reversal'}} ~= temps{sc.trialCount-1,{'Reversal'}});
            %recordReversal = recordReversal && (sc.trialCount > 1) && (sc.revCount > 0) && (temps{sc.trialCount, 2} ~= temps{sc.trialCount-1, 2});
            mrt(sc.revCount, :) = {sc.revCount, var1}; % recorded in a table titled mrt
    end
    end

end
