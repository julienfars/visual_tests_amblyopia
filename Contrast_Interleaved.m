% potential changes to make it more functional 
%{
- add training trials 
- add a CSf figure in polt results function 
%}
%% Setup
sca;
commandwindow;
filepath=fileparts(which('Contrast_Interleaved.m'));
cd(filepath);
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% initialisation of eyelink
[dummymode, var_eye_link] = eyelink_init(1);

%% Same patient? Retest? 
% This battery of test will be performed thrice on the same session (FE, AE and BE)
% And thrice for each participant (training, test and retest)
New_patient = getNewPatientInfo(); % popup window that control if this is a new participant 
global_param = initializeNewPatient(New_patient); % if new patient is true then the parameters are initialised. If not, we retrieve the previous parameters 
retest = getRetestInfo(global_param); % popup window that control if this is a retest or not
global_param.Retest = contains(retest, 'true');% Set retest variable

%% reduced version  
% not functional yet?
global_param = initializeReduced(global_param);

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'contrast_interleaved';

% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test...
    , CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);
global_param.ID = SUBJECT; % records the participant's ID in the global_param structure 
global_param.AMB_EYE = AMB_EYE; % records the participant's amblyopic eye in the global_param structure 
global_param.EYE_TEST = EYE_TEST; % records the participant's tested eye in the global_param structure 
%% launch eyelink parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen Parameters
% Call the function to set up screen parameters
debug = 0;
stereo = 100; % is supposed to be 100 when using display++
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
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, global_param, fixCross, stereo); % fusion frame function, used at all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters
% Call the function to set up basic Gabor parameters
[gaborDimPix, PixelPerDeg, size_stim_pix, FREQS_dva] = setupBasicGaborParameters(windowRect, ...
    global_param.screen_size, global_param.distance, global_param.stim_size, FREQS_test, current_test);
FREQS = FREQS_test.*CUTOFF; 
%% Other Gabor Parameters 
[gabortex, aspectRatio, phase, contrast] = createGaborTexture(window, gaborDimPix, current_test);

%% Interleaved Staircases
% Query the frame duration
ifi = Screen('GetFlipInterval', window);

sc_num_freqs = 3;
scRightRules = repelem(sc_num_freqs,length(FREQS_test));
numStaircases   = numel(scRightRules);%scRightRules    = [3, 3, 3, 3, 3, 3]; 

    % these parameters control the staircase 
StimLevels      = log10(100):-0.00001:log10(1);     % stimulus levels from 1 to 100 (log) - which should provide around 60 steps 
initStepSize    = -0.6;     % staircase step size before first reversal
stepSize        = -0.4;     % staircase step size after first reversal - has more reversals (see staircase code)
nWrongToAscend  = 1;        % number of "incorrect" responses before ascending
nRightToDescend = 3;        % number of "correct" responses before descending
maxNumTrials    = 40;       % maximum number of trials for each staircase
maxNumReversals = 8;        % maximum number of reversals for staircase
startLevel      = log10(80);% starting level of staircase (50% should be manageable to begin with)
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

%% Mean reversals table
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

while ~all([staircaseArray(:).isFinished])% keep looping until all staircases conclude
    
[HC1, HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, ...
escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, doubleScreen, AMB_EYE, EYE_TEST, ...
HC1, HC2, FF1w, FF1b, FF2w, FF2b, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, ...
black, white, ifi, current_test);

% Randomisation
[angular, orientation] = randomizeOrientation();

% select a random unfinished staircase
iSC = randi(numStaircases);
while staircaseArray(iSC).isFinished
    iSC = randi(numStaircases);
end
% think about including this part in trainingTrialsProperties when I have time  
num_training = 0; % not implemented yet, set at 0 
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

[dstGab_center1, dstGab_center2] = drawGaborStimulus(window, gabortex, stereo, ...
AMB_EYE, EYE_TEST, xCenter, yCenter, angular, propertiesMat, gaborDimPix, diff, ...
FF1b, FF1w, FF2b, FF2w, black, white);

% Flip to the screen
beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
Screen('Flip', window);
onsetTime = GetSecs; 

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% Wait for a button press
  if contains(AMB_EYE, 'Left')
      HCa = HC1;
      HCb = HC2;
  else
      HCb = HC1;
      HCa = HC2;
  end
[rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey,...
    angular, staircaseArray(iSC), temps, counter_trial, orientation, current_test, fixCross, HCa, HCb);
temps(counter_trial,:) = {current_test, datetime('now'), staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, AMB_EYE, EYE_TEST, contrast, iSC, propertiesMat(2)*gaborDimPix, orientation, Stim_position, key, value, rt};
if contains(value, 'ESCAPE')
    mean_reversals = 0;
    break;
end
    [mrt,counter_mrt] = calculateLastSixReversals(staircaseArray(iSC), temps, mrt, num_training, current_test, counter_mrt, freq, contrast, iSC);

if staircaseArray(iSC).isFinished
    [mean_reversals, success_reversal, mt] = calculateMeanReversals(staircaseArray(iSC),mrt, maxNumReversals, contrast, current_test, iSC, FREQS_test, mt);
    temps(counter_trial + 1,:) = {current_test, datetime('now'), staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, 'MEAN', 'REVERSAL', mean_reversals, iSC, propertiesMat(2)*gaborDimPix, orientation, Stim_position, success_reversal, 'end_of_table', 0};
    counter_trial = counter_trial + 1;
else 
    mean_reversals = 0;
end
plotStaircaseValues(staircaseArray(iSC), temps, mean_reversals, iSC, contrast, current_test, [], []);

%% 'Wash' the display
% after the stim was displayed, we wash the screen by displaying a
% background colour surface on the stim area
washDisplay(window, AMB_EYE, EYE_TEST, HC1, HC2, doubleScreen, windowRect, dstGab_center1, dstGab_center2, FF1b, FF1w, FF2b, FF2w, black, white);

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
baseFileName = SUBJECT + "_" + char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')) + '_contrast_interleaved';
[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mt);
writetable(temps,filename)
fprintf('Output saved in: %s\n', filename)

%% ending the script
if ~isempty(diff)
    global_param.pix_shift = diff(1:2,1);
end
global_param.EYE_TEST = '?';
save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 
