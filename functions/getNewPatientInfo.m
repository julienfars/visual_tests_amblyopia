%% Function to get new patient information
function New_patient = getNewPatientInfo()
    % pop-up window
    prompt_second = {'Is this a new patient? [true/false]'}; % description of fields
    defaults_second = {'false'};
    answer_second = inputdlg(prompt_second, 'Parameters', 2, defaults_second); % opens dialog window
    New_patient = answer_second{1,:};
end
