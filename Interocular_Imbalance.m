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

%changes to make it functional 
%{
- add training trials? 
%}

%% Setup
sca;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Interocular_Imbalance.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths 
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% Eyelink Initialization
[dummymode, var_eye_link] = eyelink_init(1);

%% retrieve data from previous test

New_patient = getNewPatientInfo(); % popup window that control if this is a new participant 
retest = getRetestInfo(global_param); % popup window that control if this is a retest or not

New_patient = []; % set to empty as the battery of tests should not start by this test
global_param = initializeNewPatient(New_patient);

% Set retest variable
global_param.Retest = contains(retest, 'true');

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'interocular_imbalance';

% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, global_param] = getParticipantInfo(global_param, current_test);
normal_testing = global_param.binoc_normal_testing;
num_freqs = numel(FREQS_test); 

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
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect)

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test

eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters

% Call the function to set up basic Gabor parameters
[gaborDimPix, PixelPerDeg, size_stim_pix, FREQS] = setupBasicGaborParameters(windowRect, screen_size, distance, stim_size, DISTANCE, FREQS_test);

%% Other Gabor Parameters 

[gabortex, aspectRatio, phase, contrast] = createGaborTexture(window, gaborDimPix, current_test);

%% Interleaved Staircases

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

sc_num_freqs = 1;
scRightRules = repelem(sc_num_freqs,num_freqs);
numStaircases   = numel(scRightRules);

    % these parameters control the staircase 
StimLevels      = log10(1):0.00001:log10(100); % stimulus levels from 1 to 100 (log) - which should provide around 60 steps
initStepSize    = 0.4;      % staircase step size before first reversal
stepSize        = 0.2;      % staircase step size after first reversal - has more reversals (see staircase code)
nWrongToAscend  = 1;        % number of "correct" responses before ascending
nRightToDescend = 1;        % number of "incorrect" responses before descending
maxNumTrials    = 30;       % maximum number of trials for each staircase
maxNumReversals = 8;        % maximum number of reversals for staircase

if contains(normal_testing, 'yes') 
    startLevel = log10(100);
else
    startLevel = log10(50);
end% starting level of staircase (50 should be manageable to begin with)
verbose = 1;        % set to 1 for verbose staircase output

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
sz = [(maxNumTrials+7)*nb_table;15];
varTypes = ["double","double","double","double", "double", "string", "string","double","double","double","double","double","datetime", "string", "string"];
varNames = ["Staircase","Fraction","Frequency", "orientationAE", "orientationFE", "Position","Key","Trial","Reversal","LevelAE","Level", "RT","time", "Eye", "AMB"];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

counter_trial = 1;

%% creating the reversals table
mr = [maxNumReversals*6+1;3];
varTypes2 = ["double", "double", "double"];
varNames2 = ["Reversal  Number", "Value", "Staircase"];
mrt = table('Size',mr,'VariableTypes',varTypes2,'VariableNames',varNames2);

%% and the mean reversals only
m = [iSC+1;4];
varTypes2 = ["double", "double", "double", "double"];
varNames2 = ["Staircase","Fraction","Frequency","MEAN"];
mt = table('Size',m,'VariableTypes',varTypes2,'VariableNames',varNames2);



%% launch the experiment staircase

    % keep looping until all staircases conclude
    while ~all([staircaseArray(:).isFinished])
  
     % run the fixing cross before the trial
   [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress);

  
    % select a random unfinished staircase
    iSC = randi(numStaircases);
    while staircaseArray(iSC).isFinished
        iSC = randi(numStaircases);
    end
    
    [angular_1, angular_2, orientation_link] = randomizeOrientation_Interocular_Imbalance(7.1);% define degrees tilt (original test = 7.1)

        StimLevel = staircaseArray(iSC).curLevel;
        linStimLevel = (10^StimLevel);             % convert to linear units - let's try but I am not sure
        freq = FREQS(iSC);                          % match the randomly chosen staircase
        if contains(normal_testing, 'yes') % careful, this has been reversed! 
            contrast = 0.5;
            contrastAE = linStimLevel/100;
        else 
            contrast = linStimLevel/100;
            contrastAE = 1; % if participant sees AE orientation then good answer, and the FE contrast gets higher
        end
        sigma = gaborDimPix/6;
        % make properties matrixes for the Gabors
        propertiesMatAE = [phase, freq, sigma, contrastAE, aspectRatio, 0, 0, 0];
        propertiesMatFE = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

        %% Eyelink Start trial
eyelink_start_trial(var_eye_link, staircaseArray(iSC).trialCount, orientation_link, [])

%% display the stim
[buffer_num_AE, buffer_num_FE, angle_AE, angle_FE, angle_results_AE, angle_results_FE] = displayStimulus_binocular_imbalance(window, gabortex, xCenter, yCenter, angular_1, angular_2, propertiesMatFE, propertiesMatAE, gaborDimPix, diff, FF1b, FF1w, FF2b, FF2w);

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% set the time presentation then flip the window 
debug_interocular_imbalance = false;
time_presentation_function(window, gaborDimPix, xCenter, yCenter, diff, black, white, FF1b, FF1w, FF2b, FF2w, debug_interocular_imbalance, 0.2);
Screen('Flip', window);
   
%% Wait for a button press


   onsetTime = GetSecs;
   [rt, value, key, temps, counter_trial] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc, temp, counter_trial);
    if contains(value, 'ESCAPE')
        break;
    end

   [mrt,counter_mrt] = calculateLastSixReversals(staircaseArray(iSC), temps, mrt, num_training, current_test, counter_mrt, contrastAE, contrast);
   [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(staircaseArray(iSC), temps, mrt, maxNumReversals, freq, Stim_position, EYE_TEST, AMB_EYE, current_test, counter_trial, mt, iSC, FREQS_test);
   plotStaircaseValues(staircaseArray(iSC), temps, mean_reversals, iSC, freq, current_test, contrastAE, contrast);

    

   %% Stop the eyelink recording 
   eyelink_stop_recording_and_write_variables(var_eye_link,staircaseArray(iSC).trialCount, orientation_link, [])

    end

 %% eyelink - close the edf file
 newName = ['Interocular_Imbalance', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);


 %% Clear screen
sca;

%% result table
baseFileName = SUBJECT + "_" + date + '_binoc_orientation';

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);

writetable(temps,filename)

fprintf('Output saved in: %s\n', filename)

%% ending the script 

save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 
