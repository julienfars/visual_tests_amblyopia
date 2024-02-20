function [mean_reversals, success_reversal] = calculateMeanReversals(sc,mrt, maxNumReversals, freq, current_test, iSC, FREQS_test)

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
        nb_reversals = size(mrt_extracted);
        if nb_reversals(1) >= 6
            success_reversal = 'Complete_reversals';
        else
            success_reversal = 'Incomplete_reversals';
        end
        % Record the mean of reversals at the end of the table
    end
end

