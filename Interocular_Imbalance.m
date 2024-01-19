%{
Welcome to the Amblyopia Study Test Battery.

This script conducts a series of visual tests to assess various aspects of the amblyopic visual experience. 
If you have questions, contact Juju (julien.fars@ndcn.ox.ac.uk).

Note: Adjust parameters in the GetGlobalVariables.m script before running the tests.

This battery utilizes modified scripts from different researchers:
- Alex S Baldwin (Staircase protocol)
- Jun-Yun Zhang (Dichoptic test)
- Alice Grasso McCaslin (Asteroid test script)

Inspired by Peter Scarfe's work (https://peterscarfe.com/ptbtutorials.html).
%}

%changes to make it functional 
%{
- add training trials? 
%}

%% Setup
sca;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('Interocular_Imbalance.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths 
KbName('UnifyKeyNames'); %set up the keyboard for answers 

%% Eyelink Initialization
[dummymode, var_eye_link] = eyelink_init(1);

%% retrieve data from previous test

New_patient = getNewPatientInfo(); % popup window that control if this is a new participant 
retest = getRetestInfo(global_param); % popup window that control if this is a retest or not

if contains(New_patient, 'true')
    global_param = GetGlobalVariables(); % set up of a 'brand new' "global_param" structure file 
else
    if isfile("global_param.mat")
        load("global_param.mat");
    else
        global_param = GetGlobalVariables();
    end
end 

% Set retest variable
global_param.Retest = contains(retest, 'true');

%% Participant Information 
% calls global.param to retrive information from the screen size, distance
% from the screen, etc...
current_test = 'interocular_imbalance';

% Call the function to get participant information
[SUBJECT, SIZE, DISTANCE, EYE_TEST, AMB_EYE, edfFile, fixCross, FREQS_test, CUTOFF, global_param] = getParticipantInfo(global_param, current_test);
global_param.binoc_normal_testing = normal_testing;
num_freqs = numel(FREQS_test); 

%% launch eyelink parameters
[ELsoftwareVersion,ver, versionstring, r1, vnumcell] = eyelink_param(var_eye_link, edfFile, dummymode);

%% Screen stuff
% Call the function to set up screen parameters
[window, windowRect, width, height] = setupScreen();

%% Eyelink Calibration
% starts the calibration of the eye-tracking (must be performed before each test because the condition changes)
[el] = eyelink_calibration(var_eye_link,window, stereoMode, [], width, height);

%% Other parameters
% Call the function to set up other parameters
[xCenter, yCenter, leftKey, rightKey, upKey, downKey, escapeKey, spaceKey, skipKey] = setupOtherParameters(window, windowRect)

%% clear screen of host PC 
% clears the screen of the host PC so we can start the test

eyelink_clear_screen(var_eye_link,el)

%% Fusion crosses/frames
[HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereoMode); % fusion cross function, only used when stereomode. The resulting variables are the Half Crosses(HC) for each eye (r and l)
[FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode); % fusion frame function, used all time. The resulting variables are the black and white parts of the fusion frame (and  for both eyes)

%% Basic Gabor parameters

% Call the function to set up basic Gabor parameters
[gaborDimPix, PixelPerDeg, size_stim_pix, FREQS] = setupBasicGaborParameters(windowRect, screen_size, distance, stim_size, DISTANCE, FREQS_test);


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

numStaircases   = numel(scRightRules);

    % these parameters control the staircase 
StimLevels      = log10(1):0.00001:log10(100); % stimulus levels from 1 to 100 (log) - which should provide around 60 steps
initStepSize    = 0.4;      % staircase step size before first reversal
stepSize        = 0.2;      % staircase step size after first reversal - has more reversals (see staircase code)
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
nb_table = numel(FREQS);
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



%% launch the experiment staircase

    % keep looping until all staircases conclude
    while ~all([staircaseArray(:).isFinished])
  
     % run the fixing cross before the trial
   [HC1,HC2, FF1w, FF1b, FF2w, FF2b, diff, doubleScreen] = fix_cross(fixCross,window, escapeKey, leftKey, rightKey, upKey, downKey, spaceKey, ...
doubleScreen, AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb, pixelsPerPress);

  
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
        sigma = gaborDimPix/6;
        % make properties matrixes for the Gabors
        propertiesMatAE = [phase, freq, sigma, contrastAE, aspectRatio, 0, 0, 0];
        propertiesMatFE = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];

        %% Eyelink Start trial
eyelink_start_trial(var_eye_link, staircaseArray(iSC).trialCount, orientation_link, [])

    
         %% display the stim
    [buffer_num_AE, buffer_num_FE, angle_AE, angle_FE, angle_results_AE, angle_results_FE] = displayStimulus_binocular_imbalance(window, gabortex, xCenter, yCenter, angular_1, angular_2, propertiesMatFE, propertiesMatAE, gaborDimPix, diff, FF1b, FF1w, FF2b, FF2w);

%% eyelink - start recording
[err] = eyelink_start_recording(var_eye_link);

%% time presentation 
   WaitSecs(0.2);
   %KbStrokeWait; % debug purposes!!!!!!

   rectColor = [1 1 1];
   dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
   dstGab_center1 = CenterRectArrayOnPoint(dstGab_center, xCenter, yCenter);
   Screen('SelectStereoDrawBuffer',window,0);
   Screen('FillRect', window, rectColor*0.5, dstGab_center1);
   Screen('FillRect', window, black, FF1b);
   Screen('FillRect', window, white, FF1w);
   dstGab_center = [0 0 1 0.5] .* gaborDimPix; %use this instead of gaborDimPix for changing the vertical size :), use for both gabor [0 0 1 1]
   dstGab_center2 = CenterRectArrayOnPoint(dstGab_center, xCenter+diff(1,:), yCenter+diff(2,:));
   Screen('SelectStereoDrawBuffer',window,1);
   Screen('FillRect', window, rectColor*0.5, dstGab_center2);
   Screen('FillRect', window, black, FF2b);
   Screen('FillRect', window, white, FF2w);

   Screen('Flip', window);
   
%% Wait for a button press


   onsetTime = GetSecs;



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
