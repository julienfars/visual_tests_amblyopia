function [gabortex, aspectRatio, phase, contrast] = createGaborTexture(window, gaborDimPix, current_test)
    % This function creates a procedural Gabor texture with specified
    % parameters.

    % Parameters for the Gabors
    backgroundOffset = [0.5 0.5 0.5 0.0];
    disableNorm = 1;
    preContrastMultiplier = 0.5;
    aspectRatio = 1.0;
    phase = 0;
    if contains(current_test, 'cutoff')
        contrast = 1; 
    else 
        contrast = [];% will be calculated by the contrast procedure
    end

    % Build a procedural gabor texture
    gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
        backgroundOffset, disableNorm, preContrastMultiplier);
end