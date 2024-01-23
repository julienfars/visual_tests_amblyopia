function [orientation, E_shape] = randomizeOrientation_snellen()
    % Randomly set the orientation for each trial.

    randVal = rand();

    if randVal <= 0.25
        orientation = 90;
        E_shape = [0 0 0 0 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0];
    elseif randVal > 0.25 && randVal <= 0.5
        orientation = 180;
        E_shape = [0 0 0 0 0; 0.5 0.5 0.5 0.5 0; 0 0 0 0 0; 0.5 0.5 0.5 0.5 0; 0 0 0 0 0];
    elseif randVal > 0.5 && randVal <= 0.75
        orientation = 270;
        E_shape = [0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0 0 0 0];
    else
        orientation = 0;
        E_shape = [0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0];
    end
end