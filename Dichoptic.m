%{
Welcome to the Amblyopia Study Test Battery.

This script conducts a series of visual tests to assess various aspects of the amblyopic visual experience. 
If you have questions, contact Juju (julien.fars@ndcn.ox.ac.uk).

Note: Adjust parameters in the GetGlobalVariables.m script before running the tests.

This battery utilizes modified scripts from different researchers:
- Alex S Baldwin (Staircase protocol)
- Jun-Yun Zhang (Dichoptic test)
- Alice Grasso McCaslin (Asteroid test script)

Inspired by Peter Scarfe's work (https://peterscarfe.com/ptbtutorials.html).
%}

%{
                            Dichoptic test 
Here is an attempt on making a new version (homemade) of the dichoptic
demasking. Because it seems that all the codes I got are not flexible. 
Attempt 1: Must find the code for the noise but the rest only concerns 
gabors and fixation cross (+ an attention square at the beginning of each trial)
01/03/2023 

Test only done on both eyes 
%}

%% Setup
% first we setup the screen, the workspace and the command window

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
retest = getRetestInfo(global_param); % popup window that control if this is a retest or not

global_param = initializeNewPatient(New_patient); % if new patient is true then the parameters are initialised. If not, we retrieve the previous parameters 

% Set retest variable
global_param.Retest = contains(retest, 'true');

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'dichoptic';
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);
%global_param.EYE_TEST = EYE_TEST; % records the participant's tested eye in the global_param structure 

%% Eyelink Parameters

[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen Parameters

[window, windowRect, width, height] = setupScreen(101);

bgcontrast = 0.1;

Screen('SelectStereoDrawBuffer',window,0);
Screen('ColorRange', window, 1, 0);
Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast]); 

Screen('SelectStereoDrawBuffer',window,1);
Screen('ColorRange', window, 1, 0);
Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast]); %bgcontrast


%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)

[el] = eyelink_calibration(var_eye_link,window, stereoMode, [], width, height);

%% Other Parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect);

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test

eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
% will start if the participant has starbismus AND is testing BE 

[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Grating parameters

[gaborDimPix, PixelPerDeg, size_stim_pix, FREQS] = setupBasicGaborParameters(windowRect, global_param.screen_size, global_param.distance, global_param.stim_size);
[sinetex, phase, freq, tilt, contrast_high, contrast_low] = createGratingTexture(window, gaborDimPix, CUTOFF, CONTRAST, global_param.dichop_contrast_high, global_param.dichop_contrast_low);

nGabors = 2; % number of gratings on display
[allRects, propertiesMat] = setupGratingsParameters(xCenter, yCenter, gaborDimPix, nGabors, phase, freq, contrast_high);

% we draw the grating already but do not display it (efficient coding)
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
temps = createTable(maxNumTrials, nb_table, ["string", "datetime", "double", "string", "string",...
    "double", "double", "double" "double", "double", "double", "string", "string", "string", "double"], ...
    ["Task", "Date_time", "Trial", "Staircase", "AMB_eye", "Eye_tested", "Contrast_low", "Contrast_high",...
    "Frequency_dva", "Orientation", "Noise", "Position", "Key", "Success", "RT"] ); 

%% Mean reversals table 
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold
mrt = createMRTTable(maxNumReversals, nb_table, 'simple');

 %% Start the experiment 

 repeatNoise = false; % used for repeating the same noise when having attention trial (UP/DOWN)
 att_test = 0; % counter for the numbers of attention tests failed 
 doubleScreen = false;
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
   [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff] = fix_cross(fixCross,window, start_trial_key, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE, HC1,HC2, FF1w, FF1b, FF2w, FF2b,HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, black, white, ifi);

    StimLevel = sc.curLevel;                   % testing level from staircase
    linStimLevel = (10^StimLevel);             % convert to linear units - let's try but I am not sure
    
    if repeatNoise % used for repeating the same noise when having attention trial (UP/DOWN)
        NOISE = repNOISE; % repeat the same noise level
        fgcontrast = NOISE;
    else
        NOISE = linStimLevel/100; % go on with the newly calculated noise
        fgcontrast = NOISE;
    end
    
    % here the code to generate the noise 
    texSize = 252; %size in pixels, was 240
    %texSize = 4.4 * size_dva; % would be too small 
    %x = meshgrid(-texSize/2+1:texSize/2, -texSize/2+1:texSize/2);
    
    noise = bandpass_noise_maker(252,5.5,240); % was 240,5.5,240
%{
    for i=1:texSize+1
            for j=1:texSize+1
                if noise(i,j)>1
                    noise(i,j)=1;end
                if noise(i,j)<-1
                    noise(i,j)=-1;end
            end
    end
%}

    smoothedNoise = noise*NOISE; % careful
    noiseTexture = Screen('MakeTexture', window, smoothedNoise, [], [], 1);
    
    %% other parameters
    [seed,whichGen] = ClockRandSeed();

    EccH=420;
    centerHsti=round(windowRect(3))/2-EccH;
    waitTime = 0.2; % the time of presentation (200ms)

%% Arrows
    [UP_side, DOWN_side, isConvex] = setupArrows(xCenter, yCenter, 240); % 240 is the size of the arrows in pixel 

%% Randomisers 
    [orientation, propertiesMat, ARROW_X, ARROW_Y, acc_resp, ...
    ATT_TRIAL] = setupDichopticRandomisers(contrast_low, contrast_high, ...
    xPosVectorUP, yPosVectorUP, xPosVectorDOWN, yPosVectorDOWN, ...
    propertiesMat);
   
%% Primer coordinates 
    [ARROWLT, ARROWRT, ARROWLB, ARROWRB, penWidthPixels] = setupPrimerCoordinates(HC1);

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
    noiseTexture, ARROW_X, ARROW_Y, isConvex, white);

    end

    % Flip to the screen
     % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);

    
%% Wait for a button press

    onsetTime = GetSecs;
    time_presentation_function(window, gaborDimPix, xCenter, yCenter, diff, black, white, FF1b, FF1w, FF2b, FF2w, current_test, false, 0.2)
    Screen('Flip', window);

    % Wait for a button press
    [rt, value, key, temps, counter_trial] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc, temps, counter_trial); 
    if contains(value, 'ESCAPE')
        break;
    end
    [mrt,counter_mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, counter_mrt, NOISE, []);
    [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, ...
    mrt, maxNumReversals, NOISE, Stim_position, EYE_TEST, AMB_EYE, ...
    current_test, counter_trial, mt, iSC, FREQS_test);
    plotStaircaseValues(sc, temps, mean_reversals, iSC, NOISE, current_test, [], contrast);
     
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