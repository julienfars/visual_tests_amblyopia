function [HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo)

    h = round(windowRect(3));
    v = round(windowRect(4));

    DisplaySize = global_param.screen_size;

    centerV = v / 2;
    centerHsti = h / 2;

    hsize = h / DisplaySize(1); %pix per mm in horizontal
    vsize = v / DisplaySize(2); %pix per mm in vertical

    PixelPerDeg = 1 / atand(1 / hsize / global_param.distance); %pixels per dva
    hpixel = 1 / PixelPerDeg * 60;
    vpixel = 1 / PixelPerDeg * 60;

    if fixCross
        if stereo == 100
            fixGapV = round(10 / vpixel / 2);
            fixGapH = round(10 / vpixel);
        elseif stereo == 101
            fixGapV = round(10 / vpixel);
            fixGapH = round(10 / vpixel / 2);
        else 
            fixGapV = round(10 / vpixel);
            fixGapH = round(10 / vpixel);
        end
    else
        fixGapV = round(10 / vpixel);
        fixGapH = round(10 / vpixel);
    end

    a = round(25 / vpixel); % thickness in pixels was 6
    b = round(100 / hpixel); % length in pixels was 40

    if fixCross
        baseRectH = round([0 0 b a * 0.5]);
        baseRectV = round([0 0 a b * 0.5]);
        baseSquare = round([0 0 b - a (b - a) * 0.5]);
    else
        baseRectH = [0 0 b a];
        baseRectV = [0 0 a b];
        baseSquare = [0 0 b - a b - a];
    end

    [HCl, HCr, pixelsPerPress] = createHalfCrosses(windowRect, centerHsti, centerV, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare);

end

function [HCl, HCr, pixelsPerPress] = createHalfCrosses(windowRect, centerHsti, centerV, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare)

    %[xCenter, ~] = RectCenter(windowRect);
    %[~, yCA] = RectCenter(baseRectV);
    %[~, xCB] = RectCenter(baseRectH);
    % Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%get the center of the squares 
[xSquare, ySquare] = RectCenter(baseSquare);

%get the center of the vertical cross arrow 
[xCA, yCA] = RectCenter(baseRectV);

%get the center of the vertical cross arrow 
[xCB, yCB] = RectCenter(baseRectH);
    %HCl = createHalfCross(windowRect, centerHsti, centerV - yCA - fixGapV, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare, xCenter, xCB);
    %HCr = createHalfCross(windowRect, centerHsti, centerV + yCA + fixGapV, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare, xCenter, xCB);
    %first half cross
    HCl(:, 1) = CenterRectArrayOnPoint(baseRectV, ...
            centerHsti,...
            centerV-yCA-fixGapV); % top cross arrow
    HCl(:, 2) = CenterRectArrayOnPoint(baseRectH, ...
            centerHsti-fixGapH-xCB,...
            centerV); % left cross arrow 
    HCl(:, 3) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV-yCA-fixGapV-yCB);% top left square
    HCl(:, 4) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV-yCA-fixGapV-yCB); % top right square 
    HCl(:, 5) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV+fixGapV+yCA+yCB); % bottom left square 
    HCl(:, 6) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV+fixGapV+yCA+yCB); % bottom right square
    
    %second half cross
    
    
    HCr(:, 1) = CenterRectArrayOnPoint(baseRectV, ...
            centerHsti,...
            centerV+yCA+fixGapV); % bottom cross arrow 
    HCr(:, 2) = CenterRectArrayOnPoint(baseRectH, ...
            centerHsti+fixGapH+xCB,...
            centerV); % right cross arrow 
    HCr(:, 3) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV-yCA-fixGapV-yCB);% top left square
    HCr(:, 4) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV-yCA-fixGapV-yCB); % top right square 
    HCr(:, 5) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV+fixGapV+yCA+yCB); % bottom left square 
    HCr(:, 6) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV+fixGapV+yCA+yCB); % bottom right square
    pixelsPerPress = 1;

end
%{
function halfCross = createHalfCross(windowRect, centerHsti, centerY, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare, xCenter, xCB)
    halfCross = zeros(4, 6);

    halfCross(:, 1) = CenterRectArrayOnPoint(baseRectV, centerHsti, centerY);
    halfCross(:, 2) = CenterRectArrayOnPoint(baseRectH, centerHsti - fixGapH - xCB, centerY);
    halfCross(:, 3) = CenterRectArrayOnPoint(baseSquare, centerHsti - fixGapH - xCB, centerY - fixGapV - baseRectV(4) / 2);
    halfCross(:, 4) = CenterRectArrayOnPoint(baseSquare, centerHsti + fixGapH + xCB, centerY - fixGapV - baseRectV(4) / 2);
    halfCross(:, 5) = CenterRectArrayOnPoint(baseSquare, centerHsti - fixGapH - xCB, centerY + fixGapV + baseRectV(4) / 2);
    halfCross(:, 6) = CenterRectArrayOnPoint(baseSquare, centerHsti + fixGapH + xCB, centerY + fixGapV + baseRectV(4) / 2);


end
%}

