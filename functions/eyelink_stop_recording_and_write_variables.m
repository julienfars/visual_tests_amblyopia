function eyelink_stop_recording_and_write_variables(var_eye_link,trialCount, orientation, iSC)
    if contains(var_eye_link, 'true')  
           Eyelink('Message', 'BLANK_SCREEN');
           WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
           Eyelink('StopRecording'); % Stop tracker recording
           WaitSecs(0.5);
       %% EYELINK STEP 5.5: CREATE VARIABLES FOR DATAVIEWER; END TRIAL

        % Write !V TRIAL_VAR messages to EDF file: creates trial variables in DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Trial Message Commands
        Eyelink('Message', '!V TRIAL_VAR iteration %d', trialCount); % Trial iteration
        Eyelink('Message', '!V TRIAL_VAR orientation %d', orientation); % Image name
        %if exist("iSC", "var")
        %Eyelink('Message', '!V TRIAL_VAR freq %d', iSC); % Image name
        %end
        WaitSecs(0.001); % Allow some time between messages. Some messages can be lost if too many are written at the same time
        %Eyelink('Message', '!V TRIAL_VAR rt %d', rt); % Reaction time
        % Write TRIAL_RESULT message to EDF file: marks the end of a trial for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
        Eyelink('Message', 'TRIAL_RESULT 0');
        WaitSecs(0.01); % Allow some time before ending the trial
    end
end

