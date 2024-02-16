function plotStaircaseValues(sc, temps, mean_reversals, iSC, freq, current_test, contrastAE, contrast, normal_testing)
    
%varargin = checkArgsAndFillMissing({sc, temps, mean_reversals, iSC, freq, current_test, contrastAE, contrast, normal_testing}, 9);
%[sc, temps, mean_reversals, iSC, freq, current_test, contrastAE, contrast, normal_testing] = varargin{:};

% Plot staircase/values
    if sc.isFinished
        plot_results(sc.isFinished, temps, mean_reversals, iSC);
    else
        % Even if not finished, the plot is displayed
        if contains(current_test, 'interocular_imbalance')
            if normal_testing
            plot_results(sc.isFinished, temps, contrastAE, iSC); 
            else   
            plot_results(sc.isFinished, temps, contrast, iSC); 
            end
        elseif contains(current_test, 'contrast_sensitivity')
            plot_results(sc.isFinished, temps, freq, iSC);
        end
    end
end