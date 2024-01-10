% Asteriodcomputer4AFC_nlp11
%{
This script is adapted from the script from ... et al (...)
For more information about the experiment, contact them 

- modifications
    - use of Display++ stereodisplay (use of passive 3D glasses)
    - modification of ChangeDotColours and ChangeDotCOloursTarget.m 
        these 2 script were using an outdated RGBA codex, was updated 
    - modifications of the dots into ovals (because we use a single screen)
    - modifications of the size of the areas of dots but kept the size of
    the dots relative to the distance

Juju (email)
%}

%% Setup
sca;
commandwindow;
filepath=fileparts(which('Asteroid.m')); % former name = ASTEROIDCOMPUTER4AFC_nlp11.m
cd(filepath);

%% initialisation of eyelink
[dummymode, var_eye_link] = eyelink_init(1);

%% retrieve data from previous test (not very useful here - can be removed if necessary)

% will retrieve the global parameters file, and if it does not exist then 
% it will create the file to record/extract basic parameters
if isfile("global_param.mat")
    load("global_param.mat");
else
    global_param = GetGlobalVariables();
end

KbName('UnifyKeyNames'); %set up the keyboard for answers 


%% Gets subject Info sets up experiment 

prompt = {'Enter subject number:', 'distance from screen', 'Which eye is amblyopic?', 'fixation cross?', 'edf file name?', 'Eye tested'}; %description of fields
defaults = {global_param.ID, num2str(global_param.distance), global_param.AMB_EYE, 'true', strcat(global_param.ID,'as'), 'Both'};%size and distance can be extracted to get the right gabor size/frequency
answer = inputdlg(prompt, 'Parameters',2,defaults); %opens dialog
SUBJECT = answer{1,:}; %Gets Subject Name
DISTANCE = str2num(answer{2,:}); %Gets distance from the screen
AMB_EYE = answer{3,:}; %which eye is the amblyopic one --> for the datafile
fixCross = answer{4,:}; %used later in the code, use false for monocular tests
edfFile = answer{5,:}; % should update name later, to be mindful of possible reruns
EYE_TEST = answer{6,:};

fixCross = strcmp(fixCross,'true'); %convert string to boolean

global_param = GetGlobalVariables();

CurrentTime = datetime('now', 'Format','yyyy/MM/dd');
CurrTest = 'asteroid';

%% launch eyelink parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);


%% Inits
nlp_timer_1 = GetSecs;
nlp_t_L       = [];
nlp_t_R       = [];
nlp_t_both    = [];

DEBUG = 0; %runs real test when at 0
AssertOpenGL % NLP 6/7/2016
PsychDefaultSetup(2);
scrnNum = max(Screen('Screens'));
%ListenChar(2);%%This line avoids writing in the code when pressing keys NLP turning this back on 6/20/2016
rand('twister',sum(100*clock));

%% parameters init

[expt] = asteroid_param(SUBJECT,AMB_EYE, EYE_TEST);

%% Keyboard init

% Keypresses that abort the expt
keycode = zeros(1,256);
KbName('UnifyKeyNames');
LEFT  = KbName('LeftArrow');
RIGHT = KbName('RightArrow');
DOWN  = KbName('DownArrow');
UP    = KbName('UpArrow');
SPACE = KbName('SPACE');

exit            = KbName('ESCAPE');
top_leftKey     = KbName('UpArrow');% KbName('a'); % see if we can set up multiple keys on the same variable
top_rightKey    = KbName('k');
bottom_leftKey  = KbName('DownArrow');%KbName('z');% see if we can set up multiple keys on the same variable
bottom_rightKey = KbName('m');


%% filename + save of expt parameters 

filename = strrep(strrep(['data/ASTEROIDCOMPUTER4AFC_' expt.subject '_' datestr(now) '.mat'],' ','_'),':','-');

%% Initialise PTB Screen

white = WhiteIndex(scrnNum);
black = BlackIndex(scrnNum);
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
screens = Screen('Screens');
screenNumber = max(screens);


% was added for the display++ setting 
if fixCross == true 
    stereoMode = 100; % 100; %will fix later, need to do diagnostics first 
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'InterleavedLineStereo', 0);
    [window, windowRect] = PsychImaging('OpenWindow',0,expt.bgcol,[],[],2,[],expt.multisample,stereoMode);
else % alternative only used for debugging purposes 
    stereoMode = [];
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [window, windowRect]=PsychImaging('OpenWindow',0,expt.bgcol,[],[],2,[],expt.multisample,0);
end

blueRectLeftOn   = [0,                 windowRect(4)-1, windowRect(3)/4,   windowRect(4)];
blueRectLeftOff  = [windowRect(3)/4,   windowRect(4)-1, windowRect(3),     windowRect(4)];
blueRectRightOn  = [0,                 windowRect(4)-1, windowRect(3)*3/4, windowRect(4)];
blueRectRightOff = [windowRect(3)*3/4, windowRect(4)-1, windowRect(3),     windowRect(4)];

%Screen('FillRect',window, 0.5);
Screen('Flip',    window);
% 6/7/2016
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%Work out timing
ifi=Screen('GetFlipInterval', window);
expt.framespersec=round(1/ifi); %% framerate HZ

SIZE_X=expt.nx;%expt.sizeimageX;
SIZE_Y=expt.ny;%expt.sizeimageY;

% Instead of returning width and height of the graphics window/screen in pixels
% using this [width, height] = Screen('WindowSize', window); 
% we do 
width = windowRect(3);
height = windowRect(4);


%% Eyelink Calibration
[el] = eyelink_calibration(var_eye_link,window, stereoMode, [], width, height);

%% clear screen of host PC 
eyelink_clear_screen(var_eye_link,el)

%% start screen 

Screen('TextFont',  window, 'Times');
Screen('TextSize',  window, 40);
Screen('TextStyle', window, 1);
Screen('DrawText',  window, 'Click "esc" to start', expt.nx/2-205, 220, [255 255 255]);
Screen('LoadNormalizedGammaTable',window,linspace(0,(255/256),256)'*ones(1,3));

Screen(window,'Flip');

HideCursor;

keyCode(1:256)=0;
while (keyCode(top_leftKey)==0 && keyCode(top_rightKey)==0 && keyCode(bottom_leftKey)== 0 && keyCode(bottom_rightKey)==0 && keyCode(KbName('ESCAPE'))==0)
   
   [keyisdown, secs, keyCode, deltaSecs] = KbCheck(-1);
   [x,y,buttons] = GetMouse;
   
end
while(keyisdown)    % wait for keys to be released
   [keyisdown, secs, keycode] = KbCheck(-1);
   WaitSecs(0.001);
end

Screen(window,'Flip');



sizeimagedots=expt.sizeimagenpixels;

n                   = 0;
nstimuli            = 0;
pressbutton         = 0;
stereocue           = 1;
passedblindnesstest = 0; %nlp skip part yes or no
correctnumber       = 0;
ntrials             = 0;

while ~passedblindnesstest
   
   ntrials=ntrials+1;
   
   if stereocue>1;    stereocue=1;    end
   if stereocue<0.25; stereocue=0.25; end
   
   fprintf('Present stimulus with easydispar and nonstereocue=%3.2f. Trial number =%3.0f\n ',stereocue,ntrials);
   
   log_disparity=expt.firstdisparitylog;
   
   randposition    = [1 2 3 4];
   randposition    = scramble(randposition);
   TARGET_Position = randposition(1);
   
   t1=GetSecs;
   
   response=0;
   
   keyCode( 1:256 )=0;


%% Eyelink Start trial
eyelink_start_trial(var_eye_link, sc.trialCount, orientation, [])

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

   %% Main Display Loop
   while (keyCode(top_leftKey)==0 && keyCode(top_rightKey)==0 && keyCode(bottom_leftKey)== 0 && keyCode(bottom_rightKey)==0 && keyCode(KbName('ESCAPE'))==0)
      
      
      if GetSecs > nlp_timer_1 + (90/1000)
         % Update stimuli
         % 90ms expired
         nlp_timer_1 = GetSecs;    % reset timer
                  
         for SQUARE=1:4

            Position=randposition(SQUARE);
            
            disparity_arcsec=(10^log_disparity);
            disparity_pixels=((10^log_disparity)*expt.nx)/(expt.degreesfullscreenX*3600);%%PIXELS
            
            tgtxcen = expt.tgtxcen(Position);
            tgtycen = expt.tgtycen(Position);
            
            % Background dots:
            % Pick random locations:
            dotXpixBG = rand(1,expt.nBGdots) * expt.stimNpixX;
            dotYpixBG = rand(1,expt.nBGdots) * expt.stimNpixY; %dotYpixBG = rand(1,expt.nBGdots) * (expt.stimNpixY);
            dotcolBG = ChooseDotColors(expt.nBGdots);
            
            % TARGET_Position patch of dots:
            % Generate random dot positions for TGT
            dotXpixTG = tgtxcen-expt.tgtXsizepix/2 + rand(1,expt.nTGdots) * expt.tgtXsizepix;
            dotYpixTG = tgtycen-expt.tgtYsizepix/2 + rand(1,expt.nTGdots) * expt.tgtYsizepix;
            
            dotXpixBG1 = tgtxcen-expt.BGXsizepix/2 + rand(1,expt.nBGdots) * expt.BGXsizepix;
            dotYpixBG1 = tgtycen-expt.BGYsizepix/2 + rand(1,expt.nBGdots) * expt.BGYsizepix;
            dotcolBG1 = ChooseDotColors(expt.nBGdots);
            
            % Now apply the disparity: We apply -disp/2 to the bg  and +bg/2 to the tgt so
            % that the relative disparity is as specified.
            %qdisp = trial.dispamplitudepix/4;
            %qdisp=(10.^(expt.disparity_indisparity_arcsec) / expt.disparity_arcsecperpix)/4
            dotXpixBGL = dotXpixBG1-disparity_pixels/4;%%%Units in pixels
            dotXpixBGR = dotXpixBG1+disparity_pixels/4;%%%Units in pixels
            if SQUARE==1
               
               dotcolTG = ChooseDotColorsTarget(expt.nTGdots,stereocue);
               
               dotXpixTGL = dotXpixTG+disparity_pixels/4;%%%Units in pixels
               dotXpixTGR = dotXpixTG-disparity_pixels/4;%%%Units in pixels
            else
               dotcolTG = ChooseDotColors(expt.nTGdots);
               
               dotXpixTGL = dotXpixTG-disparity_pixels/4;%%%Units in pixels
               dotXpixTGR = dotXpixTG+disparity_pixels/4;%%%Units in pixels
            end
            
            % Remove any BG dots which fall in the shifted position of the tgt:
            % Left eye: TARGET_Position is centred on x=tgtxcen-qdisp after the shift, y=tgtycen as no vertical disparity:
            jkeepL = find( ~ ( abs(dotXpixBGL-tgtxcen-disparity_pixels/4)<(expt.tgtXsizepix)/2 & abs(dotYpixBG1-tgtycen)<(expt.tgtYsizepix)/2 ));
            dotXpixBGL = dotXpixBGL(jkeepL);
            dotYpixBGL = dotYpixBG1(jkeepL);
            dotcolBGL = dotcolBG1(:,jkeepL);
            
            %disparity_pixels/4Right eye: TARGET_Position is centred on tgtxcen+qdisp after the shift y=tgtycen as no vertical disparity:
            jkeepR = find( ~ ( abs(dotXpixBGR-tgtxcen+disparity_pixels/4)<(expt.tgtXsizepix)/2 & abs(dotYpixBG1-tgtycen)<(expt.tgtYsizepix)/2 ));
            dotXpixBGR = dotXpixBGR(jkeepR);
            dotYpixBGR = dotYpixBG1(jkeepR);
            dotcolBGR = dotcolBG1(:,jkeepR);
            
            if SQUARE==1
               dotxL1   = [dotXpixTGL  dotXpixBGL]; % wait! is it why there is an issue? use 'cat(2,dotXpixTGL,dotXpixBGL);'?
               dotxL1   = round(dotxL1); %added --> not working!!!!!
               dotyL1   = [dotYpixTG   dotYpixBGL];
               dotyL1   = round(dotyL1); %added
               dotcolL1 = [ dotcolTG dotcolBGL];
               dotxR1   = [dotXpixTGR  dotXpixBGR];
               dotxR1   = round(dotxR1); %added
               dotyR1   = [dotYpixTG   dotYpixBGR];
               dotyR1   = round(dotyR1); %added
               dotcolR1 = [dotcolTG    dotcolBGR ];
            end
            if SQUARE==2
               dotxL2= [dotXpixTGL dotXpixBGL];
               dotxL2   = round(dotxL2); %added
               dotyL2 = [dotYpixTG dotYpixBGL];
               dotyL2   = round(dotyL2); %added
               dotcolL2 = [ dotcolTG dotcolBGL];
               dotxR2 = [dotXpixTGR dotXpixBGR];
               dotxR2   = round(dotxR2); %added
               dotyR2 = [dotYpixTG dotYpixBGR];
               dotyR2   = round(dotyR2); %added
               dotcolR2 = [ dotcolTG dotcolBGR];
            end
            
            if SQUARE==3
               dotxL3= [dotXpixTGL dotXpixBGL];
               dotxL3   = round(dotxL3); %added
               dotyL3 = [dotYpixTG dotYpixBGL];
               dotyL3   = round(dotyL3); %added
               dotcolL3 = [ dotcolTG dotcolBGL];
               dotxR3 = [dotXpixTGR dotXpixBGR];
               dotxR3   = round(dotxR3); %added
               dotyR3 = [dotYpixTG dotYpixBGR];
               dotyR3   = round(dotyR3); %added
               dotcolR3 = [ dotcolTG dotcolBGR];
            end
            if SQUARE==4
               dotxL4= [dotXpixTGL dotXpixBGL];
               dotxL4   = round(dotxL4); %added
               dotyL4 = [dotYpixTG dotYpixBGL];
               dotyL4   = round(dotyL4); %added
               dotcolL4 = [ dotcolTG dotcolBGL];
               dotxR4 = [dotXpixTGR dotXpixBGR];
               dotxR4   = round(dotxR4); %added
               dotyR4 = [dotYpixTG dotYpixBGR];
               dotyR4   = round(dotyR4); %added
               dotcolR4 = [ dotcolTG dotcolBGR];
            end
            

         end % for square
         
         dotxL   = [dotxL1   dotxL2   dotxL3   dotxL4   ];
         dotyL   = [dotyL1   dotyL2   dotyL3   dotyL4   ];
         dotcolL = [dotcolL1 dotcolL2 dotcolL3 dotcolL4 ];
         dotcolL = round(dotcolL);
         
         dotxR   = [dotxR1   dotxR2   dotxR3   dotxR4   ];
         dotyR   = [dotyR1   dotyR2   dotyR3   dotyR4   ];
         dotcolR = [dotcolR1 dotcolR2 dotcolR3 dotcolR4 ];
         dotcolR = round(dotcolR);

      end % nlp getsec loop
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
      %Screen('FillRect',window,expt.bgcol);  % Erase this buffer
      % where dots are drawn relative to:
      %cen = [(expt.nx-expt.stimNpixX)/2 (expt.ny-expt.stimNpixY)/2]; %needed to change that to appoint for the size of the screen 
     
      % Have to draw circular dots, otherwise I don't get anti-aliasing.
      dotarrayL = [dotxL; dotyL ];
      dotarrayR = [dotxR; dotyR ];
      % Initially, draw dots opaque so you overwrite the background:
      dotcolL(4,:) = 255; %was 1 but apparently it does not work that way 
      dotcolR(4,:) = 255;
     
      %% fusion crosses 
      [HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode);

%% setting the the values of left and right half crosses and fusion frames
   if fixCross == true
    if contains(AMB_EYE, 'Left') 
            HC1 = HCl;
            HC2 = HCr;
        else
            HC1 = HCr;
            HC2 = HCl;
    end

    while fixCross == true
    
    vbl = Screen('Flip', window);
    waitframes = 1; 
    
    exitFixCross = false;
    while exitFixCross == false

    % Check the keyboard to see if a button has been pressed
    [keyIsDown,secs, keyCode] = KbCheck;
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if keyCode(exit)
        exitFixCross = true; %I doubled the while loop just to be sure it goes to the next step - must change later
        fixCross = false;
        doubleScreen = true;
    elseif keyCode(LEFT)
        HC1(1,:) = HC1(1,:) - pixelsPerPress;
        HC1(3,:) = HC1(3,:) - pixelsPerPress;
    elseif keyCode(RIGHT)
        HC1(1,:) = HC1(1,:) + pixelsPerPress;
        HC1(3,:) = HC1(3,:) + pixelsPerPress;
    elseif keyCode(UP)
        HC1(2,:) = HC1(2,:) - pixelsPerPress;
        HC1(4,:) = HC1(4,:) - pixelsPerPress;
    elseif keyCode(DOWN)
        HC1(2,:) = HC1(2,:) + pixelsPerPress;
        HC1(4,:) = HC1(4,:) + pixelsPerPress;
    elseif keyCode(SPACE)
            if contains(AMB_EYE, 'Left')
            HC1 = HCl;
            HC2 = HCr;
            else
            HC1 = HCr;
            HC2 = HCl;
             end
    end
    
       % Draw the half crosses to the screen
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, white, HC1);

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, white, HC2);

    % Flip to the screen
    vbl  = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    
    if contains(AMB_EYE, 'Left')
        diff(:,1) = HC1(:,1)-HCl(:,1); %
    else
        diff(:,1) = HC1(:,1)-HCr(:,1); %
    end
    end

    baseRect = [0 0 200 250];
    [xCenter, yCenter] = RectCenter(windowRect);
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    Screen('SelectStereoDrawBuffer',window,0);
    Screen('FillRect', window, [0, 0, 0], HC1);

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, [0, 0, 0], HC2);
    Screen('Flip', window);
    WaitSecs(1);

    end
      
    cen_amb = [diff(1,1) diff(2,1)]; %(was -100 for y)
    cen_fe = [0 0]; %(was -100 for y)

    if contains(AMB_EYE, 'Left')
        cen_L = cen_amb; 
        cen_R = cen_fe;
    else
        cen_R = cen_amb; 
        cen_L = cen_fe;
    end
   else 
       cen_R = [0 0];
       cen_L = [0 0];
   end

%% make ovals instead of dots
% here we are converting all the dots into ovals. When using the scnalines
% with the stereomode, the dots are squeezed. Therefore we must make them
% longer = y longer than x to put them back to the rightful size
   % calculate the number of ovals 
   n_ovals_L = size(dotcolL,2);
   n_ovals_R = size(dotcolR,2);
   n_ovals = max([n_ovals_L, n_ovals_R]);

   ovalsizepix = [expt.dotsizepix/2; expt.dotsizepix];% because stereomode = 100
   % now create a vector of the size of the number of dots/ovals 
   ovalarrayL = ones(4,n_ovals_L); % will fill the [rect] parameter
   ovalarrayR = ones(4,n_ovals_R);
   
   %dotarray = xy positions; we must provide ovals each position 

    for ov = 1:n_ovals
        if ov <= length(dotarrayL)
        x = dotarrayL(1,ov)+cen_L(1);
        y = dotarrayL(2,ov)+cen_L(2);
        X1 = x-12;%7
        X2 = x+12;%7
        Y1 = y-6;%14
        Y2 = y+6;%14
        ovalarrayL(:,ov) = [X1;Y1;X2;Y2];
        end
        if ov <= length(dotarrayR)
        x = dotarrayR(1,ov)+cen_R(1);
        y = dotarrayR(2,ov)+cen_R(2);
        X1 = x-12;%7
        X2 = x+12;%7
        Y1 = y-6;%14
        Y2 = y+6;%14
        ovalarrayR(:,ov) = [X1;Y1;X2;Y2];
        end
    end
    maxDiameter = 24;%28


    
%% DISPLAY THE EXPERIMENT
      
% Left Eye

      Screen('SelectStereoDrawBuffer',window,0);
      Screen('FillOval', window, dotcolL, ovalarrayL, maxDiameter);
      %Screen('DrawDots',window,dotarrayL,expt.dotsizepix,dotcolL,cen_L,expt.dottype);
      % use Screen(‘FillOval’, windowPtr [,color] [,rect] [,perfectUpToMaxDiameter]);
      dotcolL(4,:) = 128; %was 0.5 but apparently it does not work that way 
      Screen('FillOval', window, dotcolL, ovalarrayL, maxDiameter);
      %Screen('DrawDots',window,dotarrayL,expt.dotsizepix,dotcolL,cen_L,expt.dottype);     

      Screen('FillRect',  window, [0, 0, 255], blueRectLeftOn  );
      Screen('FillRect',  window, [0, 0, 0],   blueRectLeftOff );
      Screen('DrawingFinished', window);

      onset = Screen('Flip',window); % flip and switch eyes
      
      nlp_t_L    = [nlp_t_L    onset];
      nlp_t_both = [nlp_t_both onset];
      
% Right eye
      
      %Screen('FillRect',window,expt.bgcol);  % Erase this buffer
      Screen('SelectStereoDrawBuffer',window,1);
      %Screen('DrawDots',window,dotarrayR,expt.dotsizepix,dotcolR,cen_R,expt.dottype);
      Screen('FillOval', window, dotcolR, ovalarrayR, maxDiameter);
      % Now, draw dots transparent so you get colour merging:
      dotcolR(4,:) = 128; %was 0.5 but apparently it does not work that way 
      %Screen('DrawDots',window,dotarrayR,expt.dotsizepix,dotcolR ,cen_R,expt.dottype);   
      Screen('FillOval', window, dotcolR, ovalarrayR, maxDiameter);

      Screen('FillRect',  window, [0, 0, 255], blueRectRightOn );
      Screen('FillRect',  window, [0, 0, 0],   blueRectRightOff);
 
      Screen('DrawingFinished', window);
      onset = Screen('Flip',window);
      nlp_t_R    = [nlp_t_R    onset];
      nlp_t_both = [nlp_t_both onset];
      
      [keyisdown, secs, keyCode, deltaSecs] = KbCheck(-1); % Don't understand this kbcheck

   end
         
   Screen('Flip',window);
   beep
   
   while(keyisdown)    % wait for keys to be released
      [keyisdown, secs, keycode] = KbCheck(-1);
      WaitSecs(0.001);
   end
   
   t2=GetSecs;
   
   trialtime_sec = t2-t1;
   

   if contains(var_eye_link, 'true')
        Eyelink('Message', 'KEY_PRESSED');
   end
   
   if keyCode(top_leftKey)==1 % use the TOP ARROW key instead 
      response=1; %
      pressbutton=1;
   end
   if keyCode(top_rightKey)==1 % 
      response=2; %
      pressbutton=1;
   end
   if keyCode( bottom_leftKey)==1 % use the BOTTOM ARROW key instead 
      response=3; %
      pressbutton=1;
   end
   if keyCode(bottom_rightKey)==1 %
      response=4; %%
      pressbutton=1;
   end
   
   if keyCode(exit)==1
      break;
   end
   
  
   if (TARGET_Position==1 && response==1) || (TARGET_Position==2 && response==2) || (TARGET_Position==3 && response==3) || (TARGET_Position==4 && response==4)
      correct=1;%CORRECT
   else
      correct=0;%ERROR
   end

        eyelink_stop_recording_and_write_variables(var_eye_link,sc.trialCount, orientation, [])
         
   if passedblindnesstest==0
      if correct==1
         fprintf('Response=CORRECT! Trial number =%3.0f\n ', ntrials);
         stereocue=stereocue-0.25;
         correctnumber=correctnumber+1;
      else
         fprintf('Response=INCORRECT! Trial number =%3.0f\n ',ntrials);
         stereocue=stereocue+0.25;
         correctnumber=0;
      end
      
      if correctnumber==4
         passedblindnesstest=1;
         fprintf('Four in a row! Well done! Total Trials =%3.0f\n ',ntrials);
         % break;
      end
      
      if ntrials>=10
         
         fprintf('The test is finished. Total Trials =%3.0f\n ',ntrials);
         
         break;
      end
 
   end
end

%% Real test (disparity)


if passedblindnesstest==1
   
   %m=[0.1:0.001:3,9]; %%Changed per Ignacio 9/6/2016 AMG
   m=linspace(log10(1),log10(3600),1000);
   qposteriori(1,:)=ones(1,length(m));
   qposteriori(2,:)=ones(1,length(m));
   qposteriori(3,:)=ones(1,length(m));
   qposteriori(4,:)=ones(1,length(m));
   qposteriori(5,:)=ones(1,length(m));
   qposteriori(6,:)=ones(1,length(m));
   qposteriori(7,:)=ones(1,length(m));
   qposteriori(8,:)=ones(1,length(m));
   qposteriori(9,:)=ones(1,length(m));
   qposteriori(10,:)=ones(1,length(m));
   
   disparity(1:length(expt.staircases))=mean(m);%%Initial disparity in pixels log units
  
   numstair=repmat(expt.staircases,1,expt.trialsperstaircase);
   numstair=scramble(numstair);
   trials=0;
   trials2=0;
   stereocue=0;
   n=0;
   while trials<expt.trialsperstaircase*length(expt.staircases)
      trials=trials+1;
      n=n+1;
      trials2=trials2+1;
      
      if trials==1
         disparity(numstair(n))=expt.firstdisparitylog;
      end
      
      log_disparity=disparity(numstair(n));%%log10(disparity_arcsec)
      
      
      if log_disparity>3
         qposteriori(numstair(n),:)=ones(1,length(m));
      end    
      
      if log_disparity>3
         log_disparity=3;
         
      end
      if log_disparity<0.01
         log_disparity=0.01;
      end
      
      %end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      randposition=[1 2 3 4];
      randposition=scramble(randposition);
      TARGET_Position=randposition(1);
      
      t1=GetSecs;
      %[T1, boxsecs, confidence] = PsychDataPixx('GetPreciseTime');
      %im = Screen('GetImage',window);
      %imwrite(round(im),'examplePTBcircles.tiff','tiff');%%Modification by Dr. Ignacio Serrano-Pedraza 2007
      
      response=0;
      
      keyCode(1:256)=0;


 %% Eyelink Start trial
eyelink_start_trial(var_eye_link, sc.trialCount, orientation, [])


 %% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);




      while (keyCode(top_leftKey)==0 && keyCode(top_rightKey)==0 && keyCode(bottom_leftKey)== 0 && keyCode(bottom_rightKey)==0 && keyCode(KbName('ESCAPE'))==0)

         if GetSecs > nlp_timer_1 + (90/1000)
            %
            % Update stimuli
            % 90ms expired
            %
            
            nlp_timer_1 = GetSecs;    % reset timer

            %WaitSecs((1/expt.tempfreq)-(1/expt.framespersec));
            
            for SQUARE=1:4
               
               
               Position=randposition(SQUARE);
               
               disparity_arcsec=(10^log_disparity);
               disparity_pixels=((10^log_disparity)*expt.nx)/(expt.degreesfullscreenX*3600);%%PIXELS %X 
 
               tgtxcen = expt.tgtxcen(Position);
               tgtycen = expt.tgtycen(Position);

               % Background dots:
               % Pick random locations:
               dotXpixBG = rand(1,expt.nBGdots) * expt.stimNpixX;
               dotYpixBG = rand(1,expt.nBGdots) * expt.stimNpixY;
               dotcolBG = ChooseDotColors(expt.nBGdots);

               % TARGET_Position patch of dots:
               % Generate random dot positions for TGT
               dotXpixTG = tgtxcen-expt.tgtXsizepix/2 + rand(1,expt.nTGdots) * expt.tgtXsizepix;
               dotYpixTG = tgtycen-expt.tgtYsizepix/2 + rand(1,expt.nTGdots) * expt.tgtYsizepix;
  
               dotXpixBG1 = tgtxcen-expt.BGXsizepix/2 + rand(1,expt.nBGdots) * expt.BGXsizepix;
               dotYpixBG1 = tgtycen-expt.BGYsizepix/2 + rand(1,expt.nBGdots) * expt.BGYsizepix;
               dotcolBG1 = ChooseDotColors(expt.nBGdots);
               
               % Now apply the disparity: We apply -disp/2 to the bg  and +bg/2 to the tgt so
               % that the relative disparity is as specified.
               %qdisp = trial.dispamplitudepix/4;
               %qdisp=(10.^(expt.disparity_indisparity_arcsec) / expt.disparity_arcsecperpix)/4
               dotXpixBGL = dotXpixBG1-disparity_pixels/4;%%%Units in pixels
               dotXpixBGR = dotXpixBG1+disparity_pixels/4;%%%Units in pixels
               if SQUARE==1
                  dotcolTG = ChooseDotColors(expt.nTGdots);
                  dotXpixTGL = dotXpixTG+disparity_pixels/4;%%%Units in pixels
                  dotXpixTGR = dotXpixTG-disparity_pixels/4;%%%Units in pixels
               else
                  dotcolTG = ChooseDotColors(expt.nTGdots);
                  dotXpixTGL = dotXpixTG-disparity_pixels/4;%%%Units in pixels
                  dotXpixTGR = dotXpixTG+disparity_pixels/4;%%%Units in pixels
               end

               % Remove any BG dots which fall in the shifted position of the tgt:
               % Left eye: TARGET_Position is centred on x=tgtxcen-qdisp after the shift, y=tgtycen as no vertical disparity:
               jkeepL = find( ~ ( abs(dotXpixBGL-tgtxcen-disparity_pixels/4)<(expt.tgtXsizepix)/2 & abs(dotYpixBG1-tgtycen)<(expt.tgtYsizepix)/2 ));
               dotXpixBGL = dotXpixBGL(jkeepL);
               dotYpixBGL = dotYpixBG1(jkeepL);
               dotcolBGL = dotcolBG1(:,jkeepL);

               %disparity_pixels/4Right eye: TARGET_Position is centred on tgtxcen+qdisp after the shift y=tgtycen as no vertical disparity:
               jkeepR = find( ~ ( abs(dotXpixBGR-tgtxcen+disparity_pixels/4)<(expt.tgtXsizepix)/2 & abs(dotYpixBG1-tgtycen)<(expt.tgtYsizepix)/2 ));
               dotXpixBGR = dotXpixBGR(jkeepR);
               dotYpixBGR = dotYpixBG1(jkeepR);
               dotcolBGR  = dotcolBG1(:,jkeepR);
               
               if SQUARE==1
                  dotxL1   = [dotXpixTGL dotXpixBGL ];
                  dotyL1   = [dotYpixTG  dotYpixBGL ];
                  dotcolL1 = [dotcolTG   dotcolBGL  ];
                  dotxR1   = [dotXpixTGR dotXpixBGR ];
                  dotyR1   = [dotYpixTG  dotYpixBGR ];
                  dotcolR1 = [dotcolTG   dotcolBGR  ];
               end
               if SQUARE==2
                  dotxL2   = [ dotXpixTGL dotXpixBGL ];
                  dotyL2   = [ dotYpixTG  dotYpixBGL ];
                  dotcolL2 = [ dotcolTG   dotcolBGL  ];
                  dotxR2   = [ dotXpixTGR dotXpixBGR ];
                  dotyR2   = [ dotYpixTG  dotYpixBGR ];
                  dotcolR2 = [ dotcolTG   dotcolBGR  ];
               end
               if SQUARE==3
                  dotxL3   = [ dotXpixTGL dotXpixBGL ];
                  dotyL3   = [ dotYpixTG  dotYpixBGL ];
                  dotcolL3 = [ dotcolTG   dotcolBGL  ];
                  dotxR3   = [ dotXpixTGR dotXpixBGR ];
                  dotyR3   = [ dotYpixTG  dotYpixBGR ];
                  dotcolR3 = [ dotcolTG   dotcolBGR  ];
               end
               if SQUARE==4
                  dotxL4   = [ dotXpixTGL dotXpixBGL ];
                  dotyL4   = [ dotYpixTG  dotYpixBGL ];
                  dotcolL4 = [ dotcolTG   dotcolBGL  ];
                  dotxR4   = [ dotXpixTGR dotXpixBGR ];
                  dotyR4   = [ dotYpixTG  dotYpixBGR ];
                  dotcolR4 = [ dotcolTG   dotcolBGR  ];
               end
            end
            
            dotxL   = [dotxL1 dotxL2 dotxL3 dotxL4];
            dotyL   = [dotyL1 dotyL2 dotyL3 dotyL4];
            dotcolL = [dotcolL1 dotcolL2 dotcolL3 dotcolL4];
            
            dotxR   = [dotxR1   dotxR2   dotxR3   dotxR4  ];
            dotyR   = [dotyR1   dotyR2   dotyR3   dotyR4  ];
            dotcolR = [dotcolR1 dotcolR2 dotcolR3 dotcolR4];

         end % nlp getsec loop

         % Blank the screen:
         %for jb=[0 1]
            %Screen('SelectStereoDrawBuffer',window,jb);
         Screen('FillRect',window,expt.bgcol);
         %Screen('Flip',window); % flip and switch eyes
         %Screen('FillRect',window,expt.bgcol);
         %end
         
         % where dots are drawn relative to:
         %cen = [(expt.nx-expt.stimNpixX)/2 (expt.ny-expt.stimNpixY)/2]; %needs another calculation because -300 is too much (see training)
         cen = [0 -100];
         % Have to draw circular dots, otherwise I don't get anti-aliasing.
         dotarrayL = [dotxL;dotyL ];
         dotarrayR = [dotxR;dotyR ];
         % Initially, draw dots opaque so you overwrite the background:
         dotcolL(4,:) = 255; %was 1 
         dotcolR(4,:) = 255;
         


         %% make ovals instead of dots
% here we are converting all the dots into ovals. When using the scnalines
% with the stereomode, the dots are squeezed. Therefore we must make them
% longer = y longer than x to put them back into the rightful size
   % calculate the number of ovals 
   n_ovals_L = size(dotcolL,2);
   n_ovals_R = size(dotcolR,2);
   n_ovals = max([n_ovals_L, n_ovals_R]);

   ovalsizepix = [expt.dotsizepix/2; expt.dotsizepix];% because stereomode = 100
   % now create a vector of the size of the number of dots/ovals 
   ovalarrayL = ones(4,n_ovals_L); % will fill the [rect] parameter
   ovalarrayR = ones(4,n_ovals_R);
   
   %dotarray = xy positions; we must provide ovals each position 

    for ov = 1:n_ovals
        if ov <= length(dotarrayL)
        x = dotarrayL(1,ov)+cen_L(1);
        y = dotarrayL(2,ov)+cen_L(2);
        X1 = x-12;%14
        X2 = x+12;
        Y1 = y-6;%7
        Y2 = y+6;
        ovalarrayL(:,ov) = [X1;Y1;X2;Y2];
        end
        if ov <= length(dotarrayR)
        x = dotarrayR(1,ov)+cen_R(1);
        y = dotarrayR(2,ov)+cen_R(2);
        X1 = x-12;
        X2 = x+12;
        Y1 = y-6;
        Y2 = y+6;
        ovalarrayR(:,ov) = [X1;Y1;X2;Y2];
        end
    end
    maxDiameter = 24; % the diameter must be below 24 pix (23.4979) to match the original article dva



%% DISPLAY
         %% Left eye

         Screen('SelectStereoDrawBuffer',window,0);
         Screen('FillOval', window, dotcolL, ovalarrayL, maxDiameter);
         %Screen('DrawDots',window,dotarrayL,expt.dotsizepix,dotcolL,cen,expt.dottype);
         dotcolL(4,:) = 128;%was 0.5
         Screen('FillOval', window, dotcolL, ovalarrayL, maxDiameter);
         %Screen('DrawDots',window,dotarrayL,expt.dotsizepix,dotcolL ,cen,expt.dottype);
         %Screen('FrameRect', window, [255 0 0], [], 5); %Left Eye
         
         if DEBUG %left eye
            if length(nlp_t_L) > 2
               Screen('DrawText', window, num2str(nlp_t_L(end),'%4.1f'),...
                  expt.nx/2-205, 520, [255 255 255]);
            end
            Screen('FrameRect', window, [255 0 0], [], 5); %Red - left eye 
         end
         Screen('FillRect',  window, [0, 0, 255], blueRectLeftOn  );
         Screen('FillRect',  window, [0, 0, 0],   blueRectLeftOff );
         Screen('DrawingFinished', window);
         
         onset = Screen('Flip',window); % flip and switch eyes
         nlp_t_L    = [nlp_t_L    onset];
         nlp_t_both = [nlp_t_both onset];

         
         %% Right eye

         Screen('SelectStereoDrawBuffer',window,1);
         Screen('FillOval', window, dotcolR, ovalarrayR, maxDiameter);
         %Screen('DrawDots',window,dotarrayR,expt.dotsizepix,dotcolR,cen,expt.dottype);                 
         % % Now, draw dots transparent so you get colour merging:
         dotcolR(4,:) = 128;%was 0.5
         Screen('FillOval', window, dotcolR, ovalarrayR, maxDiameter);
         %Screen('DrawDots',window,dotarrayR,expt.dotsizepix,dotcolR ,cen,expt.dottype);
         %Screen('FrameRect', window, [0 255 0], [], 5); %Right Eye
         
         if DEBUG %right eye
            if length(nlp_t_R) > 2
               Screen('DrawText', window, num2str(nlp_t_R(end),'%4.1f'),...
                  expt.nx/2-50, 520, [255 255 255]);
            end
            Screen('FrameRect', window, [0 255 0], [], 5); %Green - right eye 
         end
         
         Screen('FillRect',  window, [0, 0, 255], blueRectRightOn );
         Screen('FillRect',  window, [0, 0, 0],   blueRectRightOff);
         Screen('DrawingFinished', window);
         
         onset = Screen('Flip',window);
         nlp_t_R    = [nlp_t_R    onset];
         nlp_t_both = [nlp_t_both onset];

         
         
         %  [buttonStates, boxTimeSecs, getsecsTimeSecs] = ResponsePixx('GetButtons');
         [keyisdown, secs, keyCode, deltaSecs] = KbCheck(-1);
         % [x,y,buttons] = GetMouse;
         
         
      end
      Screen('Flip',window);

         beep % to avert when stim showed 


      while(keyisdown)    % wait for keys to be released
         [keyisdown, secs, keycode] = KbCheck(-1);
         WaitSecs(0.001);
      end
      
  %% record keys
 
      %[stopTimeBox, stopTimeGetSecs] = ResponsePixx('StopNow',0, [0 0 0 0 0],[]);
      
      t2=GetSecs;
      %[T2, boxsecs, confidence] = PsychDataPixx('GetPreciseTime');

      trialtime_sec = t2-t1;
      
     

   if contains(var_eye_link, 'true')
        Eyelink('Message', 'KEY_PRESSED');
   end


      if keyCode(top_leftKey)==1 %
         response    = 1; 
         pressbutton = 1;
      end
      if keyCode(top_rightKey)==1 %%
         response    = 2; 
         pressbutton = 1;
      end
      if keyCode( bottom_leftKey)==1 %
         response    = 3; 
         pressbutton = 1;
      end
      if keyCode(bottom_rightKey)==1 %
         response    = 4; %%
         pressbutton = 1;
      end
      
      if keyCode(exit)==1
         break;
      end

      %%% if  keyCode(UP)==0
      %%%%%%%%%%%%%%%%%CORRECT/ERROR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if (TARGET_Position==1 && response==1) || (TARGET_Position==2 && response==2) || (TARGET_Position==3 && response==3) || (TARGET_Position==4 && response==4)
         correct=1;%CORRECT
      else
         correct=0;%ERROR
      end

        eyelink_stop_recording_and_write_variables(var_eye_link,sc.trialCount, orientation, [])


%% data file 

      
      data(trials2).trials2                  = trials2;
      data(trials2).typestairs               = numstair(n);
      data(trials2).targetposition           = TARGET_Position;
      data(trials2).response                 = response;
      data(trials2).correct                  = correct;
      data(trials2).trialtime                = trialtime_sec;
      data(trials2).disparitydisparity_arcsec= disparity_arcsec; %%%disparity_arcsec
      data(trials2).disparitylog             = log_disparity;    %%%log10(arsec)
      data(trials2).disparitypixels          = disparity_pixels; %%%Pixels

      save(filename,'expt','data');
   
      LRA=[trials2 numstair(n) log_disparity disparity_arcsec  TARGET_Position response correct trialtime_sec]
      
      modelT(numstair(n),:)=LIKELOGISTIC4AFC(log_disparity);
      
      %%8/25/2016 Ignacio changed the LIKELOGISTIC function parameters. New
      %%function found in file LIKELOGISTIC4AFC. Old function is at LIKELOGISTIC4AFC_old.m. AMG
      
      qpE = 1-modelT(numstair(n),:);
      qpA =   modelT(numstair(n),:);
      
      if correct==1
         qposteriori(numstair(n),:)=qposteriori(numstair(n),:).*qpA;
      else
         qposteriori(numstair(n),:)=qposteriori(numstair(n),:).*qpE;
      end

      if trials==1 || trials==2 || trials==3 || trials==4
         if correct == 1
            disparity(numstair(n))= disparity(numstair(n))-log10(1.4);
         else
            disparity(numstair(n))= disparity(numstair(n))+log10(1.4);;
         end
      else
         %m=[0.1:0.001:3,9]; %%Changed per Ignacio 9/6/2016 AMG
         m=linspace(log10(1),log10(3600),1000);
         disparity(numstair(n))=sum(qposteriori(numstair(n),:).*m)/sum(qposteriori(numstair(n),:));%%%Mean
      end
      
      
      if trials2==expt.trialsperstaircase%%ISP: I included this to add the response given in the presentation 30
         log_disparity=disparity(numstair(n));%%log10(disparity_arcsec)
         if log_disparity>3
            log_disparity=3;
            
         end
         
         disparity_arcsec=(10^log_disparity);
         disparity_pixels=((10^log_disparity)*expt.nx)/(expt.degreesfullscreenX*3600);%%PIXELS
         
         trials2=trials2+1;
         data(trials2).trials2=trials2;
         data(trials2).typestairs=1;
         data(trials2).targetposition=0;
         data(trials2).response=0;
         data(trials2).correct=3;
         data(trials2).trialtime=0;
         data(trials2).disparitydisparity_arcsec=disparity_arcsec;%%%disparity_arcsec
         data(trials2).disparitylog=log_disparity;%%%log10(arsec)
         data(trials2).disparitypixels=disparity_pixels;%%%Pixels
         
         
         save(filename,'expt','data');
         LRA=[trials2 1 log_disparity disparity_arcsec]
      end
      
      
      figure(1)
      
      H=find([data.typestairs]==1);
      if isempty(H)<1
         
         plot([data(H).disparitylog],'ro-');
         xlabel('Trials')
         ylabel('Disparity (log10(disparity arcsec))')
         
         axis([0 50 0.001 3])
         strmin = ['Log disparity = ',num2str(log_disparity)];
         text(30,2.7,strmin,'HorizontalAlignment','left','EdgeColor','black','FontSize',9,'Fontname','Times New Roman');
         
         strmin = ['Disparity arcsec = ',num2str(disparity_arcsec)];
         text(30,2.5,strmin,'HorizontalAlignment','left','EdgeColor','black','FontSize',9,'Fontname','Times New Roman');
         
         pause(0.01)
         %hold on
      end
      
      
      figure(1)
      
      H=find([data.typestairs]==2);
      if isempty(H)<1
         plot([data(H).disparitylog],'go-');hold on
         xlabel('Trials')
         ylabel('Disparity (log10(disparity arcsec))')
         
         axis([0 50 0.001 3])
         pause(0.01)
      end
      %hold on
      
      figure(1)
      
      H=find([data.typestairs]==3);
      if isempty(H)<1
         plot([data(H).disparitylog],'bo-')
         axis([0 50 0.01 3])
         xlabel('Trials')
         ylabel('Disparity (log10(disparity arcsec))')
         %hold on
      end
      pause(0.01)
   end
   
else
   
   expt.passedblintest='FAIL';
   save(filename,'expt');
end

status = fclose('all');

% eyelink - close the edf file
 newName = ['Asteroid_', global_param.ID, '_',char(datetime('now','TimeZone','local','Format','y_M_d_HH_mm')),'.edf'];                
[status] = eyelink_close_edf_file(var_eye_link,dummymode,el,window,height, edfFile, newName);



%% end of program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('TextFont',window, 'Times');
Screen('TextSize',window, 40);
Screen('TextStyle', window, 1);
Screen('SelectStereoDrawBuffer',window,1);
Screen('DrawText', window, 'Thank you!', expt.nx/2-150, 220, [255 255 255]);
Screen('SelectStereoDrawBuffer',window,0);
Screen('DrawText', window, 'Thank you!', expt.nx/2-150, 220, [255 255 255]);
Screen(window,'Flip');



% Clear screen
sca;

% ListenChar(0);
KbQueueRelease

% Package up the important data and store it
if exist('data','var') == 1
sub(1).data  = data;
end
sub(1).now   = now;
sub(1).date  = date;
sub(1).clock = clock;

%% results table
baseFileName = SUBJECT + "_" + sub(1).date + '_asteroid' + "_" + num2str(sub(1).clock(4))+"-"+num2str(sub(1).clock(5));

if global_param.Retest == true
    baseFileName = baseFileName + "_retest_";
end

[filename, global_param] = results_table(baseFileName, global_param, EYE_TEST, AMB_EYE, []);

writetable(struct2table(data),filename)

%% end of the script


