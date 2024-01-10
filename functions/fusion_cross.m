function [HCl, HCr, pixelsPerPress] = fusion_cross(windowRect, global_param, fixCross, stereo)



    h=round(windowRect(3));
    v=round(windowRect(4));

%h=round(windowRect(3));% the horizontal resolution
%v=round(windowRect(4));% the vertical resolution (try to change the size for stereomode here?)

DisplaySize=global_param.screen_size; %get the size screen described in the global parameter files 

% get the center of the display 
centerV=v/2;
centerHsti=h/2;

hsize=h/DisplaySize(1); %pix per mm in horizontal
vsize=v/DisplaySize(2); %pix per mm in vertical

PixelPerDeg=1/atand(1/hsize/global_param.distance); %pixels per dva
hpixel=1/PixelPerDeg*60;
vpixel=1/PixelPerDeg*60;


if fixCross == true 
    if stereo == 100
        fixGapV = round(10/vpixel/2);
        fixGapH = round(10/vpixel);
    elseif stereo == 101
        fixGapV = round(10/vpixel);
        fixGapH = round(10/vpixel/2);
    else
        fixGapH = round(10/vpixel/2);
        fixGapV = round(10/vpixel/2);
    end
else
    fixGapV=round(10/vpixel); % size of the gap in pixels 
    fixGapH=round(10/vpixel); 
end


a=round(25/vpixel);% thickness in pixels was 6
b=round(100/hpixel);% length in pixels was 40

%make the base size of the rectangles/squares
%dimRectV = round((centerV-a) - (centerV-b)); %vertical size of the cross lines
%dimRectH = round((centerHsti+a)-(centerHsti-a)); %horizontal size of the cross lines 
%dimSquare = round((centerV-a-fixGap)-(centerV-b)); %length of the square

% I just have to add one variable here to make vertical sizes smaller 
%maybe an 'if fixCross == true --> = 0.5 else --> = 1'
%careful, I need to do that with a and b :(
%{
if fixCross == true 
    baseRectH = round([0 0 dimRectV dimRectH*0.5]); 
    baseRectV = round([0 0 dimRectH dimRectV*0.5]); 
    baseSquare = round([0 0 dimSquare dimSquare*0.5]); 
else 
baseRectH = [0 0 dimRectV dimRectH]; %1 et 4
baseRectV = [0 0 dimRectH dimRectV];%2 et 3 
baseSquare = [0 0 dimSquare dimSquare];
end
%}

if fixCross == true 
    baseRectH = round([0 0 b a*0.5]); 
    baseRectV = round([0 0 a b*0.5]); 
    baseSquare = round([0 0 b-a (b-a)*0.5]); 
else 
baseRectH = [0 0 b a]; %1 et 4
baseRectV = [0 0 a b];%2 et 3 
baseSquare = [0 0 b-a b-a];
end


% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%get the center of the squares 
[xSquare, ySquare] = RectCenter(baseSquare);

%get the center of the vertical cross arrow 
[xCA, yCA] = RectCenter(baseRectV);

%get the center of the vertical cross arrow 
[xCB, yCB] = RectCenter(baseRectH);


%now let's put them at specific locations 
%each rectangle is 10 pix away from the center (a)
%each square is 10 + 16 pix away from the center (a + b)

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


%% pixels to move the half crosses 
pixelsPerPress = 1;%numbers of pixels to move from with each button press 

