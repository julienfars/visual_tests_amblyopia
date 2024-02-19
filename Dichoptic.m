
%%% FIX THE MOVING TARGETS!!!
% 
% 
% 
% 
% 
% 
% 
% 
% 

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
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);
global_param.ID = SUBJECT; % records the participant's ID in the global_param structure 
global_param.AMB_EYE = AMB_EYE; % records the participant's amblyopic eye in the global_param structure 
global_param.EYE_TEST = EYE_TEST; % records the participant's tested eye in the global_param structure 

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
[el] = eyelink_calibration(var_eye_link,window, stereo, [], width, height);

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
maxNumTrials    = 40;       % maximum number of trials for staircase (50 without the training)
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
    "Frequency", "Orientation", "Noise", "Position", "Key", "Success", "RT"] ); 

%% Mean reversals table 
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold
mrt = createMRTTable(maxNumReversals, nb_table, 'simple');

 %% Start the experiment 

 repeatNoise = false; % used for repeating the same noise when having attention trial (UP/DOWN)
 att_test = 0; % counter for the numbers of attention tests failed 
 doubleScreen = false;
 counter_trial = 0;
 num_training = 0;
    % will determine which side of the crosses will be moving (along with one copy of the fusion frame)
    if contains(AMB_EYE, 'Left') 
            HC1 = HCl;
            HC2 = HCr;
            FF1w = FFLw;
            FF1b = FFLb;
            FF2w = FFRw;
            FF2b = FFRb;
        else
            HC1 = HCr;
            HC2 = HCl;
            FF1w = FFRw;
            FF1b = FFRb;
            FF2w = FFLw;
            FF2b = FFLb;
    end

diff = zeros(4,1);
rectColor = [1 1 1];

while ~sc.isFinished           % keep looping until staircase concludes
    
% run the fixing cross before the trial
   [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
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
    texSize = 252; %size in pixels, was 240
    noise = bandpass_noise_maker(252,5.5,240); % was 240,5.5,240
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
    [ARROWLT, ARROWRT, ARROWLB, ARROWRB, penWidthPixels] = setupPrimerCoordinates(HC1, HC2);

    %% Eyelink Start trial
eyelink_start_trial(var_eye_link, sc.trialCount, orientation, [])

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

    
%% Trials 
    if contains(ATT_TRIAL, 'false')
    [repeatNoise] = drawGratings_dichoptic(window, black, ARROWLT, ...
    ARROWRT, ARROWLB, ARROWRB, penWidthPixels, rectColor, HC1, ...
    waitTime, sinetex, allRects, orientation, propertiesMat, ...
    texSize, xCenter, yCenter, bgcontrast, fgcontrast, ...
    noiseTexture, AMB_EYE);
 
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

    onsetTime = GetSecs;
    time_presentation_function(windowRect, window, gaborDimPix, xCenter, yCenter, diff, black, white, FF1b, FF1w, FF2b, FF2w, ...
        current_test, false, 0.2, AMB_EYE, bgcontrast)
    Screen('Flip', window);

    % Wait for a button press
    [rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey, repeatNoise, ...
        sc, temps, counter_trial, acc_resp, current_test, fixCross, HC1, HC2, att_test); 
    temps(counter_trial,:) = {current_test, datetime('now'), sc.trialCount, sc.revCount, AMB_EYE, EYE_TEST, contrast_low, contrast_high, propertiesMat(1,2), orientation, NOISE, Stim_position, key, value, rt}; 
    if contains(value, 'ESCAPE')
        mean_reversals = 0;
        break;
    end
    [mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, [], NOISE, [], [], []);
    if sc.isFinished
        [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, mrt, maxNumReversals, NOISE, Stim_position, ...
            EYE_TEST, AMB_EYE, current_test, counter_trial, mt, iSC, []);
    else 
       mean_reversals = 0;
    end
    plotStaircaseValues(sc, temps, mean_reversals, [], NOISE, current_test, [], [], []);
   if contains(var_eye_link, 'true')  
           Eyelink('Message', 'BLANK_SCREEN');
           WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
           Eyelink('StopRecording'); % Stop tracker recording
   end
end
Priority(0);

%% eyelink - close the edf file
 newName = ['Dichoptic_', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
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