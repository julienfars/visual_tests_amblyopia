function [FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, global_param, fixCross, stereo)

    x0 = windowRect(3) / 2;
    y0 = windowRect(4) / 2;

    h = round(windowRect(3));
    v = round(windowRect(4));
    DisplaySize = global_param.screen_size;

    hsize = h / DisplaySize(1); %pix per mm in horizontal
    vsize = v / DisplaySize(2); %pix per mm in vertical

    PixelPerDeg = 1 / atand(1 / hsize / global_param.distance); %pixels per dva
    size_frame = ceil(PixelPerDeg*4.45);
    
%careful, use the 4,4 x 4,4 dva instead of pixels (will look too lengthy and not large enough otherwise)
        if stereo == 100
            length = size_frame;
            height = size_frame/2;
        elseif stereo == 101
            length = size_frame/2;
            height = size_frame;
        else
            length = size_frame;
            height = size_frame;
        end


    width = round(size_frame/27);

    x1 = x0 - length / 2;
    x2 = x0 - length / 4;
    x3 = x0;
    x4 = x0 + length / 4;
    x5 = x0 + length / 2;

    y1 = y0 - height / 2;
    y2 = y0 - height / 4;
    y3 = y0;
    y4 = y0 + height / 4;
    y5 = y0 + height / 2;

    Rectlarge = round((x2) - (x1)); %large size of the rectangles

        if stereo == 100
            baseFusionRectH = round([0 0 Rectlarge width * 0.5]);
            baseFusionRectV = round([0 0 width Rectlarge * 0.5]);
        elseif stereo == 101
            baseFusionRectH = [0 0 Rectlarge * 0.5 width];
            baseFusionRectV = [0 0 width * 0.5 Rectlarge];
        else % debug purposes
            baseFusionRectH = [0 0 Rectlarge width];
            baseFusionRectV = [0 0 width Rectlarge];
        end
    

    [xfCA, yfCA] = RectCenter(baseFusionRectH);
    [xfCB, yfCB] = RectCenter(baseFusionRectV);

    [FFLw, FFRw, FFLb, FFRb] = createFusionFrames(x0, y0, x1, x2, x3, x4, x5, y1, y2, y3, y4, y5, width, xfCA, yfCA, xfCB, yfCB, baseFusionRectH, baseFusionRectV);

end

