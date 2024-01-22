function global_param = initializeNewPatient(New_patient)
    % This function initializes the global_param structure based on the
    % input parameter New_patient.

    if contains(New_patient, 'true')
        global_param = GetGlobalVariables(); % Set up a 'brand new' "global_param" structure file
    else
        if isfile("data/Global_parameters/global_param.mat")
            load("data/Global_parameters/global_param.mat");
        else
            global_param = GetGlobalVariables();
        end
    end
end