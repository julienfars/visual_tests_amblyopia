function resizeAndConvertTarget(inputImagePath, outputImagePathPrefix, outputSizes)
    % RESIZEANDCONVERTTARGET - Read, convert, and resize an image to different sizes
    
    % Inputs:
    % - inputImagePath: path to the input image file
    % - outputImagePathPrefix: prefix for the output image files
    % - outputSizes: an array of sizes for the output images
    
    % Read the target image
    RGB = imread(inputImagePath);

    % Convert the image to black and white
    RGB = 255 - RGB;
    grayImage = rgb2gray(RGB); % Convert to grayscale
    meanVal = mean(grayImage, 'all');
    binaryImage = grayImage >= meanVal;

    % Display the binary image
    imshow(binaryImage);

    % Save the black and white image
    imwrite(binaryImage, [outputImagePathPrefix, '_BW.png']);

    % Resize and save images based on specified sizes
    for i = 1:length(outputSizes)
        currentSize = outputSizes(i, :);
        resizedImage = imresize(binaryImage, currentSize);

        % Save the resized image with a unique filename
        imwrite(resizedImage, [outputImagePathPrefix, '_', num2str(i), '.png']);
    end
end
