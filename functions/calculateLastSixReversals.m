function mrt = calculateLastSixReversals(sc, temps, mrt, num_training)
    % Calculate the last six reversals and record in the mrt table
    if sc.trialCount > num_training + 1 % Only begins after the training trials
        if temps{sc.trialCount, 2} ~= temps{sc.trialCount - 1, 2} % Only records when the number of reversals change
            mrt(sc.revCount, :) = {sc.revCount, freq}; % Recorded in a table titled mrt
        end
    end
end