global settings;

[folder, file, ext] = fileparts(settings.inputImages{settings.currentImageIndex});
inputFileName = [settings.outputFolder 'Temp' filesep file '.mat'];

if (exist(inputFileName, 'file'))
    load(inputFileName);
    settings.watershedImage = currentWatershedImage;
    %settings.currentSeedImage = currentSeedImage;
    settings.currentResultImage = currentResultImage;
    settings.currentSeeds = currentSeeds;
    settings.deletionRadius = deletionRadius;
%     settings.hminimaHeight = hminimaHeight;
%     settings.minArea = minArea;
%     settings.maxEccentricity = maxEccentricity;
%     settings.minIntensity = minIntensity;
    settings.currentDetections = currentDetections;
    settings.currentRegionProps = currentRegionProps;
    updateDetectionFilters;
else
    settings.currentSeeds = [];
    performAutomaticDetection;
end
