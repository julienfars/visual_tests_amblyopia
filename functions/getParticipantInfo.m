%% Function to get participant information
function [SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross] = getParticipantInfo(global_param)
    % pop-up window
    prompt = {'Enter subject number:', 'Stimuli size', 'Distance from screen (mm)', 'Which eye(s) is/are tested? (Left/Right/Both)', 'Which eye is amblyopic? (Left/Right)', 'EDF file name?'};
    defaults = {global_param.ID, num2str(global_param.stim_size), num2str(global_param.distance), global_param.EYE_TEST, global_param.AMB_EYE, strcat(global_param.ID,'co')};
    answer = inputdlg(prompt, 'Parameters', 2, defaults); % opens dialog window
    SUBJECT = answer{1,:};
    SIZE = str2double(answer{2,:});
    DISTANCE = str2double(answer{3,:});
    EYE_TEST = answer{4,:};
    AMB_EYE = answer{5,:};
    edfFile = answer{6,:};

    if contains(EYE_TEST, 'Both') % if the participant is strabismic, then we set up the fixation cross task before the trials
        fixCross = true;
    else
        fixCross = false;
    end
end