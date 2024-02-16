%% Modified getParticipantInfo function
function [SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test)

    % Common prompt and default values for both tests
    commonPrompt = {'Enter subject number:', 'Distance from screen (mm)', 'Which eye(s) is/are tested? (Left/Right/Both)', 'Which eye is amblyopic? (Left/Right)'};
    commonDefaults = {global_param.ID, num2str(global_param.distance), global_param.EYE_TEST, global_param.AMB_EYE};

    if contains(current_test, 'snellen') || contains(current_test, 'snellen_crowded')
        % Snellen-specific values
        commonPrompt = [commonPrompt {'EDF file name?'}];
        commonDefaults = {global_param.ID, num2str(global_param.distance_Snellen), global_param.EYE_TEST, global_param.AMB_EYE};
    else
        % Other test-specific values
        commonPrompt = [commonPrompt {'Stimuli size', 'EDF file name?'}];
        commonDefaults = [commonDefaults {num2str(global_param.stim_size), strcat(global_param.ID, current_test)}];
    end

    % Prompt user for input
    answer = inputdlg(commonPrompt, 'Parameters', 2, commonDefaults);
    % Extract values from the user input
    SUBJECT = answer{1, :};
    DISTANCE = str2double(answer{2, :});
    EYE_TEST = answer{3, :};
    AMB_EYE = answer{4, :};

    if contains(current_test, 'snellen') || contains(current_test, 'snellen_crowded')
        edfFile = answer{end, :};
    else
        SIZE = answer{5, :};
        edfFile = answer{end, :};
    end
    
    % Initialize other variables
    FREQS_test = [];
    CUTOFF = [];
    NOISE = [];
    CONTRAST = [];

    % If the participant is strabismic, set up the fixation cross task before the trials
    fixCross = contains(EYE_TEST, 'Both');

    % Additional parameters for the modified code (conditionally set)
    if contains(current_test, 'contrast_interleaved')
        prompt_additional = {'Frequencies shorted list (change it if needed, must be [0:1])', 'Cut-off frequency'};
        defaults_additional = {num2str(global_param.freqs), '-'};
        answer_additional = inputdlg(prompt_additional, 'Additional Parameters', 2, defaults_additional); % Opens dialog window
        FREQS_test = str2num(answer_additional{1, :});
        CUTOFF = answer_additional{2, :};
        % Conditionally set CUTOFF based on the eye and amblyopic status
        if contains(CUTOFF, '-')
            if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
                CUTOFF = global_param.cut_off_AE;
            elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
                CUTOFF = global_param.cut_off_FE;
            elseif contains(EYE_TEST, 'Both')
                CUTOFF = global_param.cut_off_BE;
            else
                CUTOFF = global_param.cut_off;
            end
            if ~isnumeric(CUTOFF)
                CUTOFF = str2double(CUTOFF);
            end
        else
            if ~isnumeric(CUTOFF)
                CUTOFF = str2double(CUTOFF);
            end
        end
        
    elseif contains(current_test, 'interocular_imbalance')
        CUTOFF = [];
        prompt_additional = {'Frequencies list (change it if needed, must be [0:1])', 'normal observer? [yes=1/no=0]'};
        defaults_additional = {'0.5 1 2 4', '0'};
        answer_additional = inputdlg(prompt_additional, 'Additional Parameters', 2, defaults_additional); % Opens dialog window
        FREQS_test = str2num(answer_additional{1, :});
        global_param.binoc_normal_testing = str2num(answer_additional{2, :});

    elseif contains(current_test, 'dichoptic')
        prompt_additional = {'Noise Contrast [0:1]', 'Contrast Gabor [0:1]', 'Cut-off frequency'};
        defaults_additional = {global_param.dichop, global_param.contrast_AE(3), '-'};
        answer_additional = inputdlg(prompt_additional, 'Additional Parameters', 2, defaults_additional); % Opens dialog window
        NOISE = str2num(answer_additional{1, :});
        CONTRAST = str2double(answer_additional{2, :});

        % Conditionally set CUTOFF based on the eye and amblyopic status
        CUTOFF = answer_additional{3, :};
        if contains(CUTOFF, '-')
            if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
                CUTOFF = global_param.cut_off_AE;
            elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
                CUTOFF = global_param.cut_off_FE;
            elseif contains(EYE_TEST, 'Both')
                CUTOFF = global_param.cut_off_BE;
            else
                CUTOFF = global_param.cut_off;
            end
        end
    end
end
