%% Setup
sca; % to clean the workspace
commandwindow; % to open the command window
filepath=fileparts(which('Cutoff.m')); % determine the filepath of the current script (all tests must be in the same folder) 
cd(filepath); % add the filepath to matlab filepaths (to save the files at the end of the test)
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% Eyelink Initialization
[dummymode, var_eye_link] = eyelink_init(1);

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
current_test = 'cutoff';
% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, ...
    CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);

global_param.ID = SUBJECT; % records the participant's ID in the global_param structure 
global_param.AMB_EYE = AMB_EYE; % records the participant's amblyopic eye in the global_param structure 
global_param.EYE_TEST = EYE_TEST; % records the participant's tested eye in the global_param structure 

%% Eyelink Parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen Parameters
% Call the function to set up screen parameters
debug = 0;
stereo = 100; % is supposed to be 100 when using display++
[window, windowRect, width, height, black, white] = setupScreen(stereo, debug); % look into this function to change the gamma table parameters

%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)
[el] = eyelink_calibration(var_eye_link,window, stereo, current_test, width, height);

%% Other parameters
% Call the function to set up other parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect);

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test
eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
% will start if the participant has starbismus AND is testing BE 
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, global_param, fixCross, stereo); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters
% Call the function to set up basic Gabor parameters
[gaborDimPix, PixelPerDeg, size_stim_pix, FREQS] = setupBasicGaborParameters(windowRect, global_param.screen_size, global_param.distance, global_param.stim_size, [], current_test);

%% Other Gabor Parameters
[gabortex, aspectRatio, phase, contrast] = createGaborTexture(window, gaborDimPix, current_test);

%% Staircase 
% then we set up the staircase procedure
ifi = Screen('GetFlipInterval', window);
% these parameters control the staircase (change it to remove the extra stepSizes)
StimLevels      = log10(1):0.00001:log10(100);     % stimulus levels from 1 to 100 (log) 
initStepSize    = 0.6;      % staircase step size before first reversal
stepSize        = 0.4;      % staircase step size after first reversal - has more reversals (see staircase code)
nRightToAscend  = 3;        % number of "correct" responses before ascending
nWrongToDescend = 1;        % number of "incorrect" responses before descending
maxNumTrials    = 35;       % maximum number of trials for staircase (35 without the training - 40 in total)
maxNumReversals = 8;       % maximum number of reversals for staircase
startLevel      = log10(5); % starting level of staircase (5 should be easy to begin with)
verbose         = 1;        % set to 1 for verbose staircase output

% class constructor function returns staircase object (see staircase.m)
sc = staircase(StimLevels, initStepSize, stepSize,         ...
               nRightToAscend, nWrongToDescend, maxNumTrials, ...
               maxNumReversals, startLevel, verbose);

%% Result table
% the final results table is generated here (optimisation reasons)
% this table will be saved in the 'data' folder as an excel table for further analyses 
nb_table = 1;
temps = createTable(maxNumTrials, nb_table); % use default variable types and names

%% Mean reversals table 
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold
mrt = createMRTTable(maxNumReversals, nb_table, 'simple');

 %% Start the experiment 
[HC1, HC2, FF1w, FF1b, FF2w, FF2b] = resetCross(AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb);
doubleScreen = false;      % this value will determine when to show the half cross (when set to 'true')
counter_trial = 0;
%fixCross = 1; % put to one to display fixation cross (keep at zero unless debugging)

while ~sc.isFinished           % keep looping until staircase concludes
  
[HC1, HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, ...
    escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, doubleScreen, AMB_EYE, EYE_TEST, ...
    HC1, HC2, FF1w, FF1b, FF2w, FF2b, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, ...
    black, white, ifi, current_test);

% Randomisation
[angular, orientation] = randomizeOrientation();

% Call the function for training trials
num_training = 5; % Number of training trials
propertiesMat = trainingTrialsProperties(sc, num_training, gaborDimPix, aspectRatio, phase, contrast);

 %% Eyelink Start trial
eyelink_start_trial(var_eye_link, sc.trialCount, orientation, [])

 %% display the stim
[dstGab_center1, dstGab_center2] = drawGaborStimulus(window, gabortex, stereo, ...
AMB_EYE, EYE_TEST, xCenter, yCenter, angular, propertiesMat, gaborDimPix, diff, ...
FF1b, FF1w, FF2b, FF2w, black, white);

% Flip to the screen
beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is tested)
Screen('Flip', window);
onsetTime = GetSecs;

%% Eyelink recording
% we start recording the trial here
[err] = eyelink_start_recording(var_eye_link);

%% Wait for a button press
[rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey,...
    angular, sc, temps, counter_trial, orientation, current_test, fixCross, HC1, HC2);
temps(counter_trial,:) = {current_test, datetime('now'), sc.trialCount, sc.revCount, EYE_TEST, AMB_EYE, contrast, propertiesMat(2), orientation, Stim_position, key, value, rt};
if contains(value, 'ESCAPE')
    mean_reversals = 0;
    break;
end

%% Record/display the results
[mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, [], propertiesMat(2), [], []);
if sc.isFinished
[temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, mrt, maxNumReversals, propertiesMat(2), Stim_position, EYE_TEST, AMB_EYE, current_test, counter_trial, [], [], []);
else 
   mean_reversals = 0;
end
plotStaircaseValues(sc, temps, mean_reversals, [], propertiesMat(2), current_test, [], []);

%% 'Wash' the display
% after the stim was displayed, we wash the screen by displaying a
% background colour surface on the stim area
washDisplay(window, AMB_EYE, EYE_TEST, HC1, HC2, doubleScreen, windowRect, dstGab_center1, dstGab_center2, FF1b, FF1w, FF2b, FF2w, black, white);

%% Stop the eyelink recording
WaitSecs(1);
eyelink_stop_recording_and_write_variables(var_eye_link,sc.trialCount, orientation, [])

end

%% Eyelink close edf and save
newName = ['Cutoff_', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);

%% Clear screen
sca;

%% Results table
% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')) + '_cutoff_freq';
[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);
writetable(temps,filename)
fprintf('Output saved in: %s\n', filename)

%% ending the script
global_param.EYE_TEST = '?'; % ready for the next launch
if ~isempty(diff)
    global_param.pix_shift = diff(1:2,1);
end
save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 

% end of the script 