function [filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals)
    % Set the base filename with appropriate prefixes
    baseFileName = baseFileName + "_" + choosePrefix(EYE_TEST, AMB_EYE) + chooseTestType(baseFileName);

    % Generate the full file path
    folder = 'data';
    extension = '.xls';
    filename = fullfile(folder, getUniqueFileName(baseFileName)+extension);

    % Update global parameters based on test type.
    % NOTE: the returned struct must be captured; MATLAB structs are passed by
    % value (before v1.1.0 this result was discarded, see CHANGELOG.md).
    global_param = updateGlobalParams(global_param, baseFileName, mean_reversals, EYE_TEST, AMB_EYE);
end

function prefix = choosePrefix(EYE_TEST, AMB_EYE)
    if contains(EYE_TEST, 'Left')
        prefix = "LEFT";
    elseif contains(EYE_TEST, 'Right')
        prefix = "RIGHT";
    elseif contains(EYE_TEST, 'Both')
        prefix = "BOTH";
    else
        prefix = "";
    end
    if contains(AMB_EYE, EYE_TEST)
        prefix = prefix + '_AMB';
    end
end

function testType = chooseTestType(baseFileName)
    testType = "";
    if contains(baseFileName, '_cutoff_freq')
        testType = "_cutoff_freq";
    elseif contains(baseFileName, '_contrast_interleaved')
        testType = "_contrast_interleaved";
    elseif contains(baseFileName, '_binoc_orientation')
        testType = "_binoc_orientation";
    elseif contains(baseFileName, '_dichoptic')
        testType = "_dichoptic";
    elseif contains(baseFileName, '_asteroid')
        testType = '_asteroid';
    elseif contains(baseFileName, '_snellen_e_crowded') % must precede '_snellen_e'
        testType = "_snellen_e_crowded";
    elseif contains(baseFileName, '_snellen_e')
        testType = "_snellen_e";
    else
        fprintf('Careful, if you received this message and you did not run the asteroid script there might be a mistake in your code\n');
    end
end

function uniqueFileName = getUniqueFileName(baseFileName)
    numberSuffix = 1;
    uniqueFileName = baseFileName;

    while numberSuffix < 500 % Exit at 500 as a failsafe, just in case all files exist.
        if exist(fullfile('data', uniqueFileName + '.xls'), 'file')
            % Construct a new filename.
            uniqueFileName = baseFileName + "_nb_" + numberSuffix;
            % Prepare for next time, in case this name also existed.
            numberSuffix = numberSuffix + 1;
        else
            break; % Out of while loop
        end
    end
end

function global_param = updateGlobalParams(global_param, baseFileName, mean_reversals, EYE_TEST, AMB_EYE)
    if contains(baseFileName, '_cutoff_freq')
        global_param = updateGlobalParamForCutoff(global_param, mean_reversals, EYE_TEST, AMB_EYE);
    elseif contains(baseFileName, '_contrast_interleaved')
        global_param = updateGlobalParamForContrast(global_param, mean_reversals, EYE_TEST, AMB_EYE);
    elseif contains(baseFileName, '_binoc_orientation')
        global_param.binoc = mean_reversals;
    elseif contains(baseFileName, '_dichoptic')
        global_param.dichop = mean_reversals;
    elseif contains(baseFileName, '_asteroid')
        global_param.asteroid = mean_reversals;
    elseif contains(baseFileName, '_snellen_e_crowded') % must precede '_snellen_e'
        global_param = updateGlobalParamForCrowdedLogMAR(global_param, mean_reversals, EYE_TEST, AMB_EYE);
    elseif contains(baseFileName, '_snellen_e')
        global_param = updateGlobalParamForLogMAR(global_param, mean_reversals, EYE_TEST, AMB_EYE);
    else
        fprintf('Careful, if you received this message and you did not run the asteroid script there might be a mistake in your code\n');
    end
end

function global_param = updateGlobalParamForCutoff(global_param, mean_reversals, EYE_TEST, AMB_EYE)
    if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
        global_param.cut_off_AE = mean_reversals;
    elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
        global_param.cut_off_FE = mean_reversals;
    elseif contains(EYE_TEST, 'Both')
        global_param.cut_off_BE = mean_reversals;
    else
        global_param.cut_off = mean_reversals;
    end
end

function global_param = updateGlobalParamForContrast(global_param, mean_reversals, EYE_TEST, AMB_EYE)
    % The contrast test passes its mean-reversal table (see createMTTable.m).
    % Store the thresholds as a numeric row vector (one value per frequency,
    % in staircase order), the format used by the defaults in GetGlobalVariables.m.
    if istable(mean_reversals)
        mean_reversals = mean_reversals.MEAN(mean_reversals.Staircase > 0)';
    end
    if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
        global_param.contrast_AE = mean_reversals;
    elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
        global_param.contrast_FE = mean_reversals;
    elseif contains(EYE_TEST, 'Both')
        global_param.contrast_BE = mean_reversals;
    else
        global_param.contrast = mean_reversals;
    end
end

function global_param = updateGlobalParamForLogMAR(global_param, mean_reversals, EYE_TEST, AMB_EYE)
    if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
        global_param.logMAR_AE = mean_reversals;
    elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
        global_param.logMAR_FE = mean_reversals;
    elseif contains(EYE_TEST, 'Both')
        global_param.logMAR_BE = mean_reversals;
    else
        global_param.logMAR = mean_reversals;
    end
end

function global_param = updateGlobalParamForCrowdedLogMAR(global_param, mean_reversals, EYE_TEST, AMB_EYE)
    if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
        global_param.logMAR_AE_crowded = mean_reversals;
    elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
        global_param.logMAR_FE_crowded = mean_reversals;
    elseif contains(EYE_TEST, 'Both')
        global_param.logMAR_BE_crowded = mean_reversals;
    else
        global_param.logMAR_crowded = mean_reversals;
    end
end

