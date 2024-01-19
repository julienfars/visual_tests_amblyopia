%% Function to determine if it's a retest
function retest = getRetestInfo(global_param)
    % pop-up window 
    prompt_first = {'Is this a retest? [true/false]'}; % description of fields
    defaults_first = string(global_param.Retest); % default answer to this field
    answer_first = inputdlg(prompt_first, 'Parameters', 2, defaults_first); % opens dialog window
    retest = answer_first{1,:};
end
