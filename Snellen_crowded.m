%% Variables 

%% Setup
clear all;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Snellen_crowded.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths (useful to save the files at the end of the test)
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% retrieve data from previous test 
New_patient = []; % set to empty as the battery of tests should not start by this test
global_param = initializeNewPatient(New_patient);

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'snellen_crowded';
% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross] = getParticipantInfo(global_param);
    
%% Screen Parameters
% Call the function to set up screen parameters
[window, windowRect, width, height] = setupScreen(100);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

%% Other parameters
% Call the function to set up other parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect);

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)

%% Size of optotypes  
[E_min_size_dva, global_param] = calculateOptotypeSize(windowRect, global_param, DISTANCE, fixCross);
   
%% Basic Snellen parameters
E_texture = preallocate_Snellen_texture(window);

%% Staircase parameters
ifi = Screen('GetFlipInterval', window);

% these parameters control the staircase 

StimLevels      = max_opto_size:-1:2;    % stimulus levels - here a decreasing list (need to convert it to logMAR eventually)
initStepSize    = -10;        % staircase step size before first reversal
stepSize        = -4;        % staircase step size after first reversal - has more reversals (see staircase code)
nRightToDescend = 3;        % number of "correct" responses before descending
nWrongToAscend  = 1;        % number of "incorrect" responses before ascending
maxNumTrials    = 30;       % maximum number of trials for staircase
maxNumReversals = 8;       % maximum number of reversals for staircase
startLevel      = 20;       % starting level of staircase 
verbose         = 1;        % set to 1 for verbose staircase output

% class constructor function returns staircase object (see staircase.m)
sc = staircase(StimLevels, initStepSize, stepSize,         ...
               nRightToDescend, nWrongToAscend, maxNumTrials, ...
               maxNumReversals, startLevel, verbose);

%% creating the results table (will be in /data folder)
nb_table = 1;
temps = createTable(maxNumTrials, nb_table,["string", "datetime", "double", "double", "string", "string", "string", ...
                    "double", "double","double","double","double", "string", "string", "string", "double"], ["Task", "Date_time",...
                    "Trial", "Reversal", "Staircase", "AMB_eye", "Eye_tested", "logMar", ...
                       "Orientation_center", "Orientation_left", "Orientation_top", "Orientation_bottom", "Orientation_right",...
                       "Position", "Key", "Success", "RT"]);

%% creating the mean reversals table (for the calculation of the mean/threshold)
mrt = createMRTTable(maxNumReversals, nb_table, 'simple');

%% determining moving side of the half crosses
[HC1, HC2] = determineMovingSide(AMB_EYE, HCl, HCr);

    %% launch the experiment staircase

doubleScreen = false;

while ~sc.isFinished           % keep looping until staircase concludes
    
    [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
    doubleScreen, AMB_EYE,HC1,HC2, FF1w, FF1b, FF2w, FF2b, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress, black, white, ifi, current_test);
    
    [crowd, E_rand_orientation] = generateSnellenCrowdedTexture(window);

    StimLevel = sc.curLevel;          % testing level from staircase
    opto_size = StimLevel;
    filterMode = 0;

%% display the stim
    
    drawCrowdedE(window, doubleScreen, E_shape, E_rand_orientation, opto_size, xCenter, yCenter, crowd, diff);
       
    % Flip to the screen
    beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);
    onsetTime = GetSecs;


  %% Wait for a button press
   [rt, value, key, temps, counter_trial] = waitForButtonPress(onsetTime, var_eye_link, escapeKey, rightKey, leftKey, angular, sc, temps, counter_trial, orientation, current_test);
   if contains(value, 'ESCAPE')
        break;
   end
   
  %% 'Wash' the display
   % after the stim was displayed, we wash the screen by displaying a
   % background colour surface on the stim area
   washDisplay(window, doubleScreen, windowRect, dstGab_center1, dstGab_center2, FF1b, FF1w, FF2b, FF2w);
   WaitSecs(0.5);
   
%% Record/display the results
% add a part to convert opto_size in logMAR?

   [mrt, counter_mrt] = calculateLastSixReversals(sc, temps, mrt, num_training, 'snellen', counter_mrt, opto_size, []);

   [temps, counter_trial, mt, mean_reversals] = calculateMeanReversals(sc, temps, ...
   mrt, maxNumReversals, opto_size, Stim_position, EYE_TEST, AMB_EYE, ...
   current_test, counter_trial, mt, iSC, FREQS_test);
                %here the function for the plot staircase/values (needs to be modified for compatibility with all the tests)
   plotStaircaseValues(sc, temps, mean_reversals, [], opto_size) 
    
end

%% Clear screen
sca;

%% Results table
% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + date + '_snellen_e_crowded';

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);

writetable(temps,filename)

fprintf('Output saved in: %s\n', filename)

%% ending the script
global_param.EYE_TEST = '?';
save('data/Global_parameters/global_param.mat','global_param'); % save the changes for the next tests 
