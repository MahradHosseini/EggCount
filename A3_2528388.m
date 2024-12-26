% =========================================================================
% Middle East Technical University Northern Cyprus Campus
% CNG 466: Image Processing
% Assignment 3: Egg Counting
%
% Mahrad Hosseini - 2528388
% Winter 2024
% =========================================================================

% inputImage should be a string containing the name of the image file
function A3_2528388(inputImage)

    img = imread(inputImage);

    [segmentedMask] = Segmentation(img);

    [halfEggCount, finalMask] = FindEggs(segmentedMask);

    eggCount = halfEggCount / 2;

    % For displaying the process:
    % (1) Original image
    originalImg = img;

    % (2) Segmented (thresholded) mask
    thresholdedImg = segmentedMask;

    % (3) After morphological cleaning/final mask
    cleanedImg = finalMask;

    % (4) Color image showing only segmented regions
    outputImg = zeros(size(img), 'uint8');
    for c = 1:3
        tempChannel = img(:,:,c);
        tempChannel(~finalMask) = 0;
        outputImg(:,:,c) = tempChannel;
    end

    % Figure 1: Show the steps
    figure(1);
    sgtitle('Figure 1: Different Steps of the Image Processing');

    subplot(2,2,1);
    imshow(originalImg);
    title('Original Image');

    subplot(2,2,2);
    imshow(thresholdedImg);
    title('Thresholded Mask');

    subplot(2,2,3);
    imshow(cleanedImg);
    title('Cleaned/Final Mask');

    subplot(2,2,4);
    imshow(outputImg);
    title(sprintf('Final Segmentation (Egg Count: %.1f)', eggCount));

    % Figure 2: Show bounding boxes on the original image
    figure(2);
    imshow(img);
    hold on;
    title(sprintf('Number of Eggs: %.1f', eggCount), 'FontSize', 8);

    % For demonstration, drawing bounding boxes by re-labeling finalMask
    labeledMask = bwlabel(finalMask);
    stats = regionprops(labeledMask, 'BoundingBox');
    for idx = 1 : length(stats)
        bb = stats(idx).BoundingBox;
        rectangle('Position', bb, 'EdgeColor', 'green', 'LineWidth', 2);
    end
    hold off;

end


% =========================================================================
% Sub-function: SEGMENTATION
% =========================================================================
function [segmentedMask] = Segmentation(originalImg)

    % Thresholding for a typical yolk-yellow
    rMin = 210;  rMax = 250; 
    gMin = 150;  gMax = 180;  
    bMin =   0;  bMax =  50;  

    R = originalImg(:,:,1);
    G = originalImg(:,:,2);
    B = originalImg(:,:,3);

    % Binary mask: 1 where pixels are within given thresholds
    segmentedMask = (R >= rMin & R <= rMax) & ...
                    (G >= gMin & G <= gMax) & ...
                    (B >= bMin & B <= bMax);

end


% =========================================================================
% Sub-function: FINDING EGGS
% =========================================================================
function [halfEggCount, cleanedMask] = FindEggs(binaryMask)

    % Morphological closing, then opening for noise reduction
    se = strel('disk', 20);
    closedMask = imclose(binaryMask, se);
    openedMask = imopen(closedMask, se);

    % Defining min and max boundaries for area
    minArea = 2000;
    maxArea = 50000;

    % Labeling the connected components and filtering them by their size
    labeled = bwlabel(openedMask);
    stats   = regionprops(labeled, 'Area');

    % Finding the indices of connected components that are within area
    % boundaries
    goodIdx = find([stats.Area] >= minArea & [stats.Area] <= maxArea);

    % Keeping only those valid regions
    cleanedMask = ismember(labeled, goodIdx);

    % Counting the number of half-eggs
    halfEggCount = numel(goodIdx);

end
