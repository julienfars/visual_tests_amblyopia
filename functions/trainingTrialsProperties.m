%% Function for training trials
function propertiesMat = trainingTrialsProperties(sc, num_training, gaborDimPix, aspectRatio, phase, contrast)
    % Set properties for training trials
    if sc.trialCount < num_training
        StimLevel = 3;
    else
        StimLevel = sc.curLevel;
    end

    % Convert StimLevel to linear units
    linStimLevel = (10^StimLevel);

    % Calculate frequency and sigma
    freq = linStimLevel / gaborDimPix;
    sigma = gaborDimPix / 6;

    % Make a properties matrix for the Gabor
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
end
