function [expt] = asteroid_param(SUBJECT,AMB_EYE, EYE_TEST)
%ASTEROID_PARAM Summary of this function goes here
%   Detailed explanation goes here
expt.subject= SUBJECT; % INITIALS
expt.age    = '?';   % AGE not useful with our setting
expt.sex    = '?';    % M or F, not useful with our settings
expt.AMB_EYE = AMB_EYE;
expt.EYE = EYE_TEST;

%% screen parameters

expt.monitor         = 'me' ; %'LG 3D D2332' % changed for display++
expt.sizescreenXcm   =  69.9; %83.5; % 51; 52  % cm width of the screen
expt.sizescreenYcm   =  39; %47; % 28.5; % cm height of the screen
expt.viewingdistance =  150; %140; % 100;  % cm  Distance to the monitor
expt.tempfreq        =  10; % HZ Temporal frequency of the random dots

expt.keysmeaning        = 'A top-left; Z bottom-left; K top-right; M bottom-Right'; 
expt.staircases         = 1;   % expt.staircases=[1 2 3] if you want to run three interleaved staicases
expt.trialsperstaircase = 60;  % 50
expt.firstdisparitylog  = 3;   % (1000 seconds of arc)
expt.presentationTime   = Inf; % milisecs. This parameter is not used

expt.screenID = 0; %was 1


[expt.nx,expt.ny] = Screen('WindowSize',expt.screenID);    % Should be 1920x1080
%I am changing it here to consider the size after setting the binocular
%effect
expt.nx = 1920;
expt.ny = 540; %here is the change %expt.ny               = expt.ny;  %/2

expt.pixelaspectratio = 2;
expt.bgcol            = 0.0;  % background colour 
expt.dotdensity       = 0.4;  % controls how many dots there are in each frame
expt.dotsizepix       = 23;   % was 28 in former exp;   % width of dots in pixels %was 7 7/6/2016
%Changed dot density and size 10/3/2016 to match the dot density and size
%from the tablet game. Former density was 0.2 and size 14 pixels.
expt.dottype          = 2;    % 2 = circles with anti-aliasing (is it supported by hardware?), 1=squares
expt.tgtXsizepix      = 335; %expt.nx/8;                               % should be 240 
expt.tgtYsizepix      = 168; %expt.tgtXsizepix/expt.pixelaspectratio;  %was 240 % was 135 
expt.Nintrotrials     = 5;    %number of easy trials to begin with

expt.sizeimagenpixels=1000;%%PIXELS

expt.degreesfullscreenX = 2*atand(((expt.sizescreenXcm/2)/expt.viewingdistance)); % dva, very important to control the final aspect of the test
expt.degreesfullscreenY = 2*atand(((expt.sizescreenYcm/2)/expt.viewingdistance));

% Background fills the screen:
expt.bgxcen  = expt.nx/2;
expt.bgycen  = expt.ny/2;
expt.bgxsize = expt.nx;
expt.bgysize = expt.ny; 

% Stimulus will fill the screen
% We want the stimulus to be the biggest square that will fit on the screen
% In practice, with interleaved row stereo, it has to be a rectangle
% elongated horizontally
expt.stimNpixX     = expt.nx;  % Number of pixels the stimulus occupies horizontally
expt.stimNpixY     = expt.ny; % Number of pixels the stimulus occupies vertically %7/6/2016 was *1
expt.sizeimageXcm  = expt.sizescreenXcm*expt.stimNpixX/expt.nx;
expt.sizeimageYcm  = expt.sizescreenYcm*expt.stimNpixY/expt.ny;
expt.degreesimageX = 2*atand(((expt.sizeimageXcm/2)/expt.viewingdistance));
expt.degreesimageY = 2*atand(((expt.sizeimageYcm/2)/expt.viewingdistance));

%% Display position of target and background (might change, was perfect for 1920x1200, must rescale for 1920x1080)

% size of the areas of dots
expt.BGXsizepix = 723;% was 500 % the size in pixels of the length of one area of dots % set up at 722 pixels to match 10.0224 dva like in the original article
expt.BGYsizepix = 240; %was 200 % the size in pixels of the height of one area of dots % we would have to set it up at 261 pixels to match 7.9928 dva like in the original article 

% Background and TARGET_Position:
expt.nBGdots = round(expt.dotdensity * expt.BGXsizepix*expt.BGYsizepix/expt.dotsizepix/expt.dotsizepix);
expt.nTGdots = round(expt.dotdensity * expt.tgtXsizepix*expt.tgtYsizepix/expt.dotsizepix/expt.dotsizepix);

% x,y location of TARGET_Position: y location is fixed, x can be elft or right
expt.tgtycen = [ -140 -140 125 125]+expt.stimNpixY/2; %expt.tgtycen = [ -115 -115 +315 +315]+expt.stimNpixY/2;
expt.tgtxcen = [ 0.29 0.70 0.29 0.70]*expt.stimNpixX; %expt.tgtxcen = [ 0.35 0.64 0.35 0.64]*expt.stimNpixX;

%% Others

expt.bgcol       = 0; % black
expt.multisample = 0; % ISP: Leave it at 0, with dotshape=2 you have dots with antialiasing


end

