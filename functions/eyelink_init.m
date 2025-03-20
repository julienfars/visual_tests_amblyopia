function [dummymode, var_eye_link] = eyelink_init(init_eyelink)
% EYELINK_INIT Initialize EyeLink connection or run in Dummy Mode.

% Ask if the experimenter wants to start the EyeLink
if init_eyelink
    prompt_eye_link = {'Do you want to start the EyeLink?'}; % Description of fields
    defaults_eye_link = {'true'};
    answer_eye_link = inputdlg(prompt_eye_link, 'Parameters', 2, defaults_eye_link); % Opens dialog
    var_eye_link = answer_eye_link{1, :};

    if contains(var_eye_link, 'true')
        % Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
        dummymode = 0;

        % Optional: Set IP address of EyeLink tracker computer to connect to.
        % Call this before initializing an EyeLink connection if you want to use a non-default IP address for the Host PC.
        %Eyelink('SetAddress', '10.10.10.240');

        EyelinkInit(dummymode); % Initialize EyeLink connection
        status = Eyelink('IsConnected');
        if status < 1 % If EyeLink not connected
            dummymode = 1;
        end
    else
        dummymode = [];
        var_eye_link = 'false';
    end
else
    dummymode = [];
    var_eye_link = 'false';
end

end


