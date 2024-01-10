function eyelink_start_trial(var_eye_link, trialCount, orientation, iSC)
%EYELINK_STAR_TRIAL Summary of this function goes here
%   Detailed explanation goes here
%% EYELINK - START TRIAL; SHOW TRIAL INFO ON HOST PC; SHOW BACKDROP IMAGE AND/OR DRAW FEEDBACK GRAPHICS ON HOST PC; DRIFT-CHECK/CORRECTION
        if contains(var_eye_link, 'true')
        % Write TRIALID message to EDF file: marks the start of a trial for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
        Eyelink('Message', 'TRIALID %d', trialCount);
        % Write !V CLEAR message to EDF file: creates blank backdrop for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
        Eyelink('Message', '!V CLEAR %d %d %d', 128, 128, 128); % careful, had to hard code this part, eyelink message do not accept 0.5 (=grey)%el.backgroundcolour(1), el.backgroundcolour(2), el.backgroundcolour(3));
        % Supply the trial number as a line of text on Host PC screen
        if isempty(iSC)
        Eyelink('Command', 'record_status_message "TRIAL %d %d"', trialCount, orientation)
        else 
            Eyelink('Command', 'record_status_message "TRIAL %d %d %d"',iSC, trialCount, orientation)
        end
        Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before drawing Host PC graphics and before recording        
        Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
%see optional options in simplepicture code

        Eyelink('StartRecording'); % Start tracker recording
        WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus
        end
end

