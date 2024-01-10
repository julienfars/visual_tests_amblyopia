function [status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName)
%% EYELINK STEP 6: CLOSE EDF FILE. TRANSFER EDF COPY TO DISPLAY PC. CLOSE EYELINK CONNECTION. FINISH UP
    if contains(var_eye_link, 'true')

    % Put tracker in idle/offline mode before closing file. Eyelink('SetOfflineMode') is recommended.
    Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
    WaitSecs(0.5); % Allow some time before closing and transferring file
    Eyelink('CloseFile'); % Close EDF file on Host PC
    % Transfer a copy of the EDF file to Display PC
    if dummymode ==0 % If connected to EyeLink
        % Show 'Receiving data file...' text until file transfer is complete
        Screen('FillRect', window, el.backgroundcolour); % Prepare background on backbuffer
        Screen('DrawText', window, 'Receiving data file...', 5, height-35, 0); % Prepare text
        Screen('Flip', window); % Present text
        fprintf('Receiving data file ''%s.edf''\n', edfFile); % Print some text in Matlab's Command Window
        
        % Transfer EDF file to Host PC
        % [status =] Eyelink('ReceiveFile',['src'], ['dest'], ['dest_is_path'])
        %status = Eyelink('ReceiveFile');
        % Optionally uncomment below to change edf file name when a copy is transferred to the Display PC
        % % If <src> is omitted, tracker will send last opened data file.
        % % If <dest> is omitted, creates local file with source file name.
        % % Else, creates file using <dest> as name.  If <dest_is_path> is supplied and non-zero
        % % uses source file name but adds <dest> as directory path.
        status = Eyelink('ReceiveFile', [], newName, 0);
        
        % Check if EDF file has been transferred successfully and print file size in Matlab's Command Window
        if status > 0
            fprintf('EDF file size: %.1f KB\n', status/1024); % Divide file size by 1024 to convert bytes to KB
        end
        % Print transferred EDF file path in Matlab's Command Window
        fprintf('Data file ''%s.edf'' can be found in ''%s''\n', edfFile, pwd);
    else
        fprintf('No EDF file saved in Dummy mode\n');
    end

    Eyelink('Shutdown'); % Close EyeLink connection
    %ListenChar(0); % Restore keyboard output to Matlab
    ShowCursor; % Restore mouse cursor
    else 
        status = [];
    end
end

