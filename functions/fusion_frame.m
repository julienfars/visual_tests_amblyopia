function [FFLw, FFRw, FFLb, FFRb] = fusion_frame(windowRect, fixCross, stereoMode)

%xL0 = x0 ; yL0 = y0; % Left half position
%xR0 = x0 ; yR0 = y0; % Right half position

%[whiteLinesL blackLinesL] = getFusionFrameLines(xL0, yL0, fusionFrameLength, lineWidth);
%[whiteLinesR blackLinesR] = getFusionFrameLines(xR0, yR0, fusionFrameLength, lineWidth);


    x0 = windowRect(3)/2; 
    y0 = windowRect(4)/2;

%careful, use the 4,4 x 4,4 dva instead of pixels (will look too lengthy and not large enough otherwise)
if fixCross == true 
    if stereoMode == 101
        length = 552;
        height = 276;
    else
        height = 276;
        length = 552;
    end
else
        length = 552;
        height = 552;
end

width = 20; 

x1 = x0-length/2;
x2 = x0-length/4;
x3 = x0;
x4 = x0+length/4;
x5 = x0+length/2;

y1 = (y0-height/2);
y2 = y0-height/4;
y3 = y0;
y4 = y0+height/4;
y5 = y0+height/2;

Rectlarge = round((x2) - (x1)); %large size of the rectangles

if fixCross == true %not sure if useful
    if stereoMode == 101
        baseFusionRectH = round([0 0 Rectlarge width*0.5]); 
        baseFusionRectV = round([0 0 width Rectlarge*0.5]); 
    elseif stereoMode == 100 
        baseFusionRectH = [0 0 Rectlarge*0.5 width];
        baseFusionRectV = [0 0 width*0.5 Rectlarge];
    end
else
    baseFusionRectH = [0 0 Rectlarge width];
    baseFusionRectV = [0 0 width Rectlarge];
end


%get the center of the horizontal rectangles 
[xfCA, yfCA] = RectCenter(baseFusionRectH);

%get the center of the vertical rectangles
[xfCB, yfCB] = RectCenter(baseFusionRectV);


%% first fusion frame
% horizontal black rectangles 
FFLb(:, 1) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x1+xfCA,...
        y1+yfCA); % first top rectangle
FFLb(:, 2) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x3+xfCA,...
        y1+yfCA); % third top rectangle
FFLb(:, 3) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x2+xfCA,...
        y5+yfCA);% second bottom rectangle
FFLb(:, 4) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x4+xfCA,...
        y5+yfCA); % fourth bottom rectangle
% vertical black rectangles
FFLb(:, 5) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x1+xfCB,...
        y2+yfCB); % second left rectangle 
FFLb(:, 6) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x1+xfCB,...
        y4+yfCB); % fourth left rectangle
FFLb(:, 7) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x5-xfCB,...
        y1+yfCB); % first right rectangle
FFLb(:, 8) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x5-xfCB,...
        y3 +yfCB); % third right rectangle


% Horizontal white rectangles 
FFLw(:, 9) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x2+xfCA,...
        y1+yfCA); % top cross arrow
FFLw(:, 10) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x4+xfCA,...
        y1+yfCA); % left cross arrow 
FFLw(:, 11) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x1+xfCA,...
        y5+yfCA);% top left square
FFLw(:, 12) = CenterRectArrayOnPoint(baseFusionRectH, ...
        x3+xfCA,...
        y5+yfCA); % top right square 
% Vertical white rectangles
FFLw(:, 13) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x1+xfCB,...
        y1+yfCB); % bottom left square 
FFLw(:, 14) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x1+xfCB,...
        y3+yfCB); % bottom right square
FFLw(:, 15) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x5-xfCB,...
        y2+yfCB); % bottom left square 
FFLw(:, 16) = CenterRectArrayOnPoint(baseFusionRectV, ...
        x5-xfCB,...
        y4+yfCB); % bottom right square

%% second fusion frame
FFRw = FFLw;
FFRb = FFLb;

