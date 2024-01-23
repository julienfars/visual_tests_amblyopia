function [MAR, logMAR] = convert_logmar(optotype, distance, stereo, pix)
    % CONVERT_LOGMAR - Convert optotype size to MAR (Minutes of Arc) and logMAR
    
    % Inputs:
    % - optotype: size of the optotype in pixels
    % - distance: viewing distance in centimeters
    % - stereo: stereo mode (not used in the calculation)
    % - pix: size of one pixel in centimeters
    
    % Outputs:
    % - MAR: size of the optotype in Minutes of Arc (dva * 60)
    % - logMAR: logarithm (base 10) of the MAR
    
    % Calculate the MAR (Minutes of Arc)
    MAR = 2 * atand((optotype * pix / 2) / distance) * 60;
    
    % Calculate the logMAR
    logMAR = log10(MAR);
end