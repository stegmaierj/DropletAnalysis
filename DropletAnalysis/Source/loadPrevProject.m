
global settings;
saveProject;
settings.currentImageIndex = max(1, settings.currentImageIndex-1);
settings.currentImage = (imread(settings.inputImages{settings.currentImageIndex}));
settings.currentFluorescenceImage = (imread(settings.fluorescenceImages{settings.currentImageIndex}));
loadProject;
if (settings.performAutoUpdate == true)
    performAutomaticDetection;
else
    updateDetectionFilters; 
end
updateVisualization;