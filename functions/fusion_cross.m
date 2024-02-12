function [HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo)

    h = round(windowRect(3));
    v = round(windowRect(4));

    DisplaySize = global_param.screen_size;

    centerV = v / 2;
    centerHsti = h / 2;

    hsize = h / DisplaySize(1); %pix per mm in horizontal
    vsize = v / DisplaySize(2); %pix per mm in vertical

    PixelPerDeg = 1 / atand(1 / hsize / global_param.distance); %pixels per dva
    hpixel = (1 / PixelPerDeg) * 60;
    vpixel = (1 / PixelPerDeg) * 60;

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


    a = round(25 / vpixel); % thickness in pixels was 6
    b = round(100 / hpixel); % length in pixels was 40

        if stereo == 100
        baseRectH = round([0 0 b a * 0.5]);
        baseRectV = round([0 0 a b * 0.5]);
        baseSquare = round([0 0 b - a (b - a) * 0.5]);
        elseif stereo == 101
        baseRectH = round([0 0 b * 0.5 a]);
        baseRectV = round([0 0 a* 0.5 b]);
        baseSquare = round([0 0 (b - a) * 0.5 (b - a)]);
        else
        baseRectH = [0 0 b a];
        baseRectV = [0 0 a b];
        baseSquare = [0 0 b - a b - a];
        end
    

    [HCl, HCr, pixelsPerPress] = createHalfCrosses(windowRect, centerHsti, centerV, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare);

end

function [HCl, HCr, pixelsPerPress] = createHalfCrosses(windowRect, centerHsti, centerV, fixGapH, fixGapV, baseRectH, baseRectV, baseSquare)

    %get the center of the vertical cross arrow 
    [xCA, yCA] = RectCenter(baseRectV);
    
    %get the center of the vertical cross arrow 
    [xCB, yCB] = RectCenter(baseRectH);

    HCl(:, 1) = CenterRectArrayOnPoint(baseRectV, ...
            centerHsti,...
            centerV-yCA-fixGapV+4); % top cross arrow
    HCl(:, 2) = CenterRectArrayOnPoint(baseRectH, ...
            centerHsti-fixGapH-xCB,...
            centerV+4); % left cross arrow 
    HCl(:, 3) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV-yCA-fixGapV-yCB+4);% top left square
    HCl(:, 4) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV-yCA-fixGapV-yCB+4); % top right square 
    HCl(:, 5) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV+fixGapV+yCA+yCB+4); % bottom left square 
    
    %second half cross
    HCr(:, 1) = CenterRectArrayOnPoint(baseRectV, ...
            centerHsti,...
            centerV+yCA+fixGapV+4); % bottom cross arrow 
    HCr(:, 2) = CenterRectArrayOnPoint(baseRectH, ...
            centerHsti+fixGapH+xCB,...
            centerV+4); % right cross arrow 
    HCr(:, 3) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV-yCA-fixGapV-yCB+4); % top right square 
    HCr(:, 4) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti-fixGapH-xCA-xCB,...
            centerV+fixGapV+yCA+yCB+4); % bottom left square 
    HCr(:, 5) = CenterRectArrayOnPoint(baseSquare, ...
            centerHsti+fixGapH+xCA+xCB,...
            centerV+fixGapV+yCA+yCB+4); % bottom right square
    pixelsPerPress = 1;

end
