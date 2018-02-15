
global settings;

saveProject;
settings.currentImageIndex = min(settings.currentImageIndex+1, length(settings.inputImages));
settings.currentImage = (imread(settings.inputImages{settings.currentImageIndex}));
settings.currentFluorescenceImage = (imread(settings.fluorescenceImages{settings.currentImageIndex}));
loadProject;
if (settings.performAutoUpdate == true)
    performAutomaticDetection;
else
    updateDetectionFilters;
end
updateVisualization;