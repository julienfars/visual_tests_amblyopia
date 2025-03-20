function [sinetex, phase, freq, tilt, contrast_high, ...
    contrast_low] = createGratingTexture(window, gaborDimPix, ...
    CUTOFF, CONTRAST, high, low)
    

% Initial stimulus params for the grating:
    virtualSize = gaborDimPix;
    phase = 0;
    freq = 0.4*CUTOFF; % following Liu & Zhang paper, we only use 40% of the cut-off frequency
    tilt = 0;
    contrast_high = high;

    if isempty(low)
        contrast_low = abs(exp(-1.6*CONTRAST)-0.2);
    else 
        contrast_low = low;
    end

    %contrast_low = (0.8 - ((CONTRAST)*1.414));
    % fplot(@(x) (0.8 - ((x)*1.414)),[0 1])
    % fplot(@(x) abs(exp(-1.6*x)-0.2),[0 1]) % YES! better way to do it
    
    % radius of the disc edge
    radius = virtualSize / 2;
    % smoothing sigma in pixel
    sigma = 55;
    % use alpha channel for smoothing?
    useAlpha = true;
    % smoothing method: cosine (0) or smoothstep (1) or inverse smoothstep (2)
    smoothMethod = 1;
    
    % the following function creates sine gratings and not gabor patches. As a
    % reminder, a gabor patch is sine grating multplied by a gaussian window.
    % This is what transform a sine grating (squre shaped grating) in a gabor
    % patch (circular grating with fading edges). BUT this function also
    % handles apertures (for the circular shape) AND smoothing edges. We can
    % therefore reproduce a gabor patch 'artificially'. Ther reason why we use
    % this function instead of the regular gabor one is because of the
    % incompatibility between the gabor function/texture and the noise texture
    % when mixed using the stereovision. 
    sinetex = CreateProceduralSmoothedApertureSineGrating(window, virtualSize, virtualSize,...
              [.5 .5 .5 1], radius, [], sigma, useAlpha, smoothMethod);

end