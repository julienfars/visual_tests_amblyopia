function eyelink_start_trial(var_eye_link, trialCount, orientation, iSC)
% EYELINK_START_TRIAL Initialize EyeLink recording and display trial information.

% Check if EyeLink is enabled
if contains(var_eye_link, 'true')
    % Write TRIALID message to EDF file: marks the start of a trial for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
    Eyelink('Message', 'TRIALID %d', trialCount);
    
    % Write !V CLEAR message to EDF file: creates a blank backdrop for DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
    Eyelink('Message', '!V CLEAR %d %d %d', 128, 128, 128); % Careful, had to hard code this part, Eyelink messages do not accept 0.5 (grey)
    
    % Supply the trial number as a line of text on the Host PC screen
    if isempty(iSC)
        Eyelink('Command', 'record_status_message "TRIAL %d %d"', trialCount, orientation)
    else
        Eyelink('Command', 'record_status_message "TRIAL %d %d %d"', iSC, trialCount, orientation)
    end
    
    Eyelink('SetOfflineMode'); % Put the tracker in idle/offline mode before drawing Host PC graphics and before recording
    Eyelink('Command', 'clear_screen 0'); % Clear the Host PC display from any previous drawing
    
    % See optional options in simplepicture code
    Eyelink('StartRecording'); % Start tracker recording
    WaitSecs(0.1); % Allow some time to record a few samples before presenting the first stimulus
end

end
