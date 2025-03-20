function [allRects, propertiesMat] = setupGratingsParameters(xCenter, yCenter, gaborDimPix, nGabors, phase, freq, contrast_high)
    % Set up Gabors with specified parameters.

    % Initialize variables
    xPos = xCenter;
    yPos = ceil(yCenter - (gaborDimPix/2)/2); % the top gabor
    gap = (gaborDimPix/2); % in pixels 

    % Make the destination rectangles for all the Gabors in the array
    baseRect = [0 0 1 0.5] .* gaborDimPix;
    allRects = nan(4, nGabors);
    allRects(:, 1) = CenterRectOnPointd(baseRect, xPos, yPos);
    allRects(:, 2) = CenterRectOnPointd(baseRect, xPos, yPos + gap);

    % Create properties matrix
    propertiesMat = repmat([phase, freq, contrast_high, 0], nGabors, 1);
end
