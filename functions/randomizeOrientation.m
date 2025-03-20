%% Function for randomization
% for each trial the orientation is set randomly. Careful, the Gabor 
    % code from the psychtoolbox is not using degrees clockwise but
    % counterclockwise. This is why the angular variable is used for the 
    % code but the orientation variable is used for the dataframe. 
    % Call the function for randomization
function [angular, orientation] = randomizeOrientation()
    % Randomly set orientation
    if rand < 0.5
        angular = 45;
        orientation = 315;
    else
        angular = 315;
        orientation = 45;
    end
end