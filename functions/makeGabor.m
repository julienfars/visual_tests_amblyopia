function grayscaleImageMatrix = makeGabor(PixPerDeg, x0, xextd, y0, yextd, contrast, cycPerDeg, sigma, phase, tiltInDegrees, locCx, locCy)
    % Tilt calculation
    tiltInRadians = (-tiltInDegrees) * pi / 180;
    a = cos(tiltInRadians) * (cycPerDeg / PixPerDeg);
    b = sin(tiltInRadians) * (cycPerDeg / PixPerDeg);

    % Meshgrid setup
    widthArray = -x0:xextd - locCx;
    heightArray = -y0:yextd - locCy;
    [x, y] = meshgrid(widthArray, heightArray);

    % Grating creation
    gratingMatrix = sin(a * x + b * y + phase / 180 * pi);

    % Gaussian mask
    circularGaussianMaskMatrix = exp(-(x.^2 + y.^2) / (sigma * PixPerDeg)^2);
    circularGaussianMaskMatrix(circularGaussianMaskMatrix < 0.005) = 0;

    % Image creation
    grayscaleImageMatrix = gratingMatrix .* circularGaussianMaskMatrix * contrast / 100;
end




