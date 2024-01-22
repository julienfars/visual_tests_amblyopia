function [angular_1, angular_2, orientation_link] = randomizeOrientation_Interocular_Imbalance(degrees)
    % This function randomly sets the orientation parameters for a trial.

    if rand < 0.5
        % For each trial, the orientation is set randomly,
        % counterclockwise instead of clockwise
        angular_1 = degrees;
        angular_2 = 360-degrees;
        orientation_link = round(angular_2);
    else
        angular_1 = 360-degrees;
        angular_2 = degrees;
        orientation_link = round(angular_2);
    end
end