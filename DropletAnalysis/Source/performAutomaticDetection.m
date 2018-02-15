%inputImage = imgaussfilt(settings.currentImage, 4); 
% hminima = (imhmin(inputImage, settings.hminimaHeight) - inputImage) > 0;
% currentRegionProps = regionprops(hminima, 'Centroid');
global settings;

%% perform watershed based segmentation
if (settings.useWatershed == true)
    medFilteredImage = medfilt2(255-settings.currentImage, [settings.medFiltWidth,settings.medFiltWidth]);
    hminimaImage = imhmin(medFilteredImage, settings.hminimaHeight);

    settings.watershedImage = watershed(hminimaImage);

    for i=1:size(settings.currentSeeds,1)
       currentIndex = settings.watershedImage(settings.currentSeeds(i,2), settings.currentSeeds(i,1));
       settings.watershedImage(settings.watershedImage == currentIndex) = 0;
    end
    labelImage = bwlabeln(settings.watershedImage > 0);
    settings.watershedImage = labelImage;
    
%% perform hough transform based segmentation
else
    [centersBright, radiiBright] = imfindcircles(imresize(settings.currentImage, settings.houghScaleFactor), round(settings.houghScaleFactor*[settings.houghMinRadius, settings.houghMaxRadius]),'ObjectPolarity', 'bright', 'Method', 'PhaseCode', 'Sensitivity', settings.houghSensitivity, 'EdgeThreshold', settings.houghEdgeThreshold);
    radiiBright = radiiBright / settings.houghScaleFactor;
    
    segmentImage = zeros(size(settings.currentImage));
    for i=1:length(centersBright)
        currentCenter = round(centersBright(i,:) / settings.houghScaleFactor);
        segmentImage(currentCenter(2), currentCenter(1)) = 1;
    end
    
    segmentImage = imdilate(segmentImage, strel('disk', 15));
    distanceMapImage = bwdist(segmentImage);
    
    watershedImage = watershed(distanceMapImage);
    watershedRegions = regionprops(watershedImage, 'PixelIdxList');
    
    labelImage = zeros(size(settings.currentImage));
    for i=1:length(centersBright)
        currentCenter = round(centersBright(i,:) / settings.houghScaleFactor);
        currentIndex = watershedImage(currentCenter(2), currentCenter(1));
        validIndices = find(distanceMapImage(watershedRegions(currentIndex).PixelIdxList) < (0.9*radiiBright(i)));
        labelImage(watershedRegions(currentIndex).PixelIdxList(validIndices)) = i;
    end
    
    %% set the label image
    settings.watershedImage = labelImage;
end

if (settings.fullRegionProps == true)
    %% extract the current region props
    settings.currentRegionProps = regionprops(labelImage, settings.currentFluorescenceImage, 'Centroid', 'Area', 'BoundingBox', 'ConvexArea', 'Eccentricity', ...
                                             'EquivDiameter', 'Extent', 'FilledArea', 'MajorAxisLength', 'MinorAxisLength', ...
                                             'Orientation', 'Perimeter', 'Solidity', 'MaxIntensity', 'MinIntensity', 'MeanIntensity', 'PixelIdxList');
else
    settings.currentRegionProps = regionprops(labelImage, settings.currentFluorescenceImage, 'Centroid', 'Area', 'Eccentricity', ...
                                                 'EquivDiameter', 'MeanIntensity', 'PixelIdxList');
end

for i=1:length(settings.currentRegionProps)
    if (~isempty(settings.currentRegionProps(i)))
        currentRegion = settings.currentFluorescenceImage(settings.currentRegionProps(i).PixelIdxList);
        validIndices = find(currentRegion > settings.intensityFeatureThreshold);
        if (~isempty(validIndices))
            settings.currentRegionProps(i).MeanIntensityAboveThreshold = mean(currentRegion(validIndices));
            settings.currentRegionProps(i).MinIntensityAboveThreshold = min(currentRegion(validIndices));
            settings.currentRegionProps(i).MaxIntensityAboveThreshold = max(currentRegion(validIndices));
        else
            settings.currentRegionProps(i).MeanIntensityAboveThreshold = -1;
            settings.currentRegionProps(i).MinIntensityAboveThreshold = -1;
            settings.currentRegionProps(i).MaxIntensityAboveThreshold = -1;
        end
    end
end

settings.dirtyFlag = true;
updateDetectionFilters;
saveProject;