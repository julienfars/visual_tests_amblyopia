function [UP_side, DOWN_side, isConvex] = setupArrows(xCenter, yCenter, size)
    % Set up arrow positions.

    % Get the size of the noise
    sidesize = side; % was 240, was 390
    dstGab_centerN = [0 0 1 0.5] .* sidesize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);

    xhead = xCenter; % 1
    xheadleft = xCenter - (sidesize/4); % 2
    xheadright = xCenter + (sidesize/4); % 3
    xbaseleft = xCenter - (sidesize/8); % 4
    xbaseright = xCenter + (sidesize/8); % 5

    % DOWN
    yhead = yCenter + (sidesize/6);
    yheadside = yCenter;
    ybase = yCenter - (sidesize/6);

    % UP
    xPosVectorUP = [xhead xheadright xbaseright xbaseright xbaseleft xbaseleft xheadleft xhead]; % is it the down one? Yes
    yPosVectorUP = [yhead yheadside yheadside ybase ybase yheadside yheadside yhead];

    % DOWN
    xPosVectorDOWN = [xhead xheadright xbaseright xbaseright xbaseleft xbaseleft xheadleft xhead]; % this is the up one? Yes 
    yPosVectorDOWN = [ybase yheadside yheadside yhead yhead yheadside yheadside ybase];

    UP_side = [xPosVectorUP; yPosVectorUP];
    DOWN_side = [xPosVectorDOWN; yPosVectorDOWN];

    % Cue to tell PTB that the polygon is convex (concave polygons require much more processing)
    isConvex = 1;
end