%% Dichoptic De-Masking script
% This test measures how much visual noise the Fellow Eye (FE) can tolerate 
% while still allowing the detection of contrast differences in the Amblyopic Eye (AE).
% The paradigm is based on the work of Liu et al. [see refs in README] and assesses noise tolerance 
% in adults with amblyopia. 

% Procedure Overview:
% - The test uses passive 3D glasses for dichoptic presentation.
% - Participants initiate the trial using the controller once the fusion cross is stable.
% - A primer (200 ms) directs attention to the AE.
% - Two gratings (one above the other) and a noise masker are presented in AE and FE respectively for 200 ms.
% - Participants indicate which grating had the higher contrast (up or down).

% Grating Properties:
% - One grating has a 50% contrast and the other 10%.
% - Both gratings share a spatial frequency equivalent to 40% of the AE's threshold 
%   obtained in the cut-off experiment.
% - Grating size: 2x2 degrees of visual angle (dva).
% - Grating separation: 2 dva (center-to-center).

% Noise Masker:
% - Size: 10 dva.
% - Generated using a salt-and-pepper white noise function.
% - Smoothed using a Gaussian filter with a standard deviation matching the grating spatial frequency.

% Staircase Procedure:
% - Follows a 3-up-1-down staircase method (only Noise contrast changes).
% - Step sizes are 0.05 log units after the fourth reversal.
% - The test concludes after 40 trials or 8 reversals.
% - Maximum tolerable noise contrast is calculated as the mean noise contrast of the last 6 reversals.

% Additional Considerations:
% - To prevent FE suppression, 20% of trials include a central white arrow (1.5 x 1.5 dva) 
%   within the noise masker in the FE.
% - In these trials, participants must indicate the arrow's direction (up or down) using the controller.

%% Setup
sca; % to clean the workspace
commandwindow; % to open the command window
filepath=fileparts(which('Dichoptic.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths (to save the files at the end of the test)
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% initialisation of eyelink
% then we initialise the eye link
[dummymode, var_eye_link] = eyelink_init(1); % will return variables that indicates that the eye link is ready to start (dummymode, var_eye_link)

%% Same patient? Retest? 
% This battery of test will be performed thrice on the same session (FE, AE and BE)
% And thrice for each participant (training, test and retest)
New_patient = getNewPatientInfo(); % popup window that control if this is a new participant 
global_param = initializeNewPatient(New_patient); % if new patient is true then the parameters are initialised. If not, we retrieve the previous parameters 
retest = getRetestInfo(global_param); % popup window that control if this is a retest or not
global_param.Retest = contains(retest, 'true');% Set retest variable

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'dichoptic';
global_param.EYE_TEST = 'Both';
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);
[global_param.ID, global_param.AMB_EYE, global_param.EYE_TEST] = deal(SUBJECT, AMB_EYE, EYE_TEST);

%% Eyelink Parameters

[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen Parameters
debug = 0;
stereo = 100; % is supposed to be 100 when using display++
[window, windowRect, width, height, black, white] = setupScreen(stereo, debug);
bgcontrast = 0.1;
Screen('SelectStereoDrawBuffer',window,0);
Screen('ColorRange', window, 1, 0);
Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast]); 
Screen('SelectStereoDrawBuffer',window,1);
Screen('ColorRange', window, 1, 0);
Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast]); %bgcontrast

%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)
[el] = eyelink_calibration(var_eye_link,window, stereo, 'dich', width, height);

%% Other Parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect);

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test

eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
% will start if the participant has starbismus AND is testing BE 

[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, global_param, fixCross, stereo); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Grating parameters

[gaborDimPix, PixelPerDeg] = setupBasicGaborParameters(windowRect, global_param.screen_size, global_param.distance, global_param.stim_size, [], current_test);
[sinetex, phase, freq, tilt, contrast_high, contrast_low] = createGratingTexture(window, gaborDimPix, CUTOFF, CONTRAST, global_param.dichop_contrast_high, global_param.dichop_contrast_low);
nGabors = 2; % number of gratings on display
[allRects, propertiesMat] = setupGratingsParameters(xCenter, yCenter, gaborDimPix, nGabors, phase, freq, contrast_high); % we draw the grating already but do not display it (efficient coding)
Screen('DrawTexture', window, sinetex, [], [], tilt, [], [], [], [], [], [0,1,0,0]);
Priority(MaxPriority(window));

%% Staircases 
% Query the frame duration
ifi = Screen('GetFlipInterval', window);
% these parameters control the staircase (change it to remove the extra stepSizes)
StimLevels      = log10(1):0.00001:log10(100);     % stimulus levels from 1 to 50 (log) - which should provide around 30 steps 
initStepSize    = 0.4;      % staircase step size before first reversal
stepSize        = 0.2;      % staircase step size after first reversal - has more reversals (see staircase code)
nRightToDescend = 3;        % number of "correct" responses before ascending
nWrongToAscend  = 1;        % number of "incorrect" responses before descending
maxNumTrials    = 100;       % maximum number of trials for staircase (50 without the training)
maxNumReversals = 8;       % maximum number of reversals for staircase
startLevel      = log10(50);%log10(20);%log10(NOISE*100);        % starting level of staircase (5 should be easy to begin with)
verbose         = 1;        % set to 1 for verbose staircase output
% class constructor function returns staircase object (see staircase.m)
sc = staircase(StimLevels, initStepSize, stepSize,         ...
               nRightToDescend, nWrongToAscend, maxNumTrials, ...
               maxNumReversals, startLevel, verbose);

%% Result table
% the final results table is generated here (optimisation reasons)
% this table will be saved in the 'data' folder as an excel table for further analyses 
nb_table = 1;
temps = createTable(maxNumTrials, nb_table, ["string", "datetime", "double", "double", "string", "string",...
    "double", "double", "double" "double", "double", "string", "string", "string", "double"], ...
    ["Task", "Date_time", "Trial","Reversal", "AMB_eye", "Eye_tested", "Contrast_low", "Contrast_high",...
    "Frequency_cpp", "Orientation", "Noise", "Position", "Key", "Success", "RT"] ); 

%% Mean reversals table 
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold
mrt = createMRTTable(maxNumReversals, nb_table, 'simple');

 %% Start the experiment 

 repeatNoise = false; % used for repeating the same noise when having attention trial (UP/DOWN)
 att_test = 0; % counter for the numbers of attention tests failed 
 [HC1, HC2, FF1w, FF1b, FF2w, FF2b] = resetCross(AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb);
 doubleScreen = false;
 counter_trial = 0;
 num_training = 0;
  
diff = zeros(4,1);
rectColor = [1 1 1];

while ~sc.isFinished           % keep looping until staircase concludes
    
% run the fixing cross before the trial
   [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE,  EYE_TEST, HC1,HC2, FF1w, FF1b, FF2w, FF2b,HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, black, white, ifi, current_test);

    StimLevel = sc.curLevel;                   % testing level from staircase
    linStimLevel = (10^StimLevel);             % convert to linear units - let's try but I am not sure
    
    if repeatNoise % used for repeating the same noise when having attention trial (UP/DOWN)
        NOISE = NOISE; % repeat the same noise level
        fgcontrast = NOISE;
    else
        NOISE = linStimLevel/100; % go on with the newly calculated noise
        fgcontrast = NOISE;
    end
    
    % here the code to generate the noise 
    texSize = 512; %size in pixels, was 240
    noise = bandpass_noise_maker(512,5.5,240); % was 240,5.5,240
    smoothedNoise = noise*NOISE; % careful
    noiseTexture = Screen('MakeTexture', window, smoothedNoise, [], [], 1);
    
    %% other parameters
    %[seed,whichGen] = ClockRandSeed();
    %EccH=420;
    %centerHsti=round(windowRect(3))/2-EccH;
    waitTime = 0.2; % the time of presentation (200ms)

%% Arrows
    [UP_side, DOWN_side, isConvex, xPosVectorUP, yPosVectorUP, xPosVectorDOWN, yPosVectorDOWN] = setupArrows(xCenter, yCenter, 240); % 240 is the size of the arrows in pixel 

%% Randomisers 
    [orientation, propertiesMat, ARROW_X, ARROW_Y, acc_resp, ...
    ATT_TRIAL] = setupDichopticRandomisers(contrast_low, contrast_high, ...
    xPosVectorUP, yPosVectorUP, xPosVectorDOWN, yPosVectorDOWN, ...
    propertiesMat);
   
%% Primer coordinates 
if contains(AMB_EYE, 'Left')
    HCa = HC1;
    HCb = HC2;
else 
    HCa = HC2;
    HCb = HC1;
end
    [ARROWLT, ARROWRT, ARROWLB, ARROWRB, penWidthPixels] = setupPrimerCoordinates(HCa, HCb);

    %% Eyelink Start trial
eyelink_start_trial(var_eye_link, sc.trialCount, orientation, [])

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

    
%% Trials 
    if contains(ATT_TRIAL, 'false')
    [repeatNoise] = drawGratings_dichoptic(window, black, ARROWLT, ...
    ARROWRT, ARROWLB, ARROWRB, penWidthPixels, rectColor, HC1, ...
    waitTime, sinetex, allRects, 0, propertiesMat, ... # orientation at the spot of 0
    texSize, xCenter, yCenter, bgcontrast, fgcontrast, ...
    noiseTexture, AMB_EYE, diff);
 
    elseif  contains(ATT_TRIAL, 'true')
    [repeatNoise] = drawAttentionCue(window, black, ARROWLT, ...
    ARROWRT, ARROWLB, ARROWRB, penWidthPixels, rectColor, HC1, ...
    waitTime, texSize, xCenter, yCenter, bgcontrast, fgcontrast, ...
    noiseTexture, ARROW_X, ARROW_Y, isConvex, white, AMB_EYE);
    end

    % Flip to the screen
     % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);

    
%% Wait for a button press

    time_presentation_function(windowRect, window, gaborDimPix, xCenter, yCenter, diff, black, white, FF1b, FF1w, FF2b, FF2w, ...
        current_test, false, 0.2, AMB_EYE, bgcontrast)
    Screen('Flip', window);

        onsetTime = GetSecs;

    % Wait for a button press
    [rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, repeatNoise, ...
        sc, temps, counter_trial, acc_resp, current_test, fixCross, HC1, HC2, att_test); 
    temps(counter_trial,:) = {current_test, datetime('now'), sc.trialCount, sc.revCount, AMB_EYE, EYE_TEST, contrast_low, contrast_high, propertiesMat(1,2)*gaborDimPix, orientation, NOISE, Stim_position, key, value, rt}; 
    if contains(value, 'ESCAPE')
        mean_reversals = 0;
        break;
    end
    [mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, [], NOISE, [], [], []);
    if sc.isFinished
        [mean_reversals, success_reversal] = calculateMeanReversals(sc,mrt, maxNumReversals, NOISE, current_test, [], [], []);
        temps(sc.trialCount + 1, :) = {current_test, datetime('now'), sc.trialCount + 1, sc.revCount, 'MEAN', 'REVERSAL', contrast_low, contrast_high, propertiesMat(1,2)*gaborDimPix, 0, mean_reversals, Stim_position, success_reversal, 'end_of_table', 0};
    else 
        mean_reversals = 0;
    end
    plotStaircaseValues(sc, temps, mean_reversals, [], NOISE, current_test, [], [], []);
    
   if contains(var_eye_link, 'true')  
           Eyelink('Message', 'BLANK_SCREEN');
           WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
           Eyelink('StopRecording'); % Stop tracker recording
   end
   WaitSecs(1);

end
Priority(0);

%% eyelink - close the edf file
 newName = ['Dichoptic_', global_param.ID, '_', EYE_TEST, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);


%% Clear screen
sca;

%% Results table
% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + date + '_dichoptic';

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);

writetable(temps,filename)

fprintf('Output saved in: %s\n', filename)

%% ending the script
global_param.dichop = NOISE; 
global_param.dichop_contrast_high = contrast_high;
global_param.dichop_contrast_low = contrast_low;

save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 

% end of the script 