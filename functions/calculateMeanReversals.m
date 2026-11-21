function [mean_reversals, success_reversal, mt] = calculateMeanReversals(sc,mrt, maxNumReversals, freq, current_test, iSC, FREQS_test, mt)

    % Check if the staircase is finished
    if sc.isFinished
        if ~contains(current_test, 'contrast_interleaved') && ~contains(current_test, 'interocular_imbalance')
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
        else
            % Interleaved staircases (contrast_interleaved, interocular_imbalance).
            % Threshold = mean of the last 6 reversal levels of THIS staircase,
            % taken from the staircase object itself (sc.reversals, log10 units).
            % Both scripts map a staircase level to contrast as 10^level/100.
            %
            % Up to v1.0.0 this branch filtered the shared reversal table on
            % its ReversalNumber column instead of its Staircase column, and
            % averaged the frequency column, so the recorded MEAN rows were
            % not contrast thresholds. See CHANGELOG.md.
            nRev = numel(sc.reversals);
            if nRev < 2 % fewer than 2 reversals: keep the last tested value (as documented in Contrast_Interleaved.m)
                mean_reversals = freq;
            else
                lastRevs = sc.reversals(max(1, nRev - 5):nRev);
                mean_reversals = mean(10.^lastRevs / 100);
            end
            % the mean of reversals is then recorded on a new table
            mt(iSC,:) = {iSC, FREQS_test(iSC), freq, mean_reversals};
            if nRev >= 6
                success_reversal = 'Complete_reversals';
            else
                success_reversal = 'Incomplete_reversals';
            end
        end
    end
end
        

