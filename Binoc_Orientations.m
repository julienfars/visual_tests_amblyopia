%{
Welcome to the battery of tests used in the Amblyopia study. 
If you have questions about the tests, contact Juju (julien.fars@ndcn.ox.ac.uk)

This battery aims to test various functions of the amblyopic visual
experience. 

Third to go is the Binocular Orientations test. 
This test will be done in third. The resulting contrasts will be used to generate a contrast sensitivity curve for each condition: 
Amblyopic Eye (AE), Fellow Eye (FE) and Both Eyes (BE). 

!!! temp !!! may be removed if not working
The mean reversal contrasts measured during the contrast interleaved test (FE) are used here.

The parameters of this test (and the subsquent ones) are extracted from the GetGlobalVariables.m script and then are stored in the
global_param.mat variable.

If you use a different setting (different screen, distance from the screen,
size of stim etc...), change the parameters in the GetGlobalVariables.m
script. 

This battery of tests is using modified scripts from several research teams
and individuals. 
For the original version of these scripts, contact: 
- Alex S Baldwin - McGill Vision Research (for the staircase)
- Jun-Yun Zhang - Beijing Key Laboratory of Behavior and Mental Health (Dichoptic test)
- Alice Grasso McCaslin, School of Optometry, Indiana University (Asteroid test and related scripts)

It is also important to note that some functions present in the battery of tests were inspired from the
psychtoolbox tutorials of Peter Scarfe - Scarfe Lab (see https://peterscarfe.com/ptbtutorials.html)
%}

%changes to make it functional 
%{
- add training trials? 
%}

%% Setup
sca;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Binoc_Orientations.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths 

%% initialisation of eyelink

[dummymode, var_eye_link] = eyelink_init(1);
%% retrieve data from previous test

% will retrieve the global parameters file, and if it does not exist then 
% it will still set the parameters but set the cutoff frequency and contrasts to 0 
% meaning you need to specify it in the prompt
if isfile("global_param.mat")
    load("global_param.mat");
else
    global_param = GetGlobalVariables();
end

KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% Gets subject Info sets up experiment
prompt = {'Enter subject number:','Size of stimuli' , 'distance from screen', 'Enter the frequencies to test (AE):', 'Which eye is amblyopic?', 'name of edf file?', 'Eye tested', 'Normal observer? [yes/no]'}; %description of fields
defaults = {global_param.ID,num2str(global_param.stim_size),num2str(global_param.distance), '0.5 1 2 4', global_param.AMB_EYE, strcat(global_param.ID,'bo'), 'both', 'no'};%no default but the size (will be changed later) and the frequencies to test (we can then fremove some)
answer = inputdlg(prompt, 'Parameters',2,defaults); %opens dialog
SUBJECT = answer{1,:}; %Gets Subject Name
SIZE = answer{2,:};
SIZE = str2num(SIZE);
DISTANCE = str2num(answer{3,:}); 
FREQS_test = answer{4,:}; %Gets the list of frequencies used
FREQS_test = str2num(FREQS_test); %transform text into numericals 
AMB_EYE = answer{5,:};
edfFile = answer{6,:}; % should update name later, to be mindful of possible reruns
EYE_TEST = answer{7,:};
normal_testing = answer{8,:};

num_freqs = numel(FREQS_test); 

fixCross = true;

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
%Screen('ConfigureDisplay', 'Dithering', 1, ditherEnable);
%Screen('Preference', 'SuppressAllWarnings', 1); 
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

stereoMode = 100; 
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
[window, windowRect] = PsychImaging('OpenWindow',screenNumber,grey,[],[],[],stereoMode);

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

pix_size = 1/DIM_Screen_hor; % the size of 1 pixel in cm 
size_stim_pix = round(2*DISTANCE*tand(SIZE/2)/pix_size); % size of the stim in pixels, we round it so it is easier to display

E_min_size_dva = 1;
size_dva = 2*DISTANCE*tand(E_min_size_dva/2)/pix_size; % divide the freq in cpd by size_dva to obtain the size in cpp 
FREQS = FREQS_test./size_dva; % here we convert cpd (cycles per dva) in cpp (cycles per pixels) 


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
ifi = Screen('GetFlipInterval', window);

sc_num_freqs = [1];
scRightRules = repelem(sc_num_freqs,num_freqs);

%scRightRules    = [3, 3, 3, 3, 3, 3]; 
numStaircases   = length(scRightRules);

% set up of the keys used in this test
leftKey=KbName('LeftArrow');
rightKey=KbName('RightArrow');
upKey=KbName('UpArrow');
downKey=KbName('DownArrow');
escapeKey = KbName('ESCAPE');
spaceKey = KbName('SPACE');


    % these parameters control the staircase 
StimLevels      = log10(1):0.00001:log10(100); % stimulus levels from 1 to 100 (log) - which should provide around 60 steps
initStepSize    = 0.4;     % staircase step size before first reversal
stepSize        = 0.2;    % staircase step size after first reversal - has more reversals (see staircase code)
nWrongToAscend  = 1;        % number of "correct" responses before ascending
nRightToDescend = 1;        % number of "incorrect" responses before descending
maxNumTrials    = 30;       % maximum number of trials for each staircase
maxNumReversals = 8;        % maximum number of reversals for staircase
if contains(normal_testing, 'yes') 
    startLevel = log10(100);
else
    startLevel = log10(50);
end% starting level of staircase (50 should be manageable to begin with)
verbose         = 1;        % set to 1 for verbose staircase output

    for iSC = numStaircases:-1:1
        % number of "correct" responses before descending
        nRightToDescend = scRightRules(iSC);
        %nWrongToDescend = scWrongRules(iSC);

        % class constructor function returns staircase object
        staircaseArray(iSC) = staircase(StimLevels, initStepSize, ...
                                        stepSize, nRightToDescend,   ...
                                        nWrongToAscend, maxNumTrials, ...
                                        maxNumReversals, startLevel, verbose);
    end
    
exp_num = 1; %temp, see above
data_name = "data\" + SUBJECT + "_" + date + "_contrast_interleaved_" + ...
    exp_num + ".xls";
nb_table = length(FREQS);
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

    %% the staircase starts 

    % keep looping until all staircases conclude
    while ~all([staircaseArray(:).isFinished])
        
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
        %doubleScreen = true;
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
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);
    %second half cross
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, HC2);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);


    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
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
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC2);
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);

    Screen('Flip', window);
    WaitSecs(1);
    end


    % select a random unfinished staircase
    iSC = randi(numStaircases);
    while staircaseArray(iSC).isFinished
        iSC = randi(numStaircases);
    end
    

    if rand<0.5 % for each trial the orientation is set randomly, careful, it is reversed 
    %counterclockwise instead of clockwise!!!!!
    angular_1 = 7.1;
    angular_2 = 352.9;
    orientation_link = 353;
    else 
    angular_1 = 352.9;
    angular_2 = 7.1;
    orientation_link = 7;
    end


    %can add training trials here
        %{
        if staircaseArray(iSC).trialCount <= 1
            StimLevel = CONTRASTS_test(iSC)*100;
            StimLevel = log10(StimLevel);
            staircaseArray(iSC).curLevel = StimLevel;
        else
            StimLevel = staircaseArray(iSC).curLevel;% testing level from staircase
        end
        %}   
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
        sigma = 12;
        % make properties matrixes for the Gabors
        propertiesMatAE = [phase, freq, sigma, contrastAE, aspectRatio, 0, 0, 0];
        propertiesMatFE = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

        %% Eyelink Start trial
eyelink_start_trial(var_eye_link, staircaseArray(iSC).trialCount, orientation_link, [])

    
         %% display the stim
    if contains(AMB_EYE, 'Left') 
        buffer_num_AE = 0;
        buffer_num_FE = 1; 
        angle_AE = angular_2; % careful, reversed!!!
        angle_FE = angular_1; % careful, reversed!!!
        % careful this is not used to code the stim, only reflect the true
        % orientation in the results!!!
        angle_results_AE = angular_1;
        angle_results_FE = angular_2;
    else
        buffer_num_AE = 1;
        buffer_num_FE = 0;
        angle_AE = angular_1; % careful, reversed!!!
        angle_FE = angular_2; % careful, reversed!!!
        angle_results_AE = angular_2;
        angle_results_FE = angular_1;
    end

    dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
    dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter, yCenter);
    Screen('SelectStereoDrawBuffer',window,buffer_num_FE);
    Screen('DrawTextures', window, gabortex, [], dstGab_center1, angle_FE, [], [], [], [],...
    kPsychDontDoRotation, propertiesMatFE');
    Screen('FillRect', window, black, FF1b);
    Screen('FillRect', window, white, FF1w);

    dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
    dstGab_center2 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
    Screen('SelectStereoDrawBuffer',window,buffer_num_AE);
    Screen('DrawTextures', window, gabortex, [], dstGab_center2, angle_AE, [], [], [], [],...
    kPsychDontDoRotation, propertiesMatAE'); %careful!!! not the same size 
    Screen('FillRect', window, black, FF2b);
    Screen('FillRect', window, white, FF2w);

    % Flip to the screen
    beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);
    
    % Wait for a button press

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% time presentation 
   WaitSecs(0.2);
   %KbStrokeWait; % debug purposes!!!!!!

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
   
%% Wait for a button press


   onsetTime = GetSecs;

   timeSecs = KbWait;
   [ keyIsDown, t, keyCode ] = KbCheck;
   keyCode = find(keyCode, 1);
   %think about changing the loops so if the participant choose a key that
   %is not defined, the trial does not change
   if keyIsDown
       rt = t - onsetTime;
       if contains(var_eye_link, 'true')
        Eyelink('Message', 'KEY_PRESSED');
       end
    if keyCode == escapeKey
            break;
    elseif  keyCode==rightKey && angle_results_FE == 352.9  
% It means that the AE is chosen instead fo the FE
       if ~contains(normal_testing, 'yes') % if normal testing = no
% It means I must increase the FE contrast when testing amblyopes
           staircaseArray(iSC).doResp(1); % HERE
       else
 % It means I must decrease the AE contrast when testing normal observers          
           staircaseArray(iSC).doResp(0);
       end
       value = 'AE';
    elseif keyCode==leftKey && angle_results_FE == 7.1
        if ~contains(normal_testing, 'yes')
            staircaseArray(iSC).doResp(1);
        else 
            staircaseArray(iSC).doResp(0)
        end
            value = 'AE';
    else
        if ~contains(normal_testing, 'yes')
            staircaseArray(iSC).doResp(0);
        else
            staircaseArray(iSC).doResp(1);
        end
            value = 'FE';
    end
    KbReleaseWait;
    if keyCode==rightKey
        key = "right";
    elseif keyCode==leftKey
        key = "left";
    else
        key = "other";
    end
        % sending the Boolean (0 or 1) isCorrect to the staircase
        %staircaseArray(iSC).doResp(isSimCorrect); % calls "doResp" method of staircase

        % current rough estimate of threshold from staircase reversals
        % n.b. currently uses ALL reversals after the first reversal
        fprintf('Staircase %0.0f: current threshold from reversals: %0.2f +/- %0.2f\n\n', ...
                iSC, staircaseArray(iSC).curReversalThresh, staircaseArray(iSC).curReversalError)

    % get the x-y shift from the center into the variable Stim_position 
    Stim_position = HC1(1:2,3) - HC2(1:2,3);
    Stim_position = Stim_position'; % transpose 
    Stim_position = num2str(Stim_position);

    
    temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq, angle_AE, angle_FE, Stim_position, key, staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, contrastAE, contrast, rt, datetime('now'), EYE_TEST, AMB_EYE};
    
    counter_trial = counter_trial +1;
   end

    %here the calculation of the last six reversals FOR EACH STAIRCASE
    if staircaseArray(iSC).trialCount > 1 % only begins after the first/training trials 
        if temps{staircaseArray(iSC).trialCount,{'Reversal'}} ~= temps{staircaseArray(iSC).trialCount-1,{'Reversal'}} % only records when the number of reversals change 
            if contains(normal_testing, 'yes')
             mrt(staircaseArray(iSC).revCount+1,:) = {staircaseArray(iSC).revCount, contrastAE, iSC}; % recorded in a table titled mrt
            else   
             mrt(staircaseArray(iSC).revCount+1,:) = {staircaseArray(iSC).revCount, contrast, iSC}; % recorded in a table titled mrt
            end
        end
    end

    if staircaseArray(iSC).isFinished
    % check if this part keeps the previous plots open
        idx = any(mrt{:,1} > maxNumReversals-6,2); %alternative is to get all of the reversals and THEN remove some from the total in mrt_extracted                                   
        mrt_extracted = mrt(idx,:);
        idx2 = any(mrt_extracted{:,1} == iSC,2); 
        mrt_extracted = mrt_extracted(idx2,:);
        %mrt_extracted = mrt_extracted(:,3) == iSC;
        mean_reversals = mean(mrt_extracted{:,2});
        if isnan(mean_reversals) % in the case of having no reversals at all (get the last result)
            if contains(normal_testing, 'yes')
                mean_reversals = contrastAE;
            else
                mean_reversals = contrast;
            end
        end
        % the mean of reversals is then recorded on a new table 
        mt(iSC,:) = {iSC, FREQS_test(iSC), freq, mean_reversals};
        temps(counter_trial,:) = {iSC, FREQS_test(iSC), freq,0, 0, 'mean', 'reversals', staircaseArray(iSC).trialCount, staircaseArray(iSC).revCount, mean_reversals, 0, 0, datetime('now'), EYE_TEST, AMB_EYE};
        counter_trial = counter_trial+1;
    end

    %here the function for the plot staircase/values 
    if staircaseArray(iSC).isFinished
        plot_results(staircaseArray(iSC).isFinished, temps, mean_reversals, iSC);
    else % even if not finished the plot is displayed
        if contains(normal_testing, 'yes')
        plot_results(staircaseArray(iSC).isFinished, temps, contrastAE, iSC); 
        else   
        plot_results(staircaseArray(iSC).isFinished, temps, contrast, iSC); 
        end
    end

    if contains(var_eye_link, 'true')  
           Eyelink('Message', 'BLANK_SCREEN');
           WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
           Eyelink('StopRecording'); % Stop tracker recording
    end

   WaitSecs(0.5);

   eyelink_stop_recording_and_write_variables(var_eye_link,staircaseArray(iSC).trialCount, orientation_link, [])


    end

 % eyelink - close the edf file
 newName = ['Binoc_Orientations_', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);


 %% Clear screen
sca;
% export data table from staircase object into an xls file

%% result table
baseFileName = SUBJECT + "_" + date + '_binoc_orientation';

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);

writetable(temps,filename)

fprintf('Output saved in: %s\n', filename)

save('global_param.mat','global_param'); % save the changes for the next tests 
