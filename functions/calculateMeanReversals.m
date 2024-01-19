function temps = calculateMeanReversals(sc, temps, mrt, maxNumReversals, freq, Stim_position, EYE_TEST, AMB_EYE)
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
end

