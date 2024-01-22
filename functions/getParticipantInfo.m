%% Modified getParticipantInfo function
function [SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test)
    % Pop-up window
    prompt = {'Enter subject number:', 'Stimuli size', 'Distance from screen (mm)', 'Which eye(s) is/are tested? (Left/Right/Both)', 'Which eye is amblyopic? (Left/Right)', 'EDF file name?'};
    defaults = {global_param.ID, num2str(global_param.stim_size), num2str(global_param.distance), global_param.EYE_TEST, global_param.AMB_EYE, strcat(global_param.ID,current_test)};
    answer = inputdlg(prompt, 'Parameters', 2, defaults); % Opens dialog window
    SUBJECT = answer{1,:};
    SIZE = str2double(answer{2,:});
    DISTANCE = str2double(answer{3,:});
    EYE_TEST = answer{4,:};
    AMB_EYE = answer{5,:};
    edfFile = answer{6,:};

    % If the participant is strabismic, set up the fixation cross task before the trials
    if contains(EYE_TEST, 'Both')
        fixCross = true;
    else
        fixCross = false;
    end

    % Additional parameters for the modified code (conditionally set)
    if contains(current_test, 'contrast_interleaved')
        prompt_additional = {'Frequencies shorted list (change it if needed, must be [0:1])', 'Cut-off frequency'};
        defaults_additional = {'0.125 0.25 0.5 0.75', '-'};
        answer_additional = inputdlg(prompt_additional, 'Additional Parameters', 2, defaults_additional); % Opens dialog window
        FREQS_test = answer_additional{1,:};
        CUTOFF = answer_additional{2,:};

        % Convert text into numericals
        FREQS_test = str2num(FREQS_test);
        if contains(CUTOFF, '-')
            % Conditionally set CUTOFF based on the eye and amblyopic status
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
        CUTOFF = str2double(CUTOFF);

    elseif contains(current_test, 'interocular_imbalance')
        CUTOFF = [];
        prompt_additional = {'Frequencies list (change it if needed, must be [0:1])', 'normal observer? [yes/no]'};
        defaults_additional = {'0.5 1 2 4', 'no'};
        answer_additional = inputdlg(prompt_additional, 'Additional Parameters', 2, defaults_additional); % Opens dialog window
        FREQS_test = answer_additional{1,:};
        global_param.binoc_normal_testing = answer_additional{2,:};

        % Convert text into numericals
        FREQS_test = str2num(FREQS_test);

    elseif contains(current_test, 'dichoptic')
        prompt_additional = {'Noise Contrast [0:1]', 'Contrast Gabor [0:1]', 'Cut-off frequency'};
        defaults_additional = {'0.1', global_param.contrast_AE(3), '-'};
        answer_additional = inputdlg(prompt_additional, 'Additional Parameters', 2, defaults_additional); % Opens dialog window
        NOISE = answer_additional{1,:};
        CONTRAST = answer_additional{2,:};
        CUTOFF = answer_additional{3,:};

        % Convert text into numerical
        NOISE = str2num(NOISE);

        if contains(CUTOFF, '-')
            % Conditionally set CUTOFF based on the eye and amblyopic status
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
        CUTOFF = str2double(CUTOFF);
    end
end