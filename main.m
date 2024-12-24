% =========================================================================
% CNG 466 Image Proccessing
% Assignment 3: EGG DETECTION
%
% Using threshold-based segmentation & morphological operations 
% to count half-eggs in plate images.
%
%
% Steps:
%   1) Read each image (Plate1.png to Plate10.png)
%   2) Segment using a color-thresholding approach
%   3) Clean up the binary mask with morphological operations
%   4) Label connected components and filter by size
%   5) Count the number of valid connected components (half-eggs)
%   6) Show bounding boxes on the original image (Figure 1)
%   7) Show the segmented/filtered image (Figure 2)
%
%
% Mahrad Hosseini
% Winter 2024
% =========================================================================

% Parameter Setup
rMin = 210;  rMax = 250; 
gMin = 150;  gMax = 180;  
bMin =   0;  bMax =  50;  

% Morphological structuring element
se = strel('disk', 20);

% Area filtering to discard noise or partial objects
minArea = 2000;   
maxArea = 50000;  

% Prepare two figures:
figure(1); 
sgtitle('Figure 1: Original Images with Detected Half-Eggs');

figure(2);
sgtitle('Figure 2: Segmented Images Highlighting Half-Eggs');


for i = 1:10

    filename = sprintf('Plate%d.png', i);  % e.g., 'Plate1.png', 'Plate2.png', ...
    img = imread(filename);
    
    % Segmentation
    % Extract RGB channels
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);

    % Create a binary mask based on these ranges
    yolkMask = (R >= rMin & R <= rMax) & ...
               (G >= gMin & G <= gMax) & ...
               (B >= bMin & B <= bMax);

    % Morphological cleanup
    % Close small holes, then remove small noise
    cleanedMask = imclose(yolkMask, se);
    cleanedMask = imopen(cleanedMask, se);

    % Label & filter connected components by area
    labeledMask = bwlabel(cleanedMask);
    stats = regionprops(labeledMask, 'Area', 'BoundingBox');

    % Find indexes of labeled regions that fit within area constraints
    goodIdx = find([stats.Area] >= minArea & [stats.Area] <= maxArea);

    % Keep only those good labeled regions
    filteredMask = ismember(labeledMask, goodIdx);

    % Count the num of half-eggs
    halfEggCount = numel(goodIdx);

    % Count the num of whole eggs
    eggCount = halfEggCount/2;

    % Figure 1: Show original image with bounding boxes
    figure(1);
    subplot(2, 5, i);
    imshow(img);
    hold on;
    title(sprintf('Plate %d: %.1f whole eggs', i, eggCount));
    
    % Draw bounding boxes for each valid region
    for idx = goodIdx
        bb = stats(idx).BoundingBox;  % [x, y, width, height]
        rectangle('Position', bb, 'EdgeColor', 'green', 'LineWidth', 2);
    end
    hold off;

    % Figure 2: Show segmented image
    % Create a color image that is black everywhere except 
    % in the detected regions
    outputImg = zeros(size(img), 'uint8');
    for c = 1:3
        tempChannel = img(:,:,c);
        tempChannel(~filteredMask) = 0; 
        outputImg(:,:,c) = tempChannel;
    end

    figure(2);
    subplot(2, 5, i);
    imshow(outputImg);
    title(sprintf('Plate %d: %.1f whole eggs', i, eggCount));

end
