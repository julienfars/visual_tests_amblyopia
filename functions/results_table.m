function [filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals)
%RESULTS_TABLE Summary of this function goes here
%   Detailed explanation goes here


%
    numberSuffix = 1;
    folder = 'data';
    if global_param.Retest == false 
        baseFileName = baseFileName + "_" + "TEST";
    else
        baseFileName = baseFileName + "_" + "RETEST";
    end
    if contains(EYE_TEST, 'Left')
        baseFileName = baseFileName + "_" + "LEFT";
    elseif contains(EYE_TEST, 'Right')
        baseFileName = baseFileName + "_" + "RIGHT";
    elseif contains(EYE_TEST, 'Both')
        baseFileName = baseFileName + "_" + "BOTH";
    else 
        baseFileName = baseFileName;
    end
    filename = fullfile(folder, baseFileName + '.xls');
    while numberSuffix < 500 % Exit at 500 as a failsafe, just in case all files exist.
      if exist(filename, 'file')
        % Construct a new filename.
        baseFileName = sprintf(baseFileName + "_nb_%d", numberSuffix);
        filename = fullfile(folder, baseFileName + '.xls');
        % Prepare for next time, in case this name also existed.
        numberSuffix  = numberSuffix  + 1;
      else
        break; % Out of while loop
      end
    end

        if contains(baseFileName, '_cutoff_freq')
            % we record the CUTOFF frequency (for each possibility: AE, FE and BE)
            if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
                global_param.cut_off_AE = mean_reversals; 
            elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
                global_param.cut_off_FE = mean_reversals;
            elseif contains(EYE_TEST, 'Both')
                global_param.cut_off_BE = mean_reversals;
            else %made another choice to cover all the possibilities (and still get the answer)
                global_param.cut_off = mean_reversals;
            end

        elseif contains(baseFileName, '_contrast_interleaved')
            % we record the contrast frequencies (for each possibility: AE, FE and BE)
            if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
                global_param.contrast_AE = mean_reversals; 
            elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
                global_param.contrast_FE = mean_reversals;
            elseif contains(EYE_TEST, 'Both')
                global_param.contrast_BE = mean_reversals;
            else %made another choice to cover all the possibilities (and still get the answer)
                global_param.contrast = mean_reversals;
            end
        
        elseif contains(baseFileName, '_binoc_orientation')
                % we record the data in the global parameters
                global_param.binoc = mean_reversals;

        elseif contains(baseFileName, '_dichoptic')
                % we record the contrast in the global parameters
                global_param.dichop = mean_reversals;
        
        elseif contains(baseFileName, '_snellen_e')
                if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
                    global_param.logMAR_AE = mean_reversals; 
                elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
                    global_param.logMAR_FE = mean_reversals;
                elseif contains(EYE_TEST, 'Both')
                    global_param.logMAR_BE = mean_reversals;
                else %made another choice to cover all the possibilities (and still get the answer)
                    global_param.logMAR = mean_reversals;
                end
        
        elseif contains(baseFileName, '_snellen_e_crowded')
                if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
                    global_param.logMAR_AE_crowded = mean_reversals; 
                elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
                    global_param.logMAR_FE_crowded = mean_reversals;
                elseif contains(EYE_TEST, 'Both')
                    global_param.logMAR_BE_crowded = mean_reversals;
                else %made another choice to cover all the possibilities (and still get the answer)
                    global_param.logMAR_crowded = mean_reversals;
                end
        
        else
                fprintf('Careful, if you received this message and you did not run the asteroid script there might be a mistake in your code')
                return
        end

end

