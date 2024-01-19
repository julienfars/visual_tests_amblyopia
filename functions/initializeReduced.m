function global_param = initializeReduced(global_param)
    % Initialize parameters for the experiment

    % Ask if this is a new patient
    prompt_first = {'Do the reduced version? [true/false]'}; % Description of fields
    defaults_first = {'false'};
    answer_first = inputdlg(prompt_first, 'Parameters', 2, defaults_first); % Opens dialog
    reduced = answer_first{1,:};

    % Check if it's a reduced version
    if contains(reduced, 'true')
        % Ask for frequencies shorted list
        prompt_second = {'Frequencies shorted list (change it if needed, must be [0:1])'}; % Description of fields
        defaults_second = {'0.125 0.25 0.5 0.75'};
        answer_second = inputdlg(prompt_second, 'Parameters', 2, defaults_second); % Opens dialog
        FREQS_test = answer_second{1,:};

        % Set global parameters for reduced version
        global_param.reduced = true;
        global_param.freqs = str2num(FREQS_test);
    else
        FREQS_test = '0.0625 0.125 0.25 0.5 0.75 1';
        global_param.reduced = false;
        global_param.freqs = str2num(FREQS_test);
    end
end