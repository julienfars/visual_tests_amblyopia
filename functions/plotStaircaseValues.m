function plotStaircaseValues(sc, temps, mean_reversals, iSC)
    % Plot staircase/values
    if sc.isFinished
        plot_results(sc.isFinished, temps, mean_reversals, iSC);
    else
        % Even if not finished, the plot is displayed
        plot_results(sc.isFinished, temps, freq, iSC);
    end
end