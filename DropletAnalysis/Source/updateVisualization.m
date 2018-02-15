
global settings;

%settings.watershedImage = watershed(imimposemin(imgaussfilt(settings.currentImage, 1), settings.currentSeedImage));
%settings.watershedImage = watershed(imgaussfilt(settings.currentImage, 1));

if (settings.showFluorescenceChannel == false && settings.showWatershedResult == false)
    currentImage = settings.currentImage;
elseif (settings.showWatershedResult == true)
    currentImage = settings.watershedImage;
else
    currentImage = settings.currentFluorescenceImage;
end

% redChannel = currentImage;
% redChannel(settings.watershedImage == 0) = 255;
% blueChannel = currentImage;
% blueChannel(settings.watershedImage == 0) = 0;
% settings.currentResultImage = cat(3, redChannel, blueChannel, blueChannel);
settings.currentResultImage = currentImage;

figure(settings.mainFigure); clf; hold on;

% subplot(2,1,1);
% cla; hold on;
% settings.imageHandle = imagesc(settings.currentImage);
% if (~isempty(settings.currentSeeds))
%     plot(settings.currentSeeds(:,1), settings.currentSeeds(:,2), '.m');
%     plot(settings.currentSeeds(:,1), settings.currentSeeds(:,2), 'oc');
% end
% axis tight;
% colormap gray;
% set(gca, 'Units', 'normalized', 'Position', [0, 0.5, 1.0, 0.5]);

%subplot(2,1,2);
cla; hold on;
imagesc(settings.currentResultImage);
if (~isempty(settings.currentSeeds))
    validSelectionIndices = find(settings.currentSeeds(:,end) == 1);
    validDeSelectionIndices = find(settings.currentSeeds(:,end) == 0);
    plot(settings.currentSeeds(validSelectionIndices,1), settings.currentSeeds(validSelectionIndices,2), '*c');
    plot(settings.currentSeeds(validDeSelectionIndices,1), settings.currentSeeds(validDeSelectionIndices,2), '*m');
%     plot(settings.currentSeeds(:,1), settings.currentSeeds(:,2), 'oc');
end

if (~isempty(settings.currentDetections))
    viscircles(settings.currentDetections(:,1:2), settings.currentDetections(:,3), 'Color','b');
end

set(gca, 'Units', 'normalized', 'Position', [0, 0, 1.0, 1.0]);
set(gca, 'YDir', 'reverse');
axis tight;
colormap gray;

if (settings.showParameters == true)
    if (settings.useWatershed == true)
        if (settings.featureMode == 1); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['H-Maximum Height: ' num2str(settings.hminimaHeight)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.98]);
        if (settings.featureMode == 2); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Minimum Area: ' num2str(settings.minArea)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.94]);
        if (settings.featureMode == 3); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Maximum Eccentricity: ' num2str(settings.maxEccentricity)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.90]);
        if (settings.featureMode == 4); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Minimum Intensity: ' num2str(settings.minIntensity)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.86]);

        text('String', ['Circle Detection: Watershed'], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.82]);
    else
        if (settings.featureMode == 1); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Image Downsampling: ' num2str(settings.houghScaleFactor)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.98]);
        if (settings.featureMode == 2); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Hough Sensitivity: ' num2str(settings.houghSensitivity)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.94]);
        if (settings.featureMode == 3); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Hough Edge Threshold: ' num2str(settings.houghEdgeThreshold)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.90]);
        if (settings.featureMode == 4); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Minimum Intensity: ' num2str(settings.minIntensity)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.86]);
        if (settings.featureMode == 5); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Minimum Radius: ' num2str(settings.houghMinRadius)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.82]);
        if (settings.featureMode == 6); currentColor = [1,0,0]; else; currentColor = [0,0,0]; end;
        text('String', ['Maximum Radius: ' num2str(settings.houghMaxRadius)], 'FontSize', settings.fontSize, 'BackgroundColor', currentColor, 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.78]);


        text('String', ['Circle Detection: Hough'], 'FontSize', settings.fontSize, 'BackgroundColor', [0,0,0], 'Color', 'white', 'Units', 'normalized', 'Position', [0.01 0.74]);
    end
end
set(settings.mainFigure, 'Name', settings.inputImages{settings.currentImageIndex},'NumberTitle','off');