% Here are all the values useful to launch any kind of experiment 

function  global_param = GetGlobalVariables()


%% get all your screen paramaters here 

global_param.screen_size = [700 392]; % [300 187]for the laptop. [horizontal vertical] in mm will change when using Display++
global_param.stim_size = 1;           % size of the stim in dva - was 1.13 dva but trying 1 to see if better results 
global_param.distance = 1500;         % distance from the screen in mm
global_param.distance_Snellen = 2500; % distance from the screen in mm (for the Snellen and Snellen crowded tests)
global_param.fusionFrameLength = 552; % was at 540 for the binoc experiment - change, must be a t 4,4 x 4,4 dva instead 
                                      % but decided to put it at 552 (512x512 + 20 of frame width)
global_param.lineWidth = 20;          % the width in question
global_param.pix_shift = [0;0];       % this is recorded in contrast interleaved and used for snellen (calculates the maximum size)
global_param.reduced = false;

%% all the participant parameters 
global_param.ID = '1'; % default at 0 --> indicates test 
global_param.AMB_EYE = '?';
global_param.Retest = false;
global_param.EYE_TEST = '?';

%% parameters from the CUTOFF
global_param.cut_off = '?';
global_param.cut_off_AE = '?';
global_param.cut_off_FE = '?';
global_param.cut_off_BE = '?';

global_param.cut_off_dva = '?';
global_param.cut_off_AE_dva = '?';
global_param.cut_off_FE_dva = '?';
global_param.cut_off_BE_dva = '?';

%% parameters from the Contrast Interleaved test
global_param.contrast = '?';
global_param.contrast_AE = [0.5 0.5 0.5 0.5 0.5 0.5];
global_param.contrast_FE = '?';
global_param.contrast_BE = '?';
global_param.reduced = false;
global_param.freqs = [0.0625 0.125 0.25 0.5 0.75 1];

%% parameters from the Binocular Orientation
global_param.binoc = '?';
global_param.binoc_normal_testing = false;

%% parameters from the Dichoptic test
% all those values are important for the VR training
global_param.dichop = '0.1';
global_param.dichop_contrast_high = 0.8;
global_param.dichop_contrast_low = [];

%% parameters from the Asteroid test 
% not recorded at the moment 

%% parameters from the Snellen 
global_param.MAR_min_theory = [];
global_param.logMAR_min_theory = []; % just indication of the minimum possible 
global_param.logMAR_AE = [];
global_param.logMAR_FE = [];
global_param.logMAR_BE = [];
global_param.logMAR = [];

%% parameters from the Snellen crowded 
global_param.MAR_min_theory_crowded = [];
global_param.logMAR_min_theory_crowded = []; % just indication of the minimum possible 
global_param.logMAR_AE_crowded = [];
global_param.logMAR_FE_crowded = [];
global_param.logMAR_BE_crowded = [];
global_param.logMAR_crowded = [];

%% end
save('data/Global_parameters/global_param.mat','global_param');
