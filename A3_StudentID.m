function A3_StudentID(inputImage)


    % ---------------------------------------------------------------------
    %   (a) Read the input image
    % ---------------------------------------------------------------------
    img = imread(inputImage);

    % ---------------------------------------------------------------------
    %   (b) SEGMENTATION (Sub-function call)
    %       This returns a binary mask that isolates the egg regions.
    % ---------------------------------------------------------------------
    [segmentedMask] = mySegmentation(img);

    % ---------------------------------------------------------------------
    %   (c) FIND EGGS AND GET COUNT (Sub-function call)
    %       Use morphological operations to refine & count half-eggs.
    % ---------------------------------------------------------------------
    [halfEggCount, finalMask] = myFindEggs(segmentedMask);

    % Each "egg" is made of two "half-eggs"
    eggCount = halfEggCount / 2;

    % ---------------------------------------------------------------------
    %   (d) Display Results
    %       Figure 1 -> Show Original Image + Bounding Boxes
    %       Figure 2 -> Show Final Segmented Image + # of Eggs
    % ---------------------------------------------------------------------

    % -- Figure 1
    figure(1);
    sgtitle('Figure 1: Steps of the Algorithm (Original + Bounding Boxes)');
    imshow(img);
    hold on;
    title(sprintf('Number of Eggs: %.1f', eggCount), 'FontSize', 12);

    % For demonstration, draw bounding boxes by re-labeling finalMask
    labeledMask = bwlabel(finalMask);
    stats = regionprops(labeledMask, 'BoundingBox');
    for idx = 1 : length(stats)
        bb = stats(idx).BoundingBox;  % [x, y, width, height]
        rectangle('Position', bb, 'EdgeColor', 'green', 'LineWidth', 2);
    end
    hold off;

    % -- Figure 2
    % Create a color image showing only segmented regions
    outputImg = zeros(size(img), 'uint8');
    for c = 1:3
        tempChannel = img(:,:,c);
        tempChannel(~finalMask) = 0; 
        outputImg(:,:,c) = tempChannel;
    end

    figure(2);
    sgtitle('Figure 2: Final Segmented Image + Egg Count');
    imshow(outputImg);
    title(sprintf('Number of Eggs: %.1f', eggCount), 'FontSize', 12);

end % End of main function


% =========================================================================
% Sub-function: SEGMENTATION
% =========================================================================
function [segmentedMask] = mySegmentation(originalImg)
%
%   mySegmentation takes an RGB image and returns a binary mask
%   identifying the egg (yolk/white) regions. You are free to use
%   any segmentation algorithm from lecture notes (thresholding, 
%   color segmentation, edge-based, etc.).
%

    % Example thresholding for a typical "yellowish" or "light" egg region
    % (You may need to adjust these values to match your egg images.)
    % ---------------------------------------------------------------------
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
function [halfEggCount, cleanedMask] = myFindEggs(binaryMask)
%
%   myFindEggs takes a segmented binary mask (result of segmentation) 
%   and applies morphological operations + region properties to 
%   find the number of half-eggs in the image.
%
%   Output:
%       halfEggCount -> the number of half-eggs
%       cleanedMask  -> the final refined binary mask
%
%   Important: The problem statement says you MUST use morphology 
%              to find the number of eggs.
%

    % ---------------------------------------------------------------------
    % (1) Morphological operations (closing, then opening) to clean noise
    % ---------------------------------------------------------------------
    se = strel('disk', 20);  % Example structuring element
    closedMask = imclose(binaryMask, se);
    openedMask = imopen(closedMask, se);

    % ---------------------------------------------------------------------
    % (2) Label connected components and filter them by area 
    %     (so that small noise is discarded)
    % ---------------------------------------------------------------------
    minArea = 2000;
    maxArea = 50000;

    labeled = bwlabel(openedMask);
    stats   = regionprops(labeled, 'Area');

    % find the indices of connected components that satisfy area constraint
    goodIdx = find([stats.Area] >= minArea & [stats.Area] <= maxArea);

    % keep only those valid regions
    cleanedMask = ismember(labeled, goodIdx);

    % ---------------------------------------------------------------------
    % (3) Count the number of half-eggs
    % ---------------------------------------------------------------------
    halfEggCount = numel(goodIdx);

end
