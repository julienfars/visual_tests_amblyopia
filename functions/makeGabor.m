function grayscaleImageMatrix=makeGabor(PixPerDeg, xor, xextd, yor, yextd, contrast, cycPerDeg, sigma, phase, tiltInDegrees, locCx, locCy)
%% 创建于2009年3月3号.
% 返回的grayscaleImageMatrix的值的范围是-1到1。
% 对比度contrast,空间频率spatial frequecy, 还有sigma已经调试正确。
% [若显示器不是21 inch 记得改actualWidth;
% 使用前务必设定好观察距离params.distance及显示器的实际宽度(单位为cm,如21 inch显示器的宽为40cm)。]

%% 2009.5月6号做了如下修改
% 取消 param参数， 直接传入PixPerDeg。
% PixPerDeg可以是根据校正后的值，也可以是更精确的在某特定离心率下算出的值。

% *** To rotate the grating, set tiltInDegrees to a new value.
%tiltInDegrees = 7; % The tilt of the grating in degrees.
tiltInRadians = (-tiltInDegrees) * pi / 180; % The tilt of the grating in radians.
% actualWidth=20; %这里算时默认显示器为21 inch.所以半宽是20cm.
% PixPerDeg= params.rectWidth/(2*(atan(actualWidth/params.distance))*180/pi);
% pixPerCyc=PixPerDeg/cycPerDeg;
% pixelsPerPeriod=pixPerCyc;
spatialFrequency=cycPerDeg/PixPerDeg;% pixel per cycle
sigma=sigma*PixPerDeg;  %原来sigma的单位是度,这里把它变成pixel.
% *** To lengthen the period of the grating, increase pixelsPerPeriod.
% pixelsPerPeriod = 1/spatialFrequency; % How many pixels will each period/cycle occupy?
% spatialFrequency = 1 / pixelsPerPeriod; % How many periods/cycles are there in a pixel?
radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)

% *** To enlarge the gaussian mask, increase periodsCoveredByOneStandardDeviation.
% The parameter "periodsCoveredByOneStandardDeviation" is approximately
% equal to
% the number of periods/cycles covered by one standard deviation of the radius of
% the gaussian mask.

%periodsCoveredByOneStandardDeviation = 1.5;

% The parameter "gaussianSpaceConstant" is approximately equal to the
% number of pixels covered by one standard deviation of the radius of
% the gaussian mask.

%gaussianSpaceConstant = periodsCoveredByOneStandardDeviation  * pixelsPerPeriod;
%

% *** If the grating is clipped on the sides, increase widthOfGrid.
% widthOfGrid = xextd-xor+1;
% heightOfGrid = yextd-yor+1;
% halfWidthOfGrid = ceil(widthOfGrid / 2);
% halfHeightOfGrid = ceil(heightOfGrid / 2);

x0=locCx-xor;
y0=locCy-yor;
x1=xextd-locCx;
y1=yextd-locCy;
widthArray = -x0:x1;
heightArray=-y0:y1;  % widthArray is used in creating the meshgrid.

% ---------- Image Setup ----------
% Stores the image in a two dimensional matrix.

% Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
% the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
% and y = y(x0, y0) corresponds to the y-coordinate of element "i"
[x y] = meshgrid(widthArray, heightArray);

% Replaced original method of changing the orientation of the grating
% (gradient = y - tan() .* x) with sine and cosine (adapted from DriftDemo).
% Use of tangent was breakable because it is undefined for theta near pi/2 and the period
% of the grating changed with change in theta.

a=cos(tiltInRadians)*radiansPerPixel;
b=sin(tiltInRadians)*radiansPerPixel;

% Converts meshgrid into a sinusoidal grating, where elements
% along a line with angle theta have the same value and where the
% period of the sinusoid is equal to "pixelsPerPeriod" pixels.
% Note that each entry of gratingMatrix varies between minus one and
% one; -1 <= gratingMatrix(x0, y0)  <= 1
gratingMatrix = sin(a*x+b*y+phase/180*pi);


% Creates a circular Gaussian mask centered at the origin, where the number
% of pixels covered by one standard deviation of the radius is
% approximately equal to "gaussianSpaceConstant."
% For more information on circular and elliptical Gaussian distributions, please see
% http://mathworld.wolfram.com/GaussianFunction.html
% Note that since each entry of circularGaussianMaskMatrix is "e"
% raised to a negative exponent, each entry of
% circularGaussianMaskMatrix is one over "e" raised to a positive
% exponent, which is always between zero and one;
% 0 < circularGaussianMaskMatrix(x0, y0) <= 1
circularGaussianMaskMatrix = exp(-((x .^ 2) + (y .^ 2)) ./ (sigma ^ 2));

% Since each entry of gratingMatrix varies between minus one and one and each entry of
% circularGaussianMaskMatrix vary between zero and one, each entry of
% imageMatrix varies between minus one and one.
% -1 <= imageMatrix(x0, y0) <= 1
trim = .005;                             % trim off gaussian values smaller than this
circularGaussianMaskMatrix(circularGaussianMaskMatrix < trim) = 0;                 % trim around edges (for 8-bit colour displays)
imageMatrix = gratingMatrix .* circularGaussianMaskMatrix; % imageMatrix 的范围是-1到1；

% Since each entry of imageMatrix is a fraction between minus one and
% one, multiplying imageMatrix by absoluteDifferenceBetweenWhiteAndGray
% and adding the gray CLUT color code baseline
% converts each entry of imageMatrix into a shade of gray:
% if an entry of "m" is minus one, then the corresponding pixel is black;
% if an entry of "m" is zero, then the corresponding pixel is gray;
% if an entry of "m" is one, then the corresponding pixel is white.


%     gray=params.gray;
%     absoluteDifferenceBetweenWhiteAndGray=params.inc*contrast;
%
% 	grayscaleImageMatrix = gray + absoluteDifferenceBetweenWhiteAndGray * imageMatrix;
grayscaleImageMatrix=imageMatrix*contrast/100;   % grayscaleImageMatrix的范围是-1到1。



