global settings;
% settings.currentImage = imread('finalResult.tif');

settings.inputFolder = [uigetdir(pwd, 'Please select the folder containing the images to be used for droplet detection') filesep];
settings.inputFiles = dir([settings.inputFolder '*.tif']);
settings.fluorescenceFolder = [uigetdir([settings.inputFolder '../'], 'Please select the folder containing the fluorescence images') filesep];
settings.fluorescenceFiles = dir([settings.fluorescenceFolder '*.tif']);
settings.inputImages = cell(0,0);
currentImageRaw = 1;
for i=1:length(settings.inputFiles)
    [folder, file, ext] = fileparts([settings.inputFolder settings.inputFiles(i).name]);
    if (strcmpi(ext, '.jpg') || strcmpi(ext, '.tif'))
        settings.inputImages{currentImageRaw} = [settings.inputFolder settings.inputFiles(i).name];
        currentImageRaw = currentImageRaw+1;
    end
end

currentImageFluorescence = 1;
for i=1:length(settings.fluorescenceFiles)
    [folder, file, ext] = fileparts([settings.fluorescenceFolder settings.fluorescenceFiles(i).name]);
    if (strcmpi(ext, '.jpg') || strcmpi(ext, '.tif'))
        settings.fluorescenceImages{currentImageFluorescence} = [settings.fluorescenceFolder settings.fluorescenceFiles(i).name];
        currentImageFluorescence = currentImageFluorescence+1;
    end
end

%% specify the output folder
settings.outputFolder = [settings.inputFolder 'Results' filesep];
if (~exist(settings.outputFolder, 'dir'))
    mkdir(settings.outputFolder);
end
if (~exist([settings.outputFolder 'Segmentation'], 'dir'))
    mkdir([settings.outputFolder 'Segmentation']);
end
if (~exist([settings.outputFolder 'Temp'], 'dir'))
    mkdir([settings.outputFolder 'Temp']);
end
if (~exist([settings.outputFolder 'CSV'], 'dir'))
    mkdir([settings.outputFolder 'CSV']);
end
if (~exist([settings.outputFolder 'Tracking'], 'dir'))
    mkdir([settings.outputFolder 'Tracking']);
end

settings.currentImageIndex = 1;
settings.currentImage = (imread(settings.inputImages{settings.currentImageIndex}));
settings.currentFluorescenceImage = (imread(settings.fluorescenceImages{settings.currentImageIndex}));
settings.watershedImage = zeros(size(settings.currentImage));
%settings.currentSeedImage = zeros(size(settings.currentImage));
settings.currentResultImage = cat(3, settings.currentImage, settings.currentImage, settings.currentImage);
settings.currentSeeds = [];
settings.currentSeedIndices = [];
settings.currentDetections = [];
settings.deletionRadius = 20;
settings.hminimaHeight = 40;
settings.medFiltWidth = 9;
settings.imageHandle = [];
settings.fontSize = 20;
settings.showFluorescenceChannel = false;
settings.showWatershedResult = false;
settings.mainFigure = figure(1);
settings.performAutoUpdate = false;
settings.fullRegionProps = false;
settings.minArea = 0;
settings.maxEccentricity = 1.0;
settings.minIntensity = 0;
settings.intensityFeatureThreshold = 0;
settings.featureMode = 1;
settings.showParameters = false;
settings.dirtyFlag = false;

settings.useWatershed = false;
settings.houghScaleFactor = 0.5;
settings.houghSensitivity = 0.9;
settings.houghEdgeThreshold = 0.1;
settings.houghMinRadius = 20;
settings.houghMaxRadius = 40;

%% mouse, keyboard events and window title
set(settings.mainFigure, 'WindowScrollWheelFcn', @ScrollEventHandler);
set(settings.mainFigure, 'KeyReleaseFcn', @KeyReleaseEventHandler);
set(settings.mainFigure, 'WindowButtonDownFcn', @mouseUp);
set(settings.mainFigure, 'CloseRequestFcn', @closeRequestHandler);

if (settings.performAutoUpdate == true)
    performAutomaticDetection;
end
updateVisualization;