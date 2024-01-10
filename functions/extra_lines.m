% to change the target, we must first read it 

RGB = imread('fixTarget.jpg');


% to convert it in black and white 

RGB = 255-RGB;

grayImage = im2gray(RGB);
meanVal = mean(grayImage,"all");
binaryImage = grayImage >= meanVal;
imshow(binaryImage);

imwrite(binaryImage,"fixTargetBW.png")


% to resize it

RGB2 = imresize(binaryImage,[33 67]); % remember matlab count starts at 0
imwrite(RGB2,"fixTargetBW_100.png")


RGB2 = imresize(binaryImage,[67 33]);
imwrite(RGB2,"fixTargetBW_101.png")