global settings;

if (settings.dirtyFlag == true)
    %currentSeedImage = settings.currentSeedImage;
    currentWatershedImage = settings.watershedImage;
    currentResultImage = settings.currentResultImage;
    currentSeeds = settings.currentSeeds;
    deletionRadius = settings.deletionRadius;
    hminimaHeight = settings.hminimaHeight;
    minArea = settings.minArea;
    maxEccentricity = settings.maxEccentricity;
    minIntensity = settings.minIntensity;
    currentDetections = settings.currentDetections;
    currentRegionProps = settings.currentRegionProps;

    [folder, file, ext] = fileparts(settings.inputImages{settings.currentImageIndex});
    outputFileName = [settings.outputFolder 'Temp' filesep file '.mat'];
    save(outputFileName, '-mat', 'currentResultImage', 'currentSeeds', 'deletionRadius', 'hminimaHeight', 'currentWatershedImage', 'minIntensity', 'minArea', 'maxEccentricity', 'currentDetections', 'currentRegionProps');
    settings.dirtyFlag = false;
end