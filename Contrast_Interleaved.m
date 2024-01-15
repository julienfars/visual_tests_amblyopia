%{
Welcome to the battery of tests used in the Amblyopia study. 
If you have questions about the tests, contact Juju (julien.fars@ndcn.ox.ac.uk)
This battery aims to test various functions of the amblyopic visual experience. 
The parameters of this test (and the subsequent ones) are extracted from the GetGlobalVariables.m script and then are stored in the
global_param.mat variable.
Change the parameters in the GetGlobalVariables.m script to your settings FIRST. 
This battery of tests is using modified scripts from several research teams and individuals. 
For the original version of these scripts, contact: 
- Alex S Baldwin - McGill Vision Research (for the staircase protocol)
- Jun-Yun Zhang - Beijing Key Laboratory of Behavior and Mental Health (for the Dichoptic test)
- Alice Grasso McCaslin, School of Optometry, Indiana University (Asteroid test script and related functions)

It is also important to note that some functions present in the battery of tests were inspired from the
work of Peter Scarfe - Scarfe Lab (see https://peterscarfe.com/ptbtutorials.html)
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
- add a results figure 
%}


%% Setup
sca;
commandwindow;
filepath=fileparts(which('Contrast_Interleaved.m'));
cd(filepath);

%% initialisation of eyelink

[dummymode, var_eye_link] = eyelink_init(1);

%% retrieve data from previous test 

% will retrieve the global parameters file, and if it does not exist then 
% it will still set the parameters but set the cutoff to 0 
% meaning you need to specify it in the prompt (useful for debugging = still allows test run)
if isfile("global_param.mat")
    load("global_param.mat");
else
    global_param = GetGlobalVariables();
end

KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% do the reduced version?  
% here we ask if this is a new patient (important otherwise we wipe the global parameters)
prompt_first = {'do the reduced version? [true/false]'}; %description of fields
defaults_first = {'false'};
answer_first = inputdlg(prompt_first, 'Parameters',2,defaults_first); %opens dialog
reduced = answer_first{1,:};

if contains(reduced, 'true')
    prompt_second = {'Frequencies shorted list (change it if needed, must be [0:1]'}; %description of fields
    defaults_second = {'0.125 0.25 0.5 0.75'};
    answer_second = inputdlg(prompt_first, 'Parameters',2,defaults_first); %opens dialog
    FREQS_test = answer_second{1,:};
    global_param.reduced = true;
    golbal_param.freqs = str2num(FREQS_test);
else
    FREQS_test = '0.0625 0.125 0.25 0.5 0.75 1'; 
end % if not we continue (useful for debugging)

%% Gets subject Info sets up experiment
prompt = {'Enter subject number:','Size of stimuli' , 'cut-off frequency:', 'distance from screen', 'Enter the frequencies to test:', 'Which eye', 'Which one is amblyopic eye?', 'fixation cross?', 'edf file name?'}; %description of fields
defaults = {global_param.ID, num2str(global_param.stim_size), '-', num2str(global_param.distance), FREQS_test, global_param.EYE_TEST, global_param.AMB_EYE, 'true', strcat(global_param.ID,'ci')};%no default but the size (will be changed later) and the frequencies to test (we can then fremove some)
answer = inputdlg(prompt, 'Parameters',2,defaults); %opens dialog
SUBJECT = answer{1,:}; %Gets Subject Name
SIZE = answer{2,:};
SIZE = str2double(SIZE);
CUTOFF = answer{3,:}; 
DISTANCE = str2double(answer{4,:}); %transform text into numericals 
FREQS_test = answer{5,:}; %Gets the list of frequencies used (this part follows the article of Liu et al 2021 - see the ...)
FREQS_test = str2num(FREQS_test); %transform text into numericals - DO NOT USE str2double as it does not work 
%CUTOFF = str2num(CUTOFF); 
EYE_TEST = answer{6,:};
AMB_EYE = answer{7,:};
Glasses = answer{8,:}; %used later in the code, use false for monocular tests
edfFile = answer{9,:}; % should update name later, to be mindful of possible reruns

if contains(EYE_TEST, 'Both') && contains(Glasses, 'true')
    fixCross = 'true';
else
    fixCross = 'false';
end
    fixCross = strcmp(fixCross,'true'); %convert string to boolean
    
% add if/else that test which condition (AE, FE, BE) and set up the correct
% CUTOFF
if contains(CUTOFF, '-')
    if contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Left') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Right')
        CUTOFF = global_param.cut_off_AE; 
    elseif contains(EYE_TEST, 'Left') && contains(AMB_EYE, 'Right') || contains(EYE_TEST, 'Right') && contains(AMB_EYE, 'Left')
        CUTOFF = global_param.cut_off_FE;
    elseif contains(EYE_TEST, 'Both')
        CUTOFF = global_param.cut_off_BE;
    else %made another choice to cover all the possibilities (and still get the answer)
        CUTOFF = global_param.cut_off;
    end
end

CUTOFF = num2str(CUTOFF);

%this part asks again about the cut-off just to be sure 
prompt = {strcat('cut-off frequency','-',EYE_TEST,'-',AMB_EYE)};
dlgtitle = AMB_EYE;
dims = [1 7];
definput = {CUTOFF};
answer = inputdlg(prompt,'Parameter',dims,definput);
CUTOFF = answer{1,:}; 
CUTOFF = str2double(CUTOFF);

num_freqs = numel(FREQS_test); 
FREQS = FREQS_test.*CUTOFF; 

%% launch eyelink parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);


%% Screen stuff

if ismac % only for testing purposes, check if your system is compatible when doing real experiment 
    oldSyncLevel = Screen('Preference', 'SkipSyncTests', 1);
elseif isunix % linux platforms are generally fine
    Screen('Preference', 'SkipSyncTests', 0);
elseif ispc % only for testing purposes, check if your system is compatible when doing real experiment 
    oldSyncLevel = Screen('Preference', 'SkipSyncTests', 1);
else
    disp('Platform not supported')
    return
end

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. With our setup, values defined between 0 and 1.
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace value for white
grey = white / 2;

if fixCross == true % setting up the stereomode when both eyes are used 
        stereoMode = 100; 
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
        [window, windowRect] = PsychImaging('OpenWindow',screenNumber,grey,[],[],[],stereoMode);
    else
        stereoMode = [];
        [window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
end

% Instead of returning width and height of the graphics window/screen in pixels
% using this [width, height] = Screen('WindowSize', window); 
% we do 
width = windowRect(3);
height = windowRect(4);

%% Eyelink Calibration
[el] = eyelink_calibration(var_eye_link,window, stereoMode, [], width, height);

%% Other parameters
HideCursor(); %hides the cursor
KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue - keyboard inputs are considered now
[xCenter, yCenter] = RectCenter(windowRect);

%% clear screen of host PC 
eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters

%lets calculate the proper size of the gabors 
DIM_Screen_hor = windowRect(3)/global_param.screen_size(1); % we get the number of pixels per mm
DIM_Screen_ver = windowRect(4)/global_param.screen_size(2);
SIZE_mm = 2*DISTANCE*tand(SIZE/2); % convert the size of stim from dva to mm
gaborDimPix1 = DIM_Screen_ver*SIZE_mm; % here from mm to pix using the number of pixels per mm
gaborDimPix2 = DIM_Screen_hor*SIZE_mm;
gaborDimPix = round((gaborDimPix1+gaborDimPix2)/2); % we round it so we can keep a regular dva 


%% GABOR PARAMETERS

% Parameters for the Gabors (see help CreateProceduralGabor - psychtoolbox)
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
aspectRatio = 1.0;
phase = 0;
contrast = []; % will be calculated by the contrast procedure

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5).

gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
   backgroundOffset, disableNorm, preContrastMultiplier);

%% Interleaved Staircases

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

sc_num_freqs = [3];
scRightRules = repelem(sc_num_freqs,num_freqs);

%scRightRules    = [3, 3, 3, 3, 3, 3]; 
numStaircases   = numel(scRightRules);

% set up of the keys used in this test
leftKey=KbName('LeftArrow');
rightKey=KbName('RightArrow');
upKey=KbName('UpArrow');
downKey=KbName('DownArrow');
escapeKey = KbName('ESCAPE');
spaceKey = KbName('SPACE');

    % these parameters control the staircase 
StimLevels      = log10(100):-0.00001:log10(1);     % stimulus levels from 1 to 100 (log) - which should provide around 60 steps 
initStepSize    = -0.6;      % staircase step size before first reversal
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
    

%% creating the results table
exp_num = 1; 
data_name = "data\" + SUBJECT + "_" + date + "_contrast_interleaved_" + ...
    exp_num + ".xls";
nb_table = numel(FREQS);
sz = [(maxNumTrials+7)*nb_table;14]; % added +6 for each staircase mean reversals and +1 for safety
varTypes = ["double","double","double","double", "string", "string","double","double","double","string","double","datetime", "string", "string"];
varNames = ["Staircase","Fraction","Frequency", "orientation", "Position","Key","Trial","Reversal","Level","value", "RT","time", "Eye", "AMB"];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


%% creating the reversals table
mr = [maxNumReversals*6+1;3]; % added +1 for safety
varTypes2 = ["double", "double", "double"];
varNames2 = ["Reversal  Number", "Value", "Staircase"];
mrt = table('Size',mr,'VariableTypes',varTypes2,'VariableNames',varNames2);
counter_mrt = 1;

%% and the mean reversals only
m = [iSC+1;4]; % added +1 for safety
varTypes2 = ["double", "double", "double", "double"];
varNames2 = ["Staircase","Fraction","Frequency","MEAN"];
mt = table('Size',m,'VariableTypes',varTypes2,'VariableNames',varNames2);



counter_trial = 1;


%% setting the the values of left and right half crosses and fusion frames
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
    
%% launch the experiment staircase

    doubleScreen = false;      % this value will determine when to show the half cross (when set to 'true')
    while ~all([staircaseArray(:).isFinished])% keep looping until all staircases conclude
        
    while fixCross == true
    
    vbl = Screen('Flip', window);
    waitframes = 1; 
    exitFixCross = false;

    while exitFixCross == false

    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitFixCross = true; %I doubled the while loop just to be sure it goes to the next step - must change later
        fixCross = false;
        doubleScreen = true;
    elseif keyCode(leftKey) % each short press of the key moves the cross+frame of one pixel
        HC1(1,:)  = HC1(1,:)  - pixelsPerPress;
        HC1(3,:)  = HC1(3,:)  - pixelsPerPress;
        FF1w(1,:) = FF1w(1,:) - pixelsPerPress;
        FF1w(3,:) = FF1w(3,:) - pixelsPerPress;
        FF1b(1,:) = FF1b(1,:) - pixelsPerPress;
        FF1b(3,:) = FF1b(3,:) - pixelsPerPress;
    elseif keyCode(rightKey)
        HC1(1,:)  = HC1(1,:)  + pixelsPerPress;
        HC1(3,:)  = HC1(3,:)  + pixelsPerPress;
        FF1w(1,:) = FF1w(1,:) + pixelsPerPress;
        FF1w(3,:) = FF1w(3,:) + pixelsPerPress;
        FF1b(1,:) = FF1b(1,:) + pixelsPerPress;
        FF1b(3,:) = FF1b(3,:) + pixelsPerPress;
    elseif keyCode(upKey)
        HC1(2,:)  = HC1(2,:)  - pixelsPerPress;
        HC1(4,:)  = HC1(4,:)  - pixelsPerPress;
        FF1w(2,:) = FF1w(2,:) - pixelsPerPress;
        FF1w(4,:) = FF1w(4,:) - pixelsPerPress;
        FF1b(2,:) = FF1b(2,:) - pixelsPerPress;
        FF1b(4,:) = FF1b(4,:) - pixelsPerPress;
    elseif keyCode(downKey)
        HC1(2,:)  = HC1(2,:)  + pixelsPerPress;
        HC1(4,:)  = HC1(4,:)  + pixelsPerPress;
        FF1w(2,:) = FF1w(2,:) + pixelsPerPress;
        FF1w(4,:) = FF1w(4,:) + pixelsPerPress;
        FF1b(2,:) = FF1b(2,:) + pixelsPerPress;
        FF1b(4,:) = FF1b(4,:) + pixelsPerPress;
    elseif keyCode(spaceKey) % if the spacekey is pressed, then the cross+frame go back to the centre of the display
         if contains(AMB_EYE, 'Left') 
            HC1 = HCl;
            HC2 = HCr;
            FF1w = FFLw;
            FF2w = FFRw;
            FF1b = FFLb;
            FF2b = FFRb;
            else
            HC1 = HCr;
            HC2 = HCl;
            FF1w = FFRw;
            FF2w = FFLw;
            FF1b = FFRb;
            FF2b = FFLb; 
         end
    end
    
    % Draw the half crosses to the screen
    %first half cross
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, black, HC1);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);
    %second half cross
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, HC2);
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    % here we calculate the difference between the position of the half
    % cross and the center of the screen, this value will be used when
    % displaying the Stimuli
        if contains(AMB_EYE, 'Left')  
            diff(:,1) = HC1(:,1)-HCl(:,1); %
        else
            diff(:,1) = HC1(:,1)-HCr(:,1); %
        end
    
    end

    % this part is "washing up" the screen, it removes the crosses from the
    % display but leaves the frame
    baseRect = [0 0 200 250];
    [xCenter, yCenter] = RectCenter(windowRect);
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    rectColor = [1 1 1];

    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC2);
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    Screen('Flip', window);
    WaitSecs(1);


    end


    % select a random unfinished staircase
    iSC = randi(numStaircases);
    while staircaseArray(iSC).isFinished
        iSC = randi(numStaircases);
    end
        

        % for each trial the orientation is set randomly. Careful, the Gabor 
    % code from the psychtoolbox is not using degrees clockwise but
    % counterclockwise. This is why the angular variable is used for the 
    % code but the orientation variable is used for the dataframe. 
    if rand<0.5 
        angular = 45;
        orientation = 315;
        else 
        angular = 315;
        orientation = 45;
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

    if doubleScreen == true 
        dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), usually [0 0 1 1] when no stereomode=100
        dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter, yCenter);
        Screen('SelectStereoDrawBuffer',window,1);
        Screen('DrawTextures', window, gabortex, [], dstGab_center1, angular, [], [], [], [],...
        kPsychDontDoRotation, propertiesMat');
        Screen('FillRect', window, black, FF2b); 
        Screen('FillRect', window, white, FF2w);
    
        dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), usually [0 0 1 1] when no stereomode=100
        dstGab_center2 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
        Screen('SelectStereoDrawBuffer',window,0);
        Screen('DrawTextures', window, gabortex, [], dstGab_center2, angular, [], [], [], [],...
        kPsychDontDoRotation, propertiesMat'); 
        Screen('FillRect', window, black, FF1b);
        Screen('FillRect', window, white, FF1w);
    else
        Screen('DrawTextures', window, gabortex, [], [], angular, [], [], [], [],...
        kPsychDontDoRotation, propertiesMat');
        Screen('FillRect', window, black, FF2b);
        Screen('FillRect', window, white, FF2w);
    end

        % Flip to the screen
        beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
        Screen('Flip', window);


%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% Wait for a button press

    onsetTime = GetSecs;

    timeSecs = KbWait;
    [ keyIsDown, t, keyCode ] = KbCheck;
    keyCode = find(keyCode, 1);
    %think about changing the loops so if the participant choose a key that
    %is not defined, the trial does not change
   if keyIsDown
       rt = t - onsetTime; % we record the response time (rt)
       if contains(var_eye_link, 'true')
        Eyelink('Message', 'KEY_PRESSED');
       end
    if keyCode == escapeKey % we can always leave the test (if glitch)
            break;
    elseif  keyCode==rightKey && angular == 315 % remember the code use counterclockwise instead of clockwise
            staircaseArray(iSC).doResp(1); 
            value = 'TRUE';    
    elseif keyCode==leftKey && angular == 45
            staircaseArray(iSC).doResp(1);
            value = 'TRUE';
    else
            staircaseArray(iSC).doResp(0);
            value = 'FALSE';
    end
    KbReleaseWait;
    % now we record the responses (not done before because it would have needed a more complicated if/else architecture)
    if keyCode==rightKey
        key = "right";
    elseif keyCode==leftKey
        key = "left";
    else
        key = "other";
    end
        
        fprintf('Staircase %0.0f: current threshold from reversals: %0.2f +/- %0.2f\n\n', ...
                iSC, staircaseArray(iSC).curReversalThresh, staircaseArray(iSC).curReversalError)

    % get the x-y shift from the center into the variable Stim_position 
    Stim_position = HC1(1:2,3) - HC2(1:2,3);
    Stim_position = Stim_position'; % transpose 
    Stim_position = num2str(Stim_position);

    %add stim position
    temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq,orientation, Stim_position, key, staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, contrast, value, rt, datetime('now'), EYE_TEST, AMB_EYE};
    counter_trial = counter_trial +1;
   end

  
  
    %here the calculation of the last six reversals FOR EACH STAIRCASE
    if staircaseArray(iSC).trialCount > 2 % add training trials + 2 to only begins after the training trials 
        if temps{staircaseArray(iSC).trialCount,{'Reversal'}} ~= temps{staircaseArray(iSC).trialCount-1,{'Reversal'}} && staircaseArray(iSC).revCount ~= 0% only records when the number of reversals change 
            mrt(counter_mrt,:) = {staircaseArray(iSC).revCount, contrast, iSC}; % recorded in a table titled mrt
            counter_mrt = counter_mrt +1;
        end
    end

    if staircaseArray(iSC).isFinished
    % check if this part keeps the previous plots open
        idx = any(mrt{:,1} > maxNumReversals-6,2); %alternative is to get all of the reversals and THEN remove some from the total in mrt_extracted                                   
        mrt_extracted = mrt(idx,:);
        %mrt_extracted = mrt_extracted(:,3) == iSC;
        %mean_reversals = mean(mrt_extracted{:,2});
        idx2 = any(mrt_extracted{:,1} == iSC,2); 
        mrt_extracted = mrt_extracted(idx2,:);
        mean_reversals = mean(mrt_extracted{:,2});
        if isnan(mean_reversals) % in the case of having no reversals at all (get the last result)
                    mean_reversals = contrast;
        end
        % the mean of reversals is then recorded on a new table 
        mt(iSC,:) = {iSC, FREQS_test(iSC), freq, mean_reversals};
        counter_trial = counter_trial+1;
        temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq,0, 'mean', 'reversals', staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, mean_reversals, 'mean', 0, datetime('now'), EYE_TEST, AMB_EYE};
        counter_trial = counter_trial+1;
    end

    %here the function for the plot staircase/values 
    if staircaseArray(iSC).isFinished
        plot_results(staircaseArray(iSC).isFinished, temps, mean_reversals, iSC);
    else % even if not finished the plot is displayed
        plot_results(staircaseArray(iSC).isFinished, temps, contrast, iSC); 
    end


  if doubleScreen == true
       rectColor = [1 1 1];
       Screen('SelectStereoDrawBuffer',window,0);
       Screen('FillRect', window, rectColor*0.5, dstGab_center1);
       Screen('FillRect', window, black, FF1b);
       Screen('FillRect', window, white, FF1w);
       Screen('SelectStereoDrawBuffer',window,1);
       Screen('FillRect', window, rectColor*0.5, dstGab_center2);
       Screen('FillRect', window, black, FF2b);
       Screen('FillRect', window, white, FF2w);
       Screen('Flip', window);
   else
       baseRect = [0 0 200 250];
       [xCenter, yCenter] = RectCenter(windowRect);
       centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
       rectColor = [1 1 1];
       Screen('FillRect', window, rectColor*0.5, centeredRect);
       Screen('FillRect', window, black, FF2b);
       Screen('FillRect', window, white, FF2w);
       Screen('Flip', window);
  end
    WaitSecs(1);
       eyelink_stop_recording_and_write_variables(var_eye_link,staircaseArray(iSC).trialCount, orientation, [])

    end
% eyelink - close the edf file
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

save('global_param.mat','global_param'); % save the changes for the next tests 

% end of the script 
