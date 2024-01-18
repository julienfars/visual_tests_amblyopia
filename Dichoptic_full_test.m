%{
Welcome to the battery of tests used in the Amblyopia study. 
If you have questions about the tests, contact Juju (julien.fars@ndcn.ox.ac.uk)
This battery aims to test various functions of the amblyopic visual experience. 
The parameters of this test (and the subsequent ones) are extracted from the GetGlobalVariables.m script and then are stored in the
global_param.mat variable. If you use a different setting that the one
described in the study, please do change the parameters in
GetGlobalVariables.m
This battery of tests is using modified scripts from several research teams and individuals. 
For the original version of these scripts, contact: 
- Alex S Baldwin - McGill Vision Research (staircase protocol)
- Jun-Yun Zhang - Beijing Key Laboratory of Behavior and Mental Health (for the Dichoptic test)
- Alice Grasso McCaslin, School of Optometry, Indiana University (Asteroid test script and related functions)

It is also important to note that some functions present in the battery of tests were inspired from the
tutorials of Peter Scarfe - Scarfe Lab (see https://peterscarfe.com/ptbtutorials.html)
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

AssertOpenGL;

%% initialisation of eyelink
% then we initialise the eye link

[dummymode, var_eye_link] = eyelink_init(1); % will return variables that indicates that the eye link is ready to start (dummymode, var_eye_link)

%% Same patient? Retest? 
% This battery of test will be performed thrice on the same session (FE, AE and BE)
% And thrice for each participant (training, test and retest)

%%%%%%%%% pop-up window
prompt_second = {'is this a new patient? [true/false]'}; %description of fields
defaults_second = {'false'};
answer_second = inputdlg(prompt_second, 'Parameters',2,defaults_second); % opens dialog window
New_patient = answer_second{1,:};
%%%%%%%%%

if contains(New_patient, 'true')
    global_param = GetGlobalVariables(); % set up of a 'brand new' "global_param" structure file 
else
    if isfile("global_param.mat")
        load("global_param.mat");
    else
        global_param = GetGlobalVariables();
    end
end 

if isempty(global_param.dichop)
    start_noise = global_param.contrast_AE(3); % we take the third one as it should be the best option
else 
    start_noise = global_param.dichop; 
end

%%%%%%%%% pop-up window 
prompt_first = {'is this a retest? [true/false]'}; % description of fields
defaults_first = string(global_param.Retest); % default answer to this field
answer_first = inputdlg(prompt_first, 'Parameters',2,defaults_first); % opens dialog window
retest = answer_first{1,:};
%%%%%%%%%

% retest variable is set at false 
if contains(retest, 'true')
    global_param.Retest = true;
else
    global_param.Retest = false;
end

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...

%%%%%%%%% pop-up window
prompt = {'Enter subject number:', 'stimuli size', 'distance from screen', 'Which eye is amblyopic?', 'Noise contrast?', 'contrast discrimination threshold?', 'cut-off frequency', 'edf file name?', "Eye tested"}; %description of fields
defaults = {global_param.ID, num2str(global_param.stim_size), num2str(global_param.distance), 'Left', global_param.dichop, global_param.contrast_AE(3), global_param.cut_off_AE, strcat(global_param.ID,'d'),  'Both'};%default answers - last two could be num2str(global_param.contrast_FE), num2str(global_param.contrast_AE)
answer = inputdlg(prompt, 'Parameters',2,defaults); %opens dialog
SUBJECT = answer{1,:}; %Gets Subject Name
SIZE = str2double(answer{2,:}); %Gets size of the stim (0.29 is from the article)
DISTANCE = str2double(answer{3,:}); %Gets distance from the screen
AMB_EYE = answer{4,:}; %which eye is the amblyopic one 
NOISE = str2double(answer{5,:});% initial noise contrast
CONTRAST = str2num(answer{6,:}); %transform text into numericals 
CUTOFF = answer{7,:};
fixCross = true; 
edfFile = answer{8,:}; % should update name later, to be mindful of possible reruns
EYE_TEST = answer{9,:};
%%%%%%%%%

% CUTOFF
if contains(CUTOFF, '-') && isempty(global_param.cut_off_AE) % probably need to change this to reflect the potential absence of data
        CUTOFF = global_param.cut_off; 
    elseif contains(CUTOFF, '-')
        CUTOFF = global_param.cut_off_AE;
end

%this part asks again about the cut-off just to be sure 
prompt = {strcat('cut-off frequency','-',AMB_EYE)};
dims = [3 7];
definput = {CUTOFF};
answer = inputdlg(prompt,'Parameter',dims,definput);
CUTOFF = answer{1,:}; 
CUTOFF = str2num(CUTOFF);

%% Eyelink Parameters

[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen Parameters

if ismac % only for testing purposes, check if your system is compatible when doing real experiment 
    oldSyncLevel = Screen('Preference', 'SkipSyncTests', 1);
elseif isunix % linux platforms are generally fine
    Screen('Preference', 'SkipSyncTests', 0);
elseif ispc 
    oldSyncLevel = Screen('Preference', 'SkipSyncTests', 1);
    %Screen('Preference', 'SkipSyncTests', 0);
else
    disp('Platform not supported')
    return
end

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');
screenNumber = max(screens); % set the experiment on the last screen (will not change anything if you only have one screen)

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace value for white
grey = white / 2;
bgcontrast = 0.1;

stereoMode = 101; 
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
[window, windowRect] = PsychImaging('OpenWindow',screenNumber,[],[],[],[],stereoMode); % grey on the first []

Screen('SelectStereoDrawBuffer',window,0);
Screen('ColorRange', window, 1, 0);
Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast]); 

Screen('SelectStereoDrawBuffer',window,1);
Screen('ColorRange', window, 1, 0);
Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast]); %bgcontrast

% Instead of returning width and height of the graphics window/screen in pixels
% using this [width, height] = Screen('WindowSize', window); 
% we do 
width = windowRect(3);
height = windowRect(4);
% we must adapt the stimuli to the current size of the window (related to stereomode)

%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)

[el] = eyelink_calibration(var_eye_link,window, stereoMode, [], width, height);

%% Other Parameters
HideCursor(); %hides the cursor
KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue - keyboard inputs are considered now
[xCenter, yCenter] = RectCenter(windowRect);

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test

eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
% will start if the participant has starbismus AND is testing BE 

[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters

DIM_Screen_hor = windowRect(3)/global_param.screen_size(2); % we get the number of pixels per mm
DIM_Screen_ver = windowRect(4)/global_param.screen_size(1);
SIZE_mm = 2*DISTANCE*tand(SIZE/2); % convert the size of stim from dva to mm
gaborDimPix1 = DIM_Screen_ver*SIZE_mm; % here from mm to pix using the number of pixels per mm
gaborDimPix2 = DIM_Screen_hor*SIZE_mm;
gaborDimPix = round((max([gaborDimPix1 gaborDimPix2])+min([gaborDimPix1 gaborDimPix2]))/2); % we round it so we can keep a regular dva 

PixelPerDeg=gaborDimPix/SIZE; % horizontal size in pix

% Initial stimulus params for the grating:
virtualSize = gaborDimPix;
phase = 0;
freq = 0.4*CUTOFF; % following Liu & Zhang paper, we only use 40% of the cut-off frequency
tilt = 0;
contrast_high = 0.8;
contrast_low = abs(exp(-1.6*CONTRAST)-0.2);
%contrast_low = (0.8 - ((CONTRAST)*1.414));
% fplot(@(x) (0.8 - ((x)*1.414)),[0 1])
% fplot(@(x) abs(exp(-1.6*x)-0.2),[0 1]) % YES! better way to do it

% radius of the disc edge
radius = virtualSize / 2;
% smoothing sigma in pixel
sigma = 55;
% use alpha channel for smoothing?
useAlpha = true;
% smoothing method: cosine (0) or smoothstep (1) or inverse smoothstep (2)
smoothMethod = 1;

% the following function creates sine gratings and not gabor patches. As a
% reminder, a gabor patch is sine grating multplied by a gaussian window.
% This is what transform a sine grating (squre shaped grating) in a gabor
% patch (circular grating with fading edges). BUT this function also
% handles apertures (for the circular shape) AND smoothing edges. We can
% therefore reproduce a gabor patch 'artificially'. Ther reason why we use
% this function instead of the regular gabor one is because of the
% incompatibility between the gabor function/texture and the noise texture
% when mixed using the stereovision. 
sinetex = CreateProceduralSmoothedApertureSineGrating(window, virtualSize, virtualSize,...
          [.5 .5 .5 1], radius, [], sigma, useAlpha, smoothMethod);

% Set Up how many Gabors there are
nGabors = 2;

xPos = xCenter;
yPos = ceil(yCenter-(gaborDimPix/2)/2); % the top gabor
gap = (gaborDimPix/2); % in pixels 

% Make the destination rectangles for all the Gabors in the array
baseRect = [0 0 1 0.5] .* gaborDimPix;
allRects = nan(4, nGabors);
allRects(:, 1) = CenterRectOnPointd(baseRect, xPos, yPos);
allRects(:, 2) = CenterRectOnPointd(baseRect, xPos, yPos+gap);

propertiesMat = repmat([phase, freq, contrast_high, 0],...
    nGabors, 1);

Screen('DrawTexture', window, sinetex, [], [], tilt, [], [], [], [], [], [0,1,0,0]);

Priority(MaxPriority(window));

%% Staircases 

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% set up of the keys used in this test
leftKey=KbName('LeftArrow');
rightKey=KbName('RightArrow');
upKey=KbName('UpArrow');
downKey=KbName('DownArrow');
escapeKey = KbName('ESCAPE');
spaceKey = KbName('SPACE');
start_trial_key = KbName('a');

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

sz = [maxNumTrials+1;13];
varTypes = ["double","double","double","double","double","string", "string", "double", "string",  "string", "string", "double","datetime"];
varNames = ["Trial","Reversal","Level", "Contrast low", "Contrast high","value", "key", "orientation", "Position", "AMB", "Eye", "RT","time"];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

%% Mean reversals table 
% the mean reversals table is generated here (optimisation reasons)
% this table will not be saved after the test but we use it to generate the threshold

mr = [maxNumReversals;2];
varTypes2 = ["double", "double"];
varNames2 = ["Reversal  Number", "Value"];
mrt = table('Size',mr,'VariableTypes',varTypes2,'VariableNames',varNames2);

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
    
% here is the arrows
    % first let's get the size of the noise 
    sidesize = 240;% was 240, was 390
    dstGab_centerN = [0 0 1 0.5] .* sidesize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);

    xhead = xCenter;%1
    xheadleft = xCenter-(sidesize/4);%2
    xheadright = xCenter+(sidesize/4);%3
    xbaseleft = xCenter-(sidesize/8); %4
    xbaseright = xCenter+(sidesize/8);%5

    %DOWN
    yhead = yCenter+(sidesize/6);
    yheadside = yCenter;
    ybase = yCenter-(sidesize/6);

    %the UP and DOWN 
    xPosVectorUP = [xhead xheadright xbaseright xbaseright xbaseleft xbaseleft xheadleft xhead]; % is it the down one?Yes
    yPosVectorUP = [yhead yheadside yheadside ybase ybase yheadside yheadside yhead];
    
    % fixed 
    xPosVectorDOWN = [xhead xheadright xbaseright xbaseright xbaseleft xbaseleft xheadleft xhead]; % this is the up one?Yes 
    yPosVectorDOWN = [ybase yheadside yheadside yhead yhead yheadside yheadside ybase];

    UP_side = [xPosVectorUP; yPosVectorUP];
    DOWN_side = [xPosVectorDOWN; yPosVectorDOWN];
    % Cue to tell PTB that the polygon is convex (concave polygons require much
    % more processing)
    isConvex = 1;

    if rand<0.5 % for each trial the orientation is set randomly, careful, it is reversed 
        %counterclockwise instead of clockwise!!!!!
    orientation = 90-45;
    else 
    orientation = 90+45;
    end

    [seed,whichGen] = ClockRandSeed();

    EccH=420;
    centerHsti=round(windowRect(3))/2-EccH;

    %change 80 by 0.8 if needed (80 in %)
    if rand<0.5 % the good answer is the bottom one
    
        propertiesMat(1,3) = contrast_low;
       propertiesMat(2,3) = contrast_high;  
        
       ARROW_X = xPosVectorUP;
       ARROW_Y = yPosVectorUP;
       
       acc_resp = 'bottom';
    else % the good answer is the top one
       propertiesMat(1,3) = contrast_high;
        propertiesMat(2,3) = contrast_low;   
     
       ARROW_X = xPosVectorDOWN;
       ARROW_Y = yPosVectorDOWN;

       acc_resp = 'top';
    end

    %sum_zero = sum(Gabor_up(:,locCy1)==0);
    %proportion = 1-(sum_zero/length(Gabor_up));
    %gaborDimPix = round(((DIM_Screen_ver*SIZE_mm+DIM_Screen_hor*SIZE_mm)/2)/proportion); % we round it so we can keep a regular dva 

    if rand<0.2 %rand<0.2
       ATT_TRIAL = 'true';
    else 
        ATT_TRIAL = 'false';
    end

    % here the primer coordinates
    LeftTopCorner = HC1(1:2,3);
    RightTopCorner = HC1(1:2,4);
    LeftBottomCorner = HC1(1:2,5);
    RightBottomCorner = HC1(1:2,6);
    ARROWLT_1 = [LeftTopCorner(1); LeftTopCorner(2); LeftTopCorner(1)+20; LeftTopCorner(2)+5];
    ARROWLT_2 = [LeftTopCorner(1); LeftTopCorner(2); LeftTopCorner(1)+5; LeftTopCorner(2)+20];
    ARROWLT = [ARROWLT_1,ARROWLT_2];

    ARROWRT_1 = [RightTopCorner(1)-20+90; RightTopCorner(2); RightTopCorner(1)+90; RightTopCorner(2)+5];
    ARROWRT_2 = [RightTopCorner(1)-5+90; RightTopCorner(2); RightTopCorner(1)+90; RightTopCorner(2)+20];
    ARROWRT = [ARROWRT_1,ARROWRT_2];

    ARROWLB_1 = [LeftBottomCorner(1); LeftBottomCorner(2)-5+45; LeftBottomCorner(1)+20; LeftBottomCorner(2)+45];
    ARROWLB_2 = [LeftBottomCorner(1); LeftBottomCorner(2)-20+45; LeftBottomCorner(1)+5; LeftBottomCorner(2)+45];
    ARROWLB = [ARROWLB_1,ARROWLB_2];

    ARROWRB_1 = [RightBottomCorner(1)-20+90; RightBottomCorner(2)-5+45; RightBottomCorner(1)+90; RightBottomCorner(2)+45];
    ARROWRB_2 = [RightBottomCorner(1)-5+90; RightBottomCorner(2)-20+45; RightBottomCorner(1)+90; RightBottomCorner(2)+45];
    ARROWRB = [ARROWRB_1,ARROWRB_2];
    penWidthPixels = 6;

    %% Eyelink Start trial
eyelink_start_trial(var_eye_link, sc.trialCount, orientation, [])

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

    
%% AMB LEFT - TRIAL FALSE
    if contains(AMB_EYE, 'Left') && contains(ATT_TRIAL, 'false')

    % here the primer (to get attention from the participant - do not confuse it with the attention trials)
    repeatNoise = false;

    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, black, ARROWLT, penWidthPixels);
    Screen('FillRect', window, black, ARROWRT, penWidthPixels);
    Screen('FillRect', window, black, ARROWLB, penWidthPixels);
    Screen('FillRect', window, black, ARROWRB, penWidthPixels);
    Screen('Flip', window);
    WaitSecs(0.2);
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('Flip', window);
    WaitSecs(0.2);
   

    
    % then we launch the gabors and noise
    %dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
    %dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', window, sinetex, [], allRects(:,1), orientation, [], [], [], [], [], propertiesMat(1,:));
    Screen('DrawTexture', window, sinetex, [], allRects(:,2), orientation, [], [], [], [], [], propertiesMat(2,:));

    dstGab_centerN = [0 0 1 0.5] .* texSize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);

    Screen('Blendfunction', window, GL_ONE, GL_ZERO);
    Screen('DrawDots', window, [xCenter yCenter], 1500, [0.5 0.5 0.5 fgcontrast], [], 3); % was 500
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE);


    Screen('DrawTextures', window, noiseTexture, [], dstGab_centerN, [], 0);
    Screen('DrawingFinished', window);




%% AMB RIGHT - NO TRIAL
    elseif contains(AMB_EYE, 'Right') && contains(ATT_TRIAL, 'false') 
    
    repeatNoise = false;

    % here the primer (to get attention from the participant - do not confuse it with the attention trials)
   
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, ARROWLT,penWidthPixels);
    Screen('FillRect', window, black, ARROWRT,penWidthPixels);
    Screen('FillRect', window, black, ARROWLB,penWidthPixels);
    Screen('FillRect', window, black, ARROWRB,penWidthPixels);
    Screen('Flip', window);
    WaitSecs(0.2);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('Flip', window);
    WaitSecs(0.2);
    
  
 % then we launch the gabors and noise
    %dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
    %dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('DrawTexture', window, sinetex, [], allRects(:,1), orientation, [], [], [], [], [], propertiesMat(1,:));
    Screen('DrawTexture', window, sinetex, [], allRects(:,2), orientation, [], [], [], [], [], propertiesMat(2,:));
   
    dstGab_centerN = [0 0 1 0.5] .* texSize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);

    Screen('Blendfunction', window, GL_ONE, GL_ZERO);
    Screen('DrawDots', window, [xCenter yCenter], 1500, [0.5 0.5 0.5 fgcontrast], [], 3);
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE);

    Screen('DrawTextures', window, noiseTexture, [], dstGab_centerN, [], 0);
    Screen('DrawingFinished', window);

 
    %% AMB LEFT - TRIAL TRUE
    elseif  contains(AMB_EYE, 'Left') && contains(ATT_TRIAL, 'true')
% here the primer (to get attention from the participant - do not confuse it with the attention trials)
    repeatNoise = true;
    repNOISE = NOISE;
    
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, black, ARROWLT,penWidthPixels);
    Screen('FillRect', window, black, ARROWRT,penWidthPixels);
    Screen('FillRect', window, black, ARROWLB,penWidthPixels);
    Screen('FillRect', window, black, ARROWRB,penWidthPixels);
    Screen('Flip', window);
    WaitSecs(0.2);
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('Flip', window);
    WaitSecs(0.2);    
    
   % put the arrow here 
    Screen('SelectStereoDrawBuffer',window,1);

    dstGab_centerN = [0 0 1 0.5] .* texSize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);

    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);

    Screen('Blendfunction', window, GL_ONE, GL_ZERO);
    Screen('DrawDots', window, [xCenter yCenter], 1500, [0.5 0.5 0.5 fgcontrast], [], 3); %was 500
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE);

    Screen('DrawTextures', window, noiseTexture, [], dstGab_centerN, [], 0);

    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillPoly', window, white, [ARROW_X; ARROW_Y]', isConvex);
    Screen('DrawingFinished', window);


    %% AMB RIGHT - TRIAL TRUE
    elseif contains(AMB_EYE, 'Right') && contains(ATT_TRIAL, 'true')
    % here the primer (to get attention from the participant - do not confuse it with the attention trials)
    repeatNoise = true;
    repNOISE = NOISE;

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, ARROWLT,penWidthPixels);
    Screen('FillRect', window, black, ARROWRT,penWidthPixels);
    Screen('FillRect', window, black, ARROWLB,penWidthPixels);
    Screen('FillRect', window, black, ARROWRB,penWidthPixels);
    Screen('Flip', window);
    WaitSecs(0.2);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('Flip', window);
    WaitSecs(0.2);


    % put the arrow here 
    Screen('SelectStereoDrawBuffer',window,0);
    dstGab_centerN = [0 0 1 0.5] .* texSize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);

    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);

    Screen('Blendfunction', window, GL_ONE, GL_ZERO);
    Screen('DrawDots', window, [xCenter yCenter], 1500, [0.5 0.5 0.5 fgcontrast], [], 3);
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE);

    Screen('DrawTextures', window, noiseTexture, [], dstGab_centerN, [], 0);

    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillPoly', window, white, [ARROW_X; ARROW_Y]', isConvex);
    Screen('DrawingFinished', window);


    end

    % Flip to the screen
     % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);

    
%% Wait for a button press

    onsetTime = GetSecs;
    WaitSecs(0.2);
    
    baseRect = [0 0 512 256];
    [xCenter, yCenter] = RectCenter(windowRect);
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    rectColor = [1 1 1];
    dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
    dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
    if contains(AMB_EYE, 'Left') 
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_center1);
    else 
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_center1);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);
    end
    Screen('DrawingFinished', window);
    Screen('Flip', window);
    
    % Wait for a button press
 
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
    if repeatNoise == false
        if keyCode == escapeKey
                break;
        elseif  keyCode==upKey && contains(acc_resp, 'top')
                sc.doResp(1); 
                value = 'TRUE';
                
        elseif  keyCode==downKey && contains(acc_resp, 'bottom')
                sc.doResp(1);
                value = 'TRUE';
                
        else
                sc.doResp(0);
                value = 'FALSE';
        end
    else 
        if keyCode == escapeKey
                break;
        elseif  keyCode==upKey && contains(acc_resp, 'top')
                value = 'ATT_TRUE';
                
        elseif  keyCode==downKey && contains(acc_resp, 'bottom')
                value = 'ATT_TRUE';
                
        else
                value = 'ATT_FALSE';
                att_test = att_test+1;
                if att_test >= 5
                    break
                end
        end
        sc.trialCount = sc.trialCount+1;
    end

    if contains(value, 'TRUE') || contains(value, 'ATT_TRUE') 
        WaitSecs(0.05);
                beep;
    end

    KbReleaseWait;
    if keyCode==upKey
        key = "up";
    elseif keyCode==downKey
        key = "down";
    else
        key = "other";
    end
    fprintf('Current threshold from reversals: %0.2f +/- %0.2f\n\n', ...
            sc.curReversalThresh, sc.curReversalError)
    

    % get the x-y shift from the center into the variable Stim_position 
    Stim_position = HC1(1:2,3) - HC2(1:2,3);
    Stim_position = Stim_position'; % transpose 
    Stim_position = num2str(Stim_position);

    temps(sc.trialCount,:) = {sc.trialCount, sc.revCount, NOISE, contrast_low, contrast_high, value, key, orientation, Stim_position, AMB_EYE, EYE_TEST, rt, datetime('now')};
    
            %here the calculation of the last six reversals
            if sc.trialCount > 1 % only begins after the training trials 
                if temps{sc.trialCount,2} ~= temps{sc.trialCount-1,2} % only records when the number of reversals change 
                    mrt(sc.revCount,:) = {sc.revCount, NOISE}; % recorded in a table titled mrt
                end
            end
            
            % when the staircase is finished, we calculate the mean of
            % reversals from the mrt table
            if sc.isFinished
                idx = any(mrt{:,1}>maxNumReversals-6,2); %alternative is to get all of the reversals and THEN remove some from the total in mrt_extracted                                   
                mrt_extracted = mrt(idx,:);
                mean_reversals = mean(mrt_extracted{:,2});
                % the mean of reversals is then recorded at the end of the
                % table
                %careful not working here, MUST FIX
                temps(sc.trialCount+1,:) = {sc.trialCount+1, sc.revCount, mean_reversals,contrast_low, contrast_high, 'MEAN', 'reversal', 0, Stim_position, AMB_EYE, EYE_TEST, 0, datetime('now')};
            end
                %here the function for the plot staircase/values (needs to be modified for compatibility with all the tests)
            if sc.isFinished
                plot_results(sc.isFinished, temps, mean_reversals, []);
            else % even if not finished the plot is displayed
                plot_results(sc.isFinished, temps, NOISE, []); 
            end
   if contains(var_eye_link, 'true')  
           Eyelink('Message', 'BLANK_SCREEN');
           WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
           Eyelink('StopRecording'); % Stop tracker recording
    end

   end
  
end
Priority(0);

% eyelink - close the edf file
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

save('global_param.mat','global_param'); % save the changes for the next tests 

% end of the script 