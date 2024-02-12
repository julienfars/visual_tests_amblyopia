% Improved Perlin Noise Generator with Edge Handling
function noise = perlin_noise(width, height, scale)
    % Generate larger grid to avoid edge issues
    largeWidth = width + 30;
    largeHeight = height + 30;
    noise = zeros(largeHeight, largeWidth);
    persistence = 0.5;
    numOctaves = 5;

    for octave = 1:numOctaves
        octaveScale = 2^octave;
        [x, y] = meshgrid(1:largeWidth, 1:largeHeight);
        x = x / octaveScale;
        y = y / octaveScale;
        % Generate noise for the larger grid
        octaveNoise = interp2(randn(largeHeight, largeWidth), x, y);
        % Crop the noise to the desired size and add to the corresponding region of the main noise
        noise(16:end-15, 16:end-15) = noise(16:end-15, 16:end-15) + octaveNoise(16:end-15, 16:end-15) * persistence;
        persistence = persistence * 0.5;
    end
    noise = noise / sum(persistence);
    % Crop the final noise to the desired size
    noise = noise(32:height, 32:width);
end
