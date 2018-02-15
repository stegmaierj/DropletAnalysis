global settings;
outputFolder = settings.outputFolder;

if (exist(outputFolder, 'dir'))
    waitBarHandle = waitbar(0,'Exporting result images and tables ...');
    frames = java.awt.Frame.getFrames();
    frames(end).setAlwaysOnTop(1); 
    
    tempSettings = settings;
    numFeatures = 24;
    d_orgs = zeros(0,length(settings.inputImages),numFeatures);
    
    for f=1:length(settings.inputImages)
        settings.currentImageIndex = f;
        settings.currentImage = (imread(settings.inputImages{settings.currentImageIndex}));

        [folder, file, ext] = fileparts(settings.inputImages{settings.currentImageIndex});
        inputFileName = [settings.outputFolder 'Temp' filesep file '.mat'];
        
        %% load the project
        settings.currentImageIndex = min(f, length(settings.inputImages));
        settings.currentImage = (imread(settings.inputImages{settings.currentImageIndex}));
        settings.currentFluorescenceImage = (imread(settings.fluorescenceImages{settings.currentImageIndex}));
        loadProject;
%         %if (settings.performAutoUpdate == true)
%             performAutomaticDetection;
%         %else
%             updateDetectionFilters; 
%         %end
                
        settings.fullRegionProps = true;
        performAutomaticDetection;
        updateDetectionFilters;
        updateVisualization;
        [folder, file, ext] = fileparts(inputFileName);
        %imwrite(settings.watershedImage, [outputFolder filesep 'Segmentation' filesep file '_Segmentation.tif']);

        currentRegionProps = settings.currentRegionProps;
        resultMatrix = zeros(size(settings.currentDetections, 1), numFeatures);
        for j=1:size(settings.currentDetections, 1)
            currentIndex = settings.currentDetections(j,end);
            resultMatrix(j,1) = j;
            resultMatrix(j,2) = currentRegionProps(currentIndex).Area;
            resultMatrix(j,3:4) = currentRegionProps(currentIndex).Centroid;
            resultMatrix(j,5) = 1;
            resultMatrix(j,6:7) = currentRegionProps(currentIndex).BoundingBox(3:end);
            resultMatrix(j,8) = 1;
            resultMatrix(j,9) = currentRegionProps(currentIndex).ConvexArea;
            resultMatrix(j,10) = currentRegionProps(currentIndex).Eccentricity;
            resultMatrix(j,11) = currentRegionProps(currentIndex).EquivDiameter;
            resultMatrix(j,12) = currentRegionProps(currentIndex).Extent;
            resultMatrix(j,13) = currentRegionProps(currentIndex).FilledArea;
            resultMatrix(j,14) = currentRegionProps(currentIndex).MinorAxisLength;
            resultMatrix(j,15) = currentRegionProps(currentIndex).MajorAxisLength;
            resultMatrix(j,16) = currentRegionProps(currentIndex).Orientation;
            resultMatrix(j,17) = currentRegionProps(currentIndex).Perimeter;
            resultMatrix(j,18) = currentRegionProps(currentIndex).Solidity;
            resultMatrix(j,19) = currentRegionProps(currentIndex).MinIntensity;
            resultMatrix(j,20) = currentRegionProps(currentIndex).MaxIntensity;
            resultMatrix(j,21) = currentRegionProps(currentIndex).MeanIntensity;
            resultMatrix(j,22) = currentRegionProps(currentIndex).MinIntensityAboveThreshold;
            resultMatrix(j,23) = currentRegionProps(currentIndex).MaxIntensityAboveThreshold;
            resultMatrix(j,24) = currentRegionProps(currentIndex).MeanIntensityAboveThreshold;
        end
        d_orgs(1:size(resultMatrix,1),f,:) = resultMatrix;
        dlmwrite([outputFolder filesep 'CSV' filesep file '_RegionProps.csv'], resultMatrix, ';');
        specifiers = 'id;area;xpos;ypos;zpos;xsize;ysize;zsize;convexArea;eccentricity;equivDiameter;extent;filledArea;minorAxisLength;majorAxisLength;orientation;perimeter;solidity;minIntensity;maxIntensity;meanIntensity;minIntensityAboveThreshold;maxIntensityAboveThreshold;meanIntensityAboveThreshold';
        prepend2file(specifiers, [outputFolder filesep 'CSV' filesep file '_RegionProps.csv'], 1);

        waitbar(f/length(settings.inputImages));
    end
    close(waitBarHandle);

    code = ones(size(d_orgs,1),1);
    var_bez = char(strsplit(specifiers, ';'));
    
    settings.areaIndex = 2;
    settings.meanIntensityIndex = 21;
    settings.meanIntensityAboveThresholdIndex = 24;
    
    PerformTracking;
    
    save([settings.outputFolder 'DropletDetectionProject.prjz'], '-mat', 'd_orgs', 'code', 'var_bez');
    
    settings = tempSettings;
    settings.fullRegionProps = false;
end