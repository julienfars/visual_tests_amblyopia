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
            idx = any(mrt{:,1} > maxNumReversals-6,2); %alternative is to get all of the reversals and THEN remove some from the total in mrt_extracted                                   
            mrt_extracted = mrt(idx,:);
            idx2 = any(mrt_extracted{:,3} == iSC,2); 
            mrt_extracted = mrt_extracted(idx2,:);
            mean_reversals = mean(mrt_extracted{:,4});
            if isnan(mean_reversals) || max(mrt_extracted{:,1})<6 % in the case of having no reversals at all (get the last result)
                        mean_reversals = freq;
            end
            % the mean of reversals is then recorded on a new table 
            mt(iSC,:) = {iSC, FREQS_test(iSC), freq, mean_reversals};
            if max(mrt_extracted{:,1})>=6
                success_reversal = 'Complete_reversals';
            else
                success_reversal = 'Incomplete_reversals';
            end
        end
    end
end
        

