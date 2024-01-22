function [orientation, propertiesMat, ARROW_X, ARROW_Y, acc_resp, ...
    ATT_TRIAL] = setupDichopticRandomisers(contrast_low, contrast_high, ...
    xPosVectorUP, yPosVectorUP, xPosVectorDOWN, yPosVectorDOWN, ...
    propertiesMat)

    % Set up trial parameters.

    % Randomly set orientation
    if rand < 0.5
        orientation = 90 - 45;
    else
        orientation = 90 + 45;
    end

    % Change 80 by 0.8 if needed (80 in %)
    if rand < 0.5 % the good answer is the bottom one
        propertiesMat(1, 3) = contrast_low;
        propertiesMat(2, 3) = contrast_high;

        ARROW_X = xPosVectorUP;
        ARROW_Y = yPosVectorUP;

        acc_resp = 'bottom';

    else % the good answer is the top one
        propertiesMat(1, 3) = contrast_high;
        propertiesMat(2, 3) = contrast_low;

        ARROW_X = xPosVectorDOWN;
        ARROW_Y = yPosVectorDOWN;

        acc_resp = 'top';
    end

    % Randomly set ATT_TRIAL
    if rand < 0.2
        ATT_TRIAL = 'true';
    else
        ATT_TRIAL = 'false';
    end
end