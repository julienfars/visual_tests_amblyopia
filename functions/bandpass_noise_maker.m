function newnoise = bandpass_noise_maker(noisesize, fc, fontsize)
    % Generate Gaussian noise
    randguass = randn(noisesize/2, noisesize/2) / 2;
    
    % Refine the noise
    while any(abs(randguass(:)) > 1)
        m = abs(randguass) > 1;
        rrr = m .* (randn(noisesize/2, noisesize/2) - 0.5) / 2;
        randguass = rrr + randguass .* (1 - m);
    end

    % Upsample and add a row and a column
    wn = imresize(randguass, 2);
    wn = [[wn; rand(1, size(wn, 1))] rand(size(wn, 2) + 1, 1)] / 2 + 0.5;

    % Compute FFT of white noise
    wnf = fftshift(fft2(wn));

    % Create a 1/f filter
    [xx, yy] = meshgrid(-noisesize/2:noisesize/2, -noisesize/2:noisesize/2);
    r = sqrt(xx.^2 + yy.^2);
    r(noisesize/2 + 1, noisesize/2 + 1) = 1;
    z = 1 ./ r;

    % Generate a cosine grating
    [x, y] = meshgrid(-noisesize/2:noisesize/2, -noisesize/2:noisesize/2);
    period = fontsize / fc;
    g = (1 + cos(2 * pi * x / period)) / 2;
    gf = fftshift(fft2(g));
    agf = abs(gf);

    % Create a band-pass filter
    f = create_band_pass_filter(agf, fc, noisesize, fontsize, z);

    % Apply the filter to white noise
    fgf = f .* wnf;

    % Inverse FFT
    igf = ifft2(fgf);
    aigf = abs(igf);
    meanlum = mean(aigf(:));

    % Adjust contrast and scale noise
    newnoise = (aigf - meanlum) * 5;
end

function f = create_band_pass_filter(agf, fc, noisesize, fontsize, z)
    bw = 1;
    fl = 10^(log10(fc) - log10(2 * bw) / 2);
    fh = 10^(log10(fc) + log10(2 * bw) / 2);
    dc = noisesize / (fontsize / fc);
    dl = noisesize / (fontsize / fl);
    dh = noisesize / (fontsize / fh);
    r12 = dl^2;
    r22 = dh^2;
    f = zeros(noisesize + 1, noisesize + 1);
    
    % Create a band-pass filter using a cosine curve
    xx = 1:3;
    dd = dl - floor(dl);
    p = 2 * pi * (2 - dd) / acos(0);
    dlEdge = fliplr((1 + cos(2 * pi * xx / p)) / 2);
    if dd < 0.3
        dlEdge(1) = 0;
    end

    dd = dh - floor(dh);
    p = 2 * pi * (1 + dd) / acos(0);
    dhEdge = (1 + cos(2 * pi * xx / p)) / 2;
    if dd < 0.3
        dhEdge(3) = 0;
    end
    
    tx = zeros(1, floor(noisesize/2) + 1);
    tx(floor(dl):floor(dl+2)) = dlEdge;
    tx(floor(dh+1):floor(dh+3)) = dhEdge;
    tx(floor(dl+3):floor(dh)) = 1;

    for i = 1:noisesize + 1
        i2 = (i - floor(noisesize/2))^2;
        for j = 1:noisesize + 1
            j2 = (j - floor(noisesize/2))^2;
            r = floor(sqrt(i2 + j2));
            if r < dh + 3 && r > dl - 3
                f(i, j) = tx(r);
            end
        end
    end
    f(floor(noisesize/2) + 1, floor(noisesize/2) + 1) = 1;
    f = f .* z * 100;
end
