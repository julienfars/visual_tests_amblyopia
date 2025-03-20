%% Function for training trials
function propertiesMat = trainingTrialsProperties(sc, num_training, gaborDimPix, aspectRatio, phase, contrast, global_param)
    % Set properties for training trials
    if sc.trialCount < num_training
        StimLevel = 0.3;
    else
        StimLevel = sc.curLevel;
    end

    % Convert StimLevel to linear units
    linStimLevel = (10^StimLevel);
    
%     If you go above 1cpp of gabor frequency, pscyhtoolbox glitched and displays lower gabor frequency
%     The following if loop prevents this situation
    if linStimLevel > gaborDimPix 
        linStimLevel = gaborDimPix;
    end
    
    % Calculate frequency and sigma
    freq = linStimLevel*global_param.stim_size / gaborDimPix;
    sigma = gaborDimPix / 6;

    % Make a properties matrix for the Gabor
    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
end
