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
                            Contrast Sensitivity
This test will be done AFTER the CUTOFF frequency task (CUTOFF frequency is used to set up the 6 conditions of the current task)
This test must be done on each eye individually and on the two eyes
binocularly. At the end we obtain 6x3 contrast thresholds:
- 6 thresholds for the Fellow Eye (FE) 
- 6 thresholds for the Amblyopic Eye (AE) 
- 6 thresholds for the Both Eyes (BE)

%}

% potential changes to make it more functional 
%{
- add training trials 
- add a CSf figure 
%}


%% Setup
sca;
commandwindow;
filepath=fileparts(which('Contrast_Interleaved.m'));
cd(filepath);
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% initialisation of eyelink
[dummymode, var_eye_link] = eyelink_init(1);

%% retrieve data from previous test 
New_patient = []; % set to empty as the battery of tests should not start by this test
global_param = initializeNewPatient(New_patient);

%% reduced version  
global_param = initializeReduced(global_param);

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'contrast_interleaved';

% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF] = getParticipantInfo(global_param, contrast_interleaved);

%% launch eyelink parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen stuff
% Call the function to set up screen parameters
[window, windowRect, width, height] = setupScreen();

%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)
[el] = eyelink_calibration(var_eye_link,window, stereoMode, [], width, height);

%% Other parameters
% Call the function to set up other parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect);

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test

eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters

% Call the function to set up basic Gabor parameters
[gaborDimPix, PixelPerDeg] = setupBasicGaborParameters(windowRect, global_param.screen_size, global_param.distance, global_param.stim_size);

%% Other Gabor Parameters 

[gabortex, aspectRatio, phase, contrast] = createGaborTexture(window, gaborDimPix, current_test);

%% Interleaved Staircases

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

sc_num_freqs = 3;
scRightRules = repelem(sc_num_freqs,num_freqs);
numStaircases   = numel(scRightRules);%scRightRules    = [3, 3, 3, 3, 3, 3]; 

    % these parameters control the staircase 
StimLevels      = log10(100):-0.00001:log10(1);     % stimulus levels from 1 to 100 (log) - which should provide around 60 steps 
initStepSize    = -0.6;     % staircase step size before first reversal
stepSize        = -0.4;     % staircase step size after first reversal - has more reversals (see staircase code)
nWrongToAscend  = 1;        % number of "incorrect" responses before ascending
nRightToDescend = 3;        % number of "correct" responses before descending
maxNumTrials    = 40;       % maximum number of trials for each staircase
maxNumReversals = 8;        % maximum number of reversals for staircase
startLevel      = log10(50);% starting level of staircase (50% should be manageable to begin with)
verbose         = 1;        % set to 1 for verbose staircase output


    for iSC = numStaircases:-1:1
        % number of "correct" responses before descending
        nRightToDescend = scRightRules(iSC);
        % class constructor function returns staircase object
        staircaseArray(iSC) = staircase(StimLevels, initStepSize, ...
                                        stepSize, nRightToDescend,   ...
                                        nWrongToAscend, maxNumTrials, ...
                                        maxNumReversals, startLevel, verbose);
    end
    

%% Result table
% the final results table is generated here (optimisation reasons)
% this table will be saved in the 'data' folder as an excel table for further analyses 
nb_table = numel(FREQS);
temps = createTable(maxNumTrials, nb_table, ["string", "datetime", "double", "double", "string", ...
    "string", "double", "double", "double", "double", "string", "string", "string", "double"], ...
    ["Task", "Date_time", "Trial", "Reversal", "AMB_eye", "Eye_tested", "Contrast", "Staircase",...
    "Frequency_dva", "Orientation", "Position", "Key", "Success", "RT"]);

%% creating the reversals table
mrt = createMRTTable(maxNumReversals, nb_table, 'interleaved');
counter_mrt = 1;

%% and the mean reversals only
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold
mt = createMTTable(nb_table, 'interleaved');

%% launch the experiment staircase
    counter_trial = 1;
    doubleScreen = false;      % this value will determine when to show the half cross (when set to 'true')
    while ~all([staircaseArray(:).isFinished])% keep looping until all staircases conclude
        
   % run the fixing cross before the trial
   [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress);

   % Randomisation
[angular, orientation] = randomizeOrientation();

    % select a random unfinished staircase
    iSC = randi(numStaircases);
    while staircaseArray(iSC).isFinished
        iSC = randi(numStaircases);
    end
        
    StimLevel = staircaseArray(iSC).curLevel;                   % testing level from staircase
    linStimLevel = (10^StimLevel);             % convert to linear units - let's try but I am not sure
    freq = FREQS(iSC);                         % match the randomly chosen staircase
    contrast = linStimLevel/100;               % /100 to get the percentage 0-1 = 0-100%
    sigma = gaborDimPix/6;                                % could be changed but 12 has the best visual effect 
    % make a properties matrix for the Gabor
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
    
%% Eyelink Start trial
eyelink_start_trial(var_eye_link, staircaseArray(iSC).trialCount, orientation, [])

 %% display the stim

drawGaborStimulus(window, gabortex, doubleScreen, xCenter, yCenter, angular, propertiesMat, gaborDimPix, diff, FF1b, FF1w, FF2b, FF2w);

% Flip to the screen
beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
Screen('Flip', window);

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% Wait for a button press

    onsetTime = GetSecs;
    [rt, value, key, temps, counter_trial] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc, temp, counter_trial);
    % add temps here!!!
    if contains(value, 'ESCAPE')
        break;
    end
    [mrt,counter_mrt] = calculateLastSixReversals(staircaseArray(iSC), temps, mrt, num_training, current_test, counter_mrt, contrast);
    [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(staircaseArray(iSC), temps, mrt, maxNumReversals, freq, Stim_position, EYE_TEST, AMB_EYE, current_test, counter_trial, mt);
    plotStaircaseValues(staircaseArray(iSC), temps, mean_reversals, []);

%% 'Wash' the display
   % after the stim was displayed, we wash the screen by displaying a
   % background colour surface on the stim area
   washDisplay(window, doubleScreen, windowRect, dstGab_center1, dstGab_center2, FF1b, FF1w, FF2b, FF2w);

   %% Stop the eyelink recording 
    WaitSecs(1);
       eyelink_stop_recording_and_write_variables(var_eye_link,staircaseArray(iSC).trialCount, orientation, [])

    end
%% eyelink - close the edf file
 newName = ['Contrast_Interleaved_', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);

 %% Clear screen
sca;

%% Results table
% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + date + '_contrast_interleaved';

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mt);

writetable(temps,filename)

fprintf('Output saved in: %s\n', filename)

%% ending the script

global_param.pix_shift = diff(1:2,1);
global_param.EYE_TEST = '?';

save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 

% end of the script 
