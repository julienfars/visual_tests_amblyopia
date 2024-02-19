%{
- add training trials? 
%}

%% Setup
sca;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Interocular_Imbalance.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths 
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% Eyelink Initialisation
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
current_test = 'interocular_imbalance';
global_param.EYE_TEST = 'Both';
% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test,...
    CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);
normal_testing = global_param.binoc_normal_testing; %set to 1 to test people with regular vision, keep at 0 for amblyopes
num_freqs = numel(FREQS_test); 

%% launch eyelink parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen Parameters
% Call the function to set up screen parameters
debug = 0; 
stereo = 100;
[window, windowRect, width, height, black, white] = setupScreen(stereo, debug); % look into this function to change the gamma table parameters

%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)
[el] = eyelink_calibration(var_eye_link,window, stereo, [], width, height);

%% Other parameters
% Call the function to set up other parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, ...
    skipKey] = setupOtherParameters(window, windowRect);

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test
eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, global_param, fixCross, stereo); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters
% Call the function to set up basic Gabor parameters
[gaborDimPix, PixelPerDeg, size_stim_pix, FREQS] = setupBasicGaborParameters(windowRect, ...
    global_param.screen_size, global_param.distance, global_param.stim_size, FREQS_test, current_test);

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
if normal_testing 
    startLevel = log10(100);
else
    startLevel = log10(50);
end % starting level of staircase (50 should be manageable to begin with)
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
temps = createTable(maxNumTrials, nb_table, ["string", "datetime", "double", "double", "string", ...
    "string", "double", "double", "double", "double", "double", "double", "string", "string", "string", "double"], ...
    ["Task", "Date_time", "Trial", "Reversal", "AMB_eye", "Eye_tested", "Contrast_AE", "Contrast_FE", "Staircase",...
    "Frequency_dva", "Orientation_AE", "Orientation_FE", "Position", "Key", "Success", "RT"]);

%% creating the reversals table
mrt = createMRTTable(maxNumReversals, nb_table, 'interleaved');
counter_mrt = 1;

%% and the mean reversals only
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold
mt = createMTTable(nb_table, 'interleaved');

%% Start the experiment 
[HC1, HC2, FF1w, FF1b, FF2w, FF2b] = resetCross(AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb);
counter_trial = 0;
doubleScreen = false;      % this value will determine when to show the half cross (see fix_cross function)
%fixCross = 1; % put to one to display fixation cross (keep at zero unless debugging)

while ~all([staircaseArray(:).isFinished])

[HC1, HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, ...
escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, doubleScreen, AMB_EYE, EYE_TEST, ...
HC1, HC2, FF1w, FF1b, FF2w, FF2b, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, ...
black, white, ifi, current_test);

% select a random unfinished staircase
iSC = randi(numStaircases);
while staircaseArray(iSC).isFinished
    iSC = randi(numStaircases);
end

[angular_1, angular_2, orientation_link] = randomizeOrientation_Interocular_Imbalance(7.1);% define degrees tilt (original test = 7.1, when debugging, use 25)

StimLevel = staircaseArray(iSC).curLevel;
linStimLevel = (10^StimLevel);             % convert to linear units - let's try but I am not sure
freq = FREQS(iSC);                          % match the randomly chosen staircase
if normal_testing
    contrast = 0.5;
    contrastAE = linStimLevel/100;
else 
    contrast = linStimLevel/100;
    contrastAE = 1; % if participant sees AE orientation == successful trial, the FE contrast gets higher
end
sigma = gaborDimPix/6;
% make properties matrixes for the Gabors
propertiesMatAE = [phase, freq, sigma, contrastAE, aspectRatio, 0, 0, 0];
propertiesMatFE = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

%% Eyelink Start trial
eyelink_start_trial(var_eye_link, staircaseArray(iSC).trialCount, orientation_link, [])

%% display the stim
[buffer_num_AE, buffer_num_FE, angle_AE, angle_FE, angle_results_AE, angle_results_FE] = displayStimulus_binocular_imbalance(window, ...
    gabortex, xCenter, yCenter, angular_1, angular_2, propertiesMatFE, propertiesMatAE, gaborDimPix, diff, FF1b, FF1w, FF2b, FF2w, ...
    AMB_EYE, black, white);

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% set the time presentation then flip the window 
time_presentation_function(window, gaborDimPix, xCenter, yCenter, diff, black, ...
    white, FF1b, FF1w, FF2b, FF2w, current_test, debug, 0.2);
Screen('Flip', window);
   
%% Wait for a button press
onsetTime = GetSecs;
if contains(EYE_TEST, 'Left')
    angular = [angular_1 angular_2];
else 
    angular = [angular_2 angular_1];
end
[rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, ...
    downKey, escapeKey, spaceKey, skipKey,angular, staircaseArray(iSC), temps, counter_trial, [], current_test, fixCross, HC1, HC2, normal_testing);
temps(counter_trial,:) = {current_test, datetime('now'), staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, ...
    AMB_EYE, EYE_TEST, contrastAE, contrast, iSC, propertiesMatAE(2)*gaborDimPix, angle_results_AE, angle_results_FE, Stim_position, key, value, rt};
if contains(value, 'ESCAPE')
    mean_reversals = 0;
    break;
end

[mrt,counter_mrt] = calculateLastSixReversals(staircaseArray(iSC), temps, mrt, 0, current_test, counter_mrt, contrastAE, contrast, iSC, normal_testing);
if staircaseArray(iSC).isFinished
[temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(staircaseArray(iSC), temps, mrt, maxNumReversals, contrast, Stim_position, EYE_TEST, AMB_EYE, current_test, counter_trial, mt, iSC, FREQS_test);
else 
   mean_reversals = 0;
end
plotStaircaseValues(staircaseArray(iSC), temps, mean_reversals, iSC, freq, current_test, contrastAE, contrast, normal_testing);

%% Stop the eyelink recording 
eyelink_stop_recording_and_write_variables(var_eye_link,staircaseArray(iSC).trialCount, orientation_link, [])

end

 %% eyelink - close the edf file
 newName = ['Interocular_Imbalance', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);

 %% Clear screen
sca;

%% result table
% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')) + '_binoc_orientation';
[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mt);
writetable(temps,filename)
fprintf('Output saved in: %s\n', filename)

%% ending the script 
if ~isempty(diff)
    global_param.pix_shift = diff(1:2,1);
end
save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 
