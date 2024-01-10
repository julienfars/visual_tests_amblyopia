sca;
commandwindow; % just to be sure to open the command window
filepath=fileparts(which('extract_variables.m')); %determine what is the filepath of the script 
cd(filepath); % add the filepath to matlab filepaths (useful to save the files at the end of the test)

load("global_param.mat");

folder = 'data/mat_files';
baseFileName = global_param.ID + "_" + date + '_parameters_';
filename = fullfile(folder, baseFileName + '.csv');
while numberSuffix < 500 % Exit at 500 as a failsafe, just in case all files exist.
  if exist(filename, 'file')
    % Construct a new filename.
    baseFileName = sprintf(global_param.ID + "_" + date + "_parameters__%d", numberSuffix);
    filename = fullfile(folder, baseFileName + '.csv');
    % Prepare for next time, in case this name also existed.
    numberSuffix  = numberSuffix  + 1;
  else
    break; % Out of while loop
  end
end

writematrix(jsonencode(global_param),filename) 
