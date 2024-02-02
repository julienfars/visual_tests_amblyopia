function [FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode)

    x0 = windowRect(3) / 2;
    y0 = windowRect(4) / 2;

    if fixCross
        if stereoMode == 101
            length = 276;
            height = 552;
        elseif stereoMode == 100
            height = 276;
            length = 552;
        else % debug purposes
            length = 552;
            height = 552;
        end
    else
        length = 552;
        height = 552;
    end

    width = 20;

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

    if fixCross
        if stereoMode == 101
            baseFusionRectH = round([0 0 Rectlarge width * 0.5]);
            baseFusionRectV = round([0 0 width Rectlarge * 0.5]);
        elseif stereoMode == 100
            baseFusionRectH = [0 0 Rectlarge * 0.5 width];
            baseFusionRectV = [0 0 width * 0.5 Rectlarge];
        else % debug purposes
            baseFusionRectH = [0 0 Rectlarge width];
            baseFusionRectV = [0 0 width Rectlarge];
        end
    else
        baseFusionRectH = [0 0 Rectlarge width];
        baseFusionRectV = [0 0 width Rectlarge];
    end

    [xfCA, yfCA] = RectCenter(baseFusionRectH);
    [xfCB, yfCB] = RectCenter(baseFusionRectV);

    [FFLw, FFRw, FFLb, FFRb] = createFusionFrames(x0, y0, x1, x2, x3, x4, x5, y1, y2, y3, y4, y5, width, xfCA, yfCA, xfCB, yfCB, baseFusionRectH, baseFusionRectV);

end


