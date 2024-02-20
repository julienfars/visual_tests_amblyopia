%% Setup
sca;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Snellen.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths (useful to save the files at the end of the test)
KbName('UnifyKeyNames'); %set up the keyboard for answers 

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
current_test = 'snellen';
% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, ...
    CUTOFF, NOISE, CONTRAST, global_param] = getParticipantInfo(global_param, current_test);
global_param.ID = SUBJECT; % records the participant's ID in the global_param structure 
global_param.AMB_EYE = AMB_EYE; % records the participant's amblyopic eye in the global_param structure 
global_param.EYE_TEST = EYE_TEST; % records the participant's tested eye in the global_param structure 

%% Screen Parameters
% Call the function to set up screen parameters
debug = 0;
stereo = 100; % is supposed to be 100 when using display++
[window, windowRect, width, height, black, white] = setupScreen(stereo, debug); % look into this function to change the gamma table parameters
% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

%% Other parameters
% Call the function to set up other parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect);

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)

%% Size of optotypes  
   [E_min_size_dva, global_param] = calculateOptotypeSize(windowRect, global_param, DISTANCE, fixCross);
    
%% Staircase parameters
ifi = Screen('GetFlipInterval', window);

% these parameters control the staircase 
StimLevels      = max_opto_size:-1:2;    % stimulus levels - here a decreasing list in pixels
initStepSize    = -10;        % staircase step size before first reversal
stepSize        = -4;         % staircase step size after first reversal - has more reversals (see staircase code)
nRightToDescend = 3;          % number of "correct" responses before descending
nWrongToAscend  = 1;          % number of "incorrect" responses before ascending
maxNumTrials    = 30;         % maximum number of trials for staircase
maxNumReversals = 8;          % maximum number of reversals for staircase
startLevel      = 20;       % starting level of staircase 
verbose         = 1;          % set to 1 for verbose staircase output

% class constructor function returns staircase object (see staircase.m)
sc = staircase(StimLevels, initStepSize, stepSize,         ...
               nRightToDescend, nWrongToAscend, maxNumTrials, ...
               maxNumReversals, startLevel, verbose);

%% creating the results table (will be in /data folder)
nb_table = 1;
temps = createTable(maxNumTrials, 1,["string", "datetime", "double", "double", "string", "string", ...
                    "double", "double", "string", "string", "string", "double"], ["Task", "Date_time",...
                    "Trial", "Reversal", "AMB_eye", "Eye_tested", "logMar", ...
                       "Orientation", "Position", "Key", "Success", "RT"]);

%% creating the mean reversals table (for the calculation of the mean/threshold)
mrt = createMRTTable(maxNumReversals, nb_table, 'simple');

%% determining moving side of the half crosses
[HC1, HC2] = determineMovingSide(AMB_EYE, HCl, HCr);

%% launch the experiment staircase
    doubleScreen = false;
    counter_trial = 0;
    num_training = 0; 
    counter_mrt = 0;
while ~sc.isFinished           % keep looping until staircase concludes  
    [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE,HC1,HC2, [], [], [], [], HCl, HCr, [], [], [], [], pixelsPerPress, black, white, ifi, current_test);
    [orientation, E_shape] = randomizeOrientation_snellen();
    E_texture = Screen('MakeTexture', window, E_shape);
    StimLevel = sc.curLevel;          % testing level from staircase
    opto_size = StimLevel;

%% display the stim
    drawSnellenStimulus(window, doubleScreen, E_texture, xCenter, yCenter, opto_size, diff);
    % Flip to the screen
    beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);
    onsetTime = GetSecs; % Wait for a button press

%% wait the button press

    [rt, value, key, counter_trial, Stim_position] = waitForButtonPress(onsetTime, var_eye_link, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey,...
    [], sc, temps, counter_trial, orientation, current_test, fixCross, HC1, HC2);
    temps(counter_trial,:) = {current_test, datetime('now'), sc.trialCount, sc.revCount, AMB_EYE, EYE_TEST, opto_size, orientation, Stim_position, key, value, rt};
    if contains(value, 'ESCAPE')
        mean_reversals = 0;
        break;
   end
   %% Record/display the results
% add a part to convert opto_size in logMAR?
   [mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, current_test, [], opto_size, [], []);
   if sc.isFinished
       [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, mrt, maxNumReversals, opto_size, Stim_position, ...
           EYE_TEST, AMB_EYE, current_test, counter_trial, mt, iSC, FREQS_test);
   else
       mean_reversals =0;
   end
   plotStaircaseValues(sc, temps, mean_reversals, [], opto_size, current_test, [], []);

   %% 'Wash' the display
   % after the stim was displayed, we wash the screen by displaying a
   % background colour surface on the stim area
   washDisplay(window, AMB_EYE, EYE_TEST, HC1, HC2, doubleScreen, windowRect, dstGab_center1, dstGab_center2, [], [], [], [], black, white);
   WaitSecs(0.5);
end

%% Clear screen
sca;

%% Results table
% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')) + '_snellen_e';
[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);
writetable(temps,filename)
fprintf('Output saved in: %s\n', filename)

%% ending the script
global_param.EYE_TEST = '?';
if ~isempty(diff)
    global_param.pix_shift = diff(1:2,1);
end
save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 
