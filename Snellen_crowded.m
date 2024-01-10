%{
Welcome to the battery of tests used in the Amblyopia study. 
If you have questions about the tests, contact Juju (julien.fars@ndcn.ox.ac.uk)

This battery aims to test various functions of the amblyopic visual
experience. 

Contrary to the other tests, Snellen and Snellen Crowded need another way
of making the stereomode. Instead on using the vertical dimension for the
interleaved pixels, We could use the horizontal pixels (stereomode 101 instead of 100). BUT there is a risk of
not having enough pixels to take in account the participants' strabisma. 
If none of these problems can be fixed, then we might abandon the binocular measurements for the
snellen and snellen crowded (especially this last one - larger).

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
work of Peter Scarfe - Scarfe Lab (see https://peterscarfe.com/ptbtutorials.html)
%}



%% Setup
clear all;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Snellen_crowded.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths (useful to save the files at the end of the test)

%% retrieve info from previous test 

% will retrieve the global parameters file, and if it does not exist then 
% it will still set the parameters but set the cutoff to 0 
% meaning you need to specify it in the prompt
if isfile("global_param.mat")
    load("global_param.mat");
else
    global_param = GetGlobalVariables();
end

KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% Gets subject Info sets up experiment
prompt = {'Enter subject number:', 'distance from screen', 'Which eye is tested?', 'Amblyopic eye?', 'fixation cross?'}; %description of fields
defaults = {global_param.ID, num2str(global_param.distance_Snellen),global_param.EYE_TEST, global_param.AMB_EYE, 'true'};%no default but the size (will be changed later) and the frequencies to test (we can then fremove some)
answer = inputdlg(prompt, 'Parameters',2,defaults); %opens dialog
SUBJECT = answer{1,:}; %Gets Subject Name
DISTANCE = str2double(answer{2,:}); 
EYE_TEST = answer{3,:};
AMB_EYE = answer{4,:};
Glasses = answer{5,:}; %used later in the code, use false for monocular tests

if contains(AMB_EYE, 'Both') && contains(Glasses, 'true')
    fixCross = 'true';
else
    fixCross = 'false';
end
    fixCross = strcmp(fixCross,'true'); %convert string to boolean
    
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

if fixCross == true %later, use "if EYE_TEST == "both" for this conditional"
stereoMode = 100; %see how it goes with 101, try 100 later as well 
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
[window, windowRect] = PsychImaging('OpenWindow',screenNumber,grey,[],[],[],stereoMode);
%now I have to add a value that will change the size of all horizontal
%values (and also gaborDimPix? hmm, this could be an issue)
else
stereoMode = [];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
end

% Instead of returning width and height of the graphics window/screen in pixels
% using this [width, height] = Screen('WindowSize', window); 
% we do 
width = windowRect(3);
height = windowRect(4);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

HideCursor(); %hides the cursor
KbName('UnifyKeyNames'); %used for cross-platform compatibility of keynaming
KbQueueCreate; %creates cue using defaults
KbQueueStart;  %starts the cue


%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)

%% pixels to move the half crosses 
pixelsPerPress = 1;%numbers of pixels to move from with each button press 


%% Basic Snellen parameters
    % Here we set the size of the lines of our Snellen E --> then we create
    % a texture, because we can then change its size and orientation

    E_shape = [0 0 0 0 0; 0 0.5 0.5 0.5 0.5 ; 0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0]; % 0.5 is for grey and 0 is for black

% Make the shape into a texure (5 x 5 pixels)
E_texture = Screen('MakeTexture', window, E_shape);
% size of the Snellen E must be determined by the optotypes 


%% size calculation 
% for monocular setting
    DIM_Screen_hor = windowRect(3)/global_param.screen_size(2); % we get the number of pixels per mm
    DIM_Screen_ver = windowRect(4)/global_param.screen_size(1);
    pix_size = 1/DIM_Screen_hor; % the size of 1 pixel in mm 
    E_min_size = 5*pix_size; %in mm 
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE); %in dva, this 
    % correspond to the degree of visual angle of the smallest Snellen E 
    % texture (depends on the distance) 
    % Snellen charts are calculated using MAR (maximum angle of resolution)
    % Which is set at 1 minute of arc (1/60 of a degree)
    MAR = 2*atand((pix_size/2)/DISTANCE) * 60; % the angle of resolution (optotype)
    % of the smallest stim possible (using the actual resolution+screen)
    logMAR = log10(MAR); %the lower range of acuity that can be calculated

% for binocular setting 
    % remember that the resolution is halved, therfore a 1920x1080 would 
    % become a 960x1080 (display++, stereotest = 101)
    % to finish
    
% for the calculations the optotype size is determined in pixels (1 = 1 pix)
    opto_size = [];
    % this is the value that will vary with each trial

    % binocular testing - maximum optotypte size
    % Be even more careful -> the dimension that will be halved will be
    % used as a limiting factor. If stereotest = 101, res = 960x1080; if
    % sterotest = 100, res = 1920x540. To keep a large snellen, choice has
    % been made to use the horizontal size (and keep a larger range)
    % HOWEVER, each milimeter of deviation (squint) shifts the stim of 7
    % degrees, which correspond to 600pix !!! Because most of strabismic
    % participant will present Eso-Exotropia, we have to consider keeping
    % stereotest = 100 OR use prisms to reduce the shifting amount

        % TBC
    if fixCross==true
        max_opto_size = 58; % just to set up the staircase, will be modified later
    else
        % monucular testing - maximum optotype size
        % careful, with crowded E, the minimum size is now larger BUT it
        % does not change the concept - participants still have to see the
        % optotypes indicating the direction of E. Therefore no changes to
        % add to this part. We just have to ensure the max optotype will
        % stay inside the screen. 
        [min_res,idx]= min(windowRect(3:4));
        base_size = (5*3)+2; %17 pixels is the minimum size of a whole crowded E (E + _ + E + _ + E)
        max_opto_size = round(min_res/base_size, -1) -2; % this size of optotype will 
        % keep the largest E inside the screen      
    end

        pixel_shift = opto_size; % here is the variable that decides of the shifts
    % between the crowded E s - not used at the moment

%% Staircase parameters
ifi = Screen('GetFlipInterval', window);

% set up of the keys used in this test
leftKey=KbName('LeftArrow');
rightKey=KbName('RightArrow');
upKey=KbName('UpArrow');
downKey=KbName('DownArrow');
escapeKey = KbName('ESCAPE');
spaceKey = KbName('SPACE');


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
sz = [maxNumTrials+1;16];
varTypes = ["double","double","double", "double","string","string", "string", "double", "double", "double", "double", "double", "string", "string", "double","datetime"];
varNames = ["Trial","Reversal","Level", "LogMar","value", "key", "Position", "orientation center", "orientation left", "orientation top", "orientation bottom", "orientation right","Eye", "AMB", "RT","time"];
temps = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

%% creating the mean reversals table (for the calculation of the mean/threshold)
mr = [maxNumReversals;2];
varTypes2 = ["double", "double"];
varNames2 = ["Reversal  Number", "Value"];
mrt = table('Size',mr,'VariableTypes',varTypes2,'VariableNames',varNames2);

%% Staircase loop 

% will determine which side of the crosses will be moving (along with one copy of the fusion frame)
    if contains(AMB_EYE, 'Left')
            HC1 = HCl;
            HC2 = HCr;
        else
            HC1 = HCr;
            HC2 = HCl;
    end

    %% launch the experiment staircase

doubleScreen = false;

while ~sc.isFinished           % keep looping until staircase concludes
    while fixCross == true
    
    vbl = Screen('Flip', window);
    waitframes = 1; 
    exitFixCross = false;
    while exitFixCross == false

    % Check the keyboard to see if a button has been pressed
    [keyIsDown, secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(escapeKey)
        exitFixCross = true; %I doubled the while loop just to be sure it goes to the next step - must change later
        fixCross = false;
        doubleScreen = true;

    elseif keyCode(leftKey) % each short press of the key moves the cross+frame of one pixel
        HC1(1,:)  = HC1(1,:)  - pixelsPerPress;
        HC1(3,:)  = HC1(3,:)  - pixelsPerPress;
    elseif keyCode(rightKey)
        HC1(1,:)  = HC1(1,:)  + pixelsPerPress;
        HC1(3,:)  = HC1(3,:)  + pixelsPerPress;
    elseif keyCode(upKey)
        HC1(2,:)  = HC1(2,:)  - pixelsPerPress;
        HC1(4,:)  = HC1(4,:)  - pixelsPerPress;
    elseif keyCode(downKey)
        HC1(2,:)  = HC1(2,:)  + pixelsPerPress;
        HC1(4,:)  = HC1(4,:)  + pixelsPerPress;
    elseif keyCode(spaceKey) % if the spacekey is pressed, then the cross+frame go back to the centre of the display
         if contains(AMB_EYE, 'Left')
            HC1 = HCl;
            HC2 = HCr;
            else
            HC1 = HCr;
            HC2 = HCl;
         end
    end
    
% here the part of the code that would set the staircase (only for trial = 1)

    % Draw the half crosses to the screen
    %first half cross
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, black, HC1);
    %second half cross
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, HC2);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    if contains(AMB_EYE, 'Left')
        diff(:,1) = HC1(:,1)-HCl(:,1);
    else
        diff(:,1) = HC1(:,1)-HCr(:,1);
    end
    end

    rectColor = [1 1 1];

    % this part is "washing up" the screen
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, rectColor*0.5, HC1);

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC2);
    WaitSecs(1);
    end
    
    crowd = [E_texture E_texture E_texture E_texture E_texture];
    E_rand_num = rand(1,5);
    E_rand_orientation = zeros(1,5);
    i=1;
    for x = E_rand_num
        if x<=0.25 % for each trial the orientation is set randomly
            orientation = 90;
            E_shape = [0 0 0 0 0; 0 0.5 0 0.5 0 ; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0;0 0.5 0 0.5 0];
            E_texture = Screen('MakeTexture', window, E_shape);
        elseif x>0.25 && rand<=0.5 
            orientation = 180;
            E_shape = [0 0 0 0 0; 0.5 0.5 0.5 0.5 0; 0 0 0 0 0; 0.5 0.5 0.5 0.5 0; 0 0 0 0 0];
            E_texture = Screen('MakeTexture', window, E_shape);
        elseif x>0.5 && rand<=0.75
            orientation = 270;
            E_shape = [0 0.5 0 0.5 0 ; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0;0 0.5 0 0.5 0; 0 0 0 0 0];
            E_texture = Screen('MakeTexture', window, E_shape);
        else 
            orientation = 0;
            E_shape = [0 0 0 0 0; 0 0.5 0.5 0.5 0.5 ; 0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0];
            E_texture = Screen('MakeTexture', window, E_shape);
        end
        E_rand_orientation(1,i)=orientation;
        crowd(1,i) = E_texture;
        i = i+1;
    end

    StimLevel = sc.curLevel;          % testing level from staircase
    opto_size = StimLevel;
    filterMode = 0;

%% display the stim
    if doubleScreen == true 
    [s1, s2] = size(E_shape);
    
    for i = [1 2 3 4 5]
        if E_rand_orientation(i) == 180 || E_rand_orientation(i) == 0
          dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size; %opto_size, need to be changed
          dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter); %check if it messed up due to the interleaved
          dstRect_center(i,1:4) = dstRect_center_s;
        else
          dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size; %opto_size, need to be changed
          dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter); %check if it messed up due to the interleaved
          dstRect_center(i,1:4) = dstRect_center_s;
        end
    end
   
    %dstRect_center = [0 0 s1 s2*0.5] .* opto_size; %opto_size, need to be changed
    %dstRect_center = CenterRectArrayOnPoint(dstRect_center, xCenter, yCenter);

    Left = round(xCenter-5*opto_size*2*0.75); %remove last 0.75 to have full opto size between the two E
    Right = round(xCenter+5*2*opto_size*0.75); 
    Bottom = round(yCenter-5*opto_size*0.75); 
    Up = round(yCenter+5*opto_size*0.75); 

    dstRect_left = CenterRectArrayOnPoint(dstRect_center(2,:), Left, yCenter);
    dstRect_right =  CenterRectArrayOnPoint(dstRect_center(3,:), Right, yCenter);
    dstRect_bottom =  CenterRectArrayOnPoint(dstRect_center(4,:), xCenter, Bottom);
    dstRect_top =   CenterRectArrayOnPoint(dstRect_center(5,:), xCenter, Up);
    
    if opto_size <= 2
        dstRect_top = dstRect_top + [0 -1 0 -1];
    end

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('DrawTextures', window, crowd(1), [],...
    dstRect_center(1,:), [], filterMode);
    Screen('DrawTextures', window, crowd(2), [],...
    dstRect_left, [], filterMode);
    Screen('DrawTextures', window, crowd(3), [],...
    dstRect_top, [], filterMode);
    Screen('DrawTextures', window, crowd(4), [],...
    dstRect_bottom, [], filterMode);
    Screen('DrawTextures', window, crowd(5), [],...
    dstRect_right, [], filterMode);
    
    %now the second one
    [s1, s2] = size(E_shape);

    for i = 1:5 % I should have made it differently instead of just duplicating but did not get another idea 
        if E_rand_orientation(i) == 180 || E_rand_orientation(i) == 0
          dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size; %opto_size, need to be changed
          dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter+diff(1,:), yCenter+diff(2,:)); %check if it messed up due to the interleaved
          dstRect_center(i,1:4) = dstRect_center_s;
        else
          dstRect_center_s = [0 0 s1 s2*0.5] .* opto_size; %opto_size, need to be changed
          dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter+diff(1,:), yCenter+diff(2,:)); %check if it messed up due to the interleaved
          dstRect_center(i,1:4) = dstRect_center_s;
        end
    end
    %dstRect_center = [0 0 s1 s2*0.5] .* opto_size; %opto_size, need to be changed
    %dstRect_center = CenterRectArrayOnPoint(dstRect_center, xCenter+diff(1,:), yCenter+diff(2,:)); %check if it messed up due to the interleaved
    
    Left = round(xCenter-5*opto_size*2*0.75);%changed
    Right = round(xCenter+5*2*opto_size*0.75);%changed
    Bottom = round(yCenter-5*opto_size*0.75);
    Up = round(yCenter+5*opto_size*0.75);

    dstRect_left = CenterRectArrayOnPoint(dstRect_center(2,:), Left+diff(1,:), yCenter+diff(2,:));
    dstRect_right =  CenterRectArrayOnPoint(dstRect_center(3,:), Right+diff(1,:), yCenter+diff(2,:));
    dstRect_bottom =  CenterRectArrayOnPoint(dstRect_center(4,:), xCenter+diff(1,:), Bottom+diff(2,:));
    dstRect_top =   CenterRectArrayOnPoint(dstRect_center(5,:), xCenter+diff(1,:), Up+diff(2,:));

    if opto_size <= 2
        dstRect_top = dstRect_top + [0 -1 0 -1];
    end

    Screen('SelectStereoDrawBuffer',window,0);
    Screen('DrawTextures', window, crowd(1), [],...
    dstRect_center(1,:), [], filterMode);
    Screen('DrawTextures', window, crowd(2), [],...
    dstRect_left, [], filterMode);
    Screen('DrawTextures', window, crowd(3), [],...
    dstRect_top, [], filterMode);
    Screen('DrawTextures', window, crowd(4), [],...
    dstRect_bottom, [], filterMode);
    Screen('DrawTextures', window, crowd(5), [],...
    dstRect_right, [], filterMode);
    
    else
    [s1, s2] = size(E_shape);

    for i = [1 2 3 4 5]
        if E_rand_orientation(i) == 180 || E_rand_orientation(i) == 0
          dstRect_center_s = [0 0 s1 s2] .* opto_size; %opto_size, need to be changed
          dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter); %check if it messed up due to the interleaved
          dstRect_center(i,1:4) = dstRect_center_s;
        else
          dstRect_center_s = [0 0 s1 s2] .* opto_size; %opto_size, need to be changed
          dstRect_center_s = CenterRectArrayOnPoint(dstRect_center_s, xCenter, yCenter); %check if it messed up due to the interleaved
          dstRect_center(i,1:4) = dstRect_center_s;
        end
    end
   
  
    Left = xCenter-5*opto_size*2*0.75; %remove last 0.75 to have full opto size between the two E
    Right = xCenter+5*2*opto_size*0.75; 
    Bottom = yCenter-5*opto_size*1.5; 
    Up = yCenter+5*opto_size*1.5; 

    dstRect_left = CenterRectArrayOnPoint(dstRect_center(2,:), Left, yCenter);
    dstRect_top =  CenterRectArrayOnPoint(dstRect_center(3,:), Right, yCenter);
    dstRect_bottom =  CenterRectArrayOnPoint(dstRect_center(4,:), xCenter, Bottom);
    dstRect_right =   CenterRectArrayOnPoint(dstRect_center(5,:), xCenter, Up);
    
    
    Screen('DrawTextures', window, crowd(1), [],...
    dstRect_center(1,:), [], filterMode);
    Screen('DrawTextures', window, crowd(2), [],...
    dstRect_left, [], filterMode);
    Screen('DrawTextures', window, crowd(3), [],...
    dstRect_top, [], filterMode);
    Screen('DrawTextures', window, crowd(4), [],...
    dstRect_bottom, [], filterMode);
    Screen('DrawTextures', window, crowd(5), [],...
    dstRect_right, [], filterMode);
    end
       
    % Flip to the screen
    beep; % we use a sound to avert the participants that the stim is showed (might be very useful when amblyopic eye is used)
    Screen('Flip', window);
    onsetTime = GetSecs;


    %% Wait for a button press
 
    timeSecs = KbWait;
    [ keyIsDown, t, keyCode ] = KbCheck;
    keyCode = find(keyCode, 1);
    %think about changing the loops so if the participant choose a key that
    %is not defined, the trial does not change
   if keyIsDown
               rt = t - onsetTime;
      
    if keyCode == escapeKey
            break;
    elseif  keyCode==rightKey && E_rand_orientation(1) == 0
            sc.doResp(1); 
            value = 'TRUE';
    elseif keyCode==upKey && E_rand_orientation(1) == 270
            sc.doResp(1);
            value = 'TRUE';
    elseif keyCode==downKey && E_rand_orientation(1) == 90
            sc.doResp(1);
            value = 'TRUE';
    elseif keyCode==leftKey && E_rand_orientation(1) == 180
            sc.doResp(1);
            value = 'TRUE';
    else
            sc.doResp(0);
            value = 'FALSE';
    end
    KbReleaseWait;
    if keyCode==rightKey
        key = "right";
    elseif keyCode==leftKey
        key = "left";
    elseif keyCode==upKey
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

    [MAR, logMAR] = convert_logmar(opto_size, DISTANCE, stereoMode, pix_size);

    
    temps(sc.trialCount,:) = {sc.trialCount, sc.revCount, opto_size, logMAR, value, key, Stim_position, E_rand_orientation(1), E_rand_orientation(2), E_rand_orientation(3), E_rand_orientation(4), E_rand_orientation(5), EYE_TEST, AMB_EYE, rt, datetime('now')};
    % follows the varaibles set previously --> varNames = ["Trial","Reversal","Level", "LogMar","value", "key", "Position", "orientation center", "orientation left", "orientation top", "orientation bottom", "orientation right","Eye", "AMB", "RT","time"];

   end
   
   if doubleScreen == true
   Screen('SelectStereoDrawBuffer',window,0);
   Screen('FillRect', window, rectColor*0.5, HC1);
   Screen('SelectStereoDrawBuffer',window,1);
   Screen('FillRect', window, rectColor*0.5, HC2);
   Screen('Flip', window);
   else
   baseRect = [0 0 200 250];
   [xCenter, yCenter] = RectCenter(windowRect);
   centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
   rectColor = [1 1 1];
   Screen('FillRect', window, rectColor*0.5, centeredRect);
   Screen('Flip', window);
   end
   WaitSecs(0.5);
   

%% calculations
    %here the calculation of the last six reversals
            if sc.trialCount > 1 && sc.revCount > 0 % only begins after the first trial 
                if temps{sc.trialCount,2} ~= temps{sc.trialCount-1,2} % only records when the number of reversals change 
                    mrt(sc.revCount,:) = {sc.revCount, logMAR}; % recorded in a table titled mrt
                end
            end

    % when the staircase is finished, we calculate the mean of
            % reversals from the mrt table
            if sc.isFinished
                idx = any(mrt{:,1}>maxNumReversals-6,2); %alternative is to get all of the reversals and THEN remove some from the total in mrt_extracted                                   
                mrt_extracted = mrt(idx,:);
                mean_reversals = mean(mrt_extracted{:,2});
                if isnan(mean_reversals) % in the case of having no reversals at all (get the last result)
                    mean_reversals = logMAR;
                end
                % the mean of reversals is then recorded at the end of the
                % table     

                temps(sc.trialCount+1,:) = {sc.trialCount+1, sc.revCount, 0, mean_reversals, 'MEAN', 'reversals', Stim_position,0,0,0,0,0, EYE_TEST, AMB_EYE, 0, datetime('now')};
            end
                %here the function for the plot staircase/values (needs to be modified for compatibility with all the tests)
            if sc.isFinished
                plot_results(sc.isFinished, temps, mean_reversals, []);
            else % even if not finished the plot is displayed
                plot_results(sc.isFinished, temps, logMAR, []); 
            end  
    
        
end

% Clear screen
sca;

% export data table from staircase object into an xls file
baseFileName = SUBJECT + "_" + date + '_snellen_e_crowded';

if global_param.Retest == true
    baseFileName = baseFileName + "_retest_";
end

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, mean_reversals);

writetable(temps,filename)

fprintf('Output saved in: %s\n', filename)

global_param.EYE_TEST = '?';
save('global_param.mat','global_param');
