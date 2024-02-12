function plotStaircaseValues(sc, temps, mean_reversals, iSC, freq, current_test, contrastAE, contrast)
    % Plot staircase/values
    if sc.isFinished
        plot_results(sc.isFinished, temps, mean_reversals, iSC);
    else
        % Even if not finished, the plot is displayed
        if contains(current_test, 'interocular_imbalance')
            if contains(normal_testing, 'yes')
            plot_results(sc.isFinished, temps, contrastAE, iSC); 
            else   
            plot_results(sc.isFinished, temps, contrast, iSC); 
            end
        elseif contains(current_test, 'contrast_sensitivity')
            plot_results(sc.isFinished, temps, freq, iSC);
        end
    end
end