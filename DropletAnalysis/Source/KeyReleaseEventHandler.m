%% the key event handler
function KeyReleaseEventHandler(src,evt)
    global settings;
    
    %% switch between the images of the loaded series
    if (strcmp(evt.Character, '.') || strcmp(evt.Key, 'rightarrow'))
        loadNextProject;
    elseif (strcmp(evt.Character, ',') || strcmp(evt.Key, 'leftarrow'))
        loadPrevProject;
    %% not implemented yet, maybe use for contrast or scrolling
    elseif (strcmp(evt.Character, '+') || strcmp(evt.Key, 'uparrow'))
        if (settings.useWatershed == true)
            if (settings.featureMode == 1)
                settings.hminimaHeight = settings.hminimaHeight + 1;
            elseif (settings.featureMode == 2)
                settings.minArea = settings.minArea + 100;
            elseif (settings.featureMode == 3)
                settings.maxEccentricity = min(1.0, settings.maxEccentricity + 0.05);
            elseif (settings.featureMode == 4)
                settings.minIntensity = min(255, settings.minIntensity + 5);
            end
        else
            if (settings.featureMode == 1)
                settings.houghScaleFactor = min(1, settings.houghScaleFactor * 2);
            elseif (settings.featureMode == 2)
                settings.houghSensitivity = min(1.0, settings.houghSensitivity + 0.05);
            elseif (settings.featureMode == 3)
                settings.houghEdgeThreshold = min(1.0, settings.houghEdgeThreshold + 0.05);
            elseif (settings.featureMode == 4)
                settings.minIntensity = min(255, settings.minIntensity + 5);
            elseif (settings.featureMode == 5)
                settings.houghMinRadius = min(100, settings.houghMinRadius + 1);
            elseif (settings.featureMode == 6)
                settings.houghMaxRadius = min(100, settings.houghMaxRadius + 1);
            end
        end
        
        settings.dirtyFlag = true;
        
%         settings.houghScaleFactor = 1;
% settings.houghSensitivity = 0.9;
% settings.houghEdgeThreshold = 0.1;
% settings.houghMinRadius = 20;
% settings.houghMaxRadius = 40;

                
        if (settings.performAutoUpdate == true)
            performAutomaticDetection;
        else
            updateDetectionFilters; 
        end
        updateVisualization;
    elseif (strcmp(evt.Character, '-') || strcmp(evt.Key, 'downarrow'))
        if (settings.useWatershed == true)
            if (settings.featureMode == 1)
                settings.hminimaHeight = max(1, settings.hminimaHeight - 1);
            elseif (settings.featureMode == 2)
                settings.minArea = max(0, settings.minArea - 100);
            elseif (settings.featureMode == 3)
                settings.maxEccentricity = max(0.0, settings.maxEccentricity - 0.05);
            elseif (settings.featureMode == 4)
                settings.minIntensity = max(0, settings.minIntensity - 5);
            end
        else
            if (settings.featureMode == 1)
                settings.houghScaleFactor = max(0.25, settings.houghScaleFactor / 2);
            elseif (settings.featureMode == 2)
                settings.houghSensitivity = max(0.0, settings.houghSensitivity - 0.05);
            elseif (settings.featureMode == 3)
                settings.houghEdgeThreshold = max(0.0, settings.houghEdgeThreshold - 0.05);
            elseif (settings.featureMode == 4)
                settings.minIntensity = max(0, settings.minIntensity - 5);
            elseif (settings.featureMode == 5)
                settings.houghMinRadius = max(5, settings.houghMinRadius - 1);
            elseif (settings.featureMode == 6)
                settings.houghMaxRadius = max(5, settings.houghMaxRadius - 1);
            end
        end
        
        settings.dirtyFlag = true;
        
        if (settings.performAutoUpdate == true && settings.featureMode == 1)
            performAutomaticDetection;
        else
            updateDetectionFilters; 
        end
        updateVisualization;
    %% save dialog
    elseif (strcmp(evt.Character, 'u'))
        performAutomaticDetection;
        updateVisualization;
    elseif (strcmp(evt.Character, 's'))
        saveProject;
    elseif (strcmp(evt.Character, 'e'))
        exportResults;          
    elseif (strcmp(evt.Character, 'f'))
        settings.showWatershedResult = false;
        settings.showFluorescenceChannel = true;
        updateVisualization;
    elseif (strcmp(evt.Character, 'c'))
        settings.useWatershed = ~settings.useWatershed;
        performAutomaticDetection;
        updateVisualization;
    elseif (strcmp(evt.Character, 'd'))
        set(settings.mainFigure, 'WindowButtonDownFcn', '');
        if (~isempty(settings.imageHandle))
            h = imfreehand;
            if (~isempty(h))
                maskImage = createMask(h, settings.imageHandle);
                deletionIndices = [];
                if (sum(maskImage(:)) > 0)
                    for i=1:size(settings.currentSeeds,1)
                        currentPosition = settings.currentSeeds(i,:);
                        if (maskImage(currentPosition(2), currentPosition(1)) > 0)
                            deletionIndices = [deletionIndices, i];
                        end
                    end
                    settings.currentSeeds(deletionIndices,:) = [];
                    settings.currentSeedImage = settings.currentSeedImage .* ~maskImage;
                end
            end
            updateVisualization;
        end
        set(settings.mainFigure, 'WindowButtonDownFcn', @mouseUp);
    elseif (strcmp(evt.Character, 'r'))
        settings.currentSeedImage(:) = 0;
        settings.currentSeeds = [];
        updateVisualization;
    elseif (strcmp(evt.Character, 'h'))
        %% show the help dialog
        showHelp;
    elseif (strcmp(evt.Character, 'v'))    
        settings.showParameters = ~settings.showParameters;
        updateVisualization;
    elseif (strcmp(evt.Character, 'w'))
        settings.showWatershedResult = true;
        settings.showFluorescenceChannel = false;
        updateVisualization;
    elseif (strcmp(evt.Character, 'b'))
        settings.showWatershedResult = false;
        settings.showFluorescenceChannel = false;
        updateVisualization;
    elseif (strcmp(evt.Character, 'p'))
        %% ask for voxel resulution
        prompt = {'Scale Factor: ', 'Minimum Radius (px):','Maximum Radius (px):', 'Sensitivity ([0,..,1]):', 'EdgeThreshold ([0,...,1]):', 'Intensity Feature Threshold ([0,...,255]):'};
        dlg_title = 'Provide Hough Transform Parameters';
        num_lines = 1;
        defaultans = {num2str(settings.houghScaleFactor), ...
                      num2str(settings.houghMinRadius), ...
                      num2str(settings.houghMaxRadius), ...
                      num2str(settings.houghSensitivity), ...
                      num2str(settings.houghEdgeThreshold), ...
                      num2str(settings.intensityFeatureThreshold)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if (~isempty(answer))
            settings.houghScaleFactor = str2double(answer{1});
            settings.houghMinRadius = str2double(answer{2});
            settings.houghMaxRadius = str2double(answer{3});
            settings.houghSensitivity = str2double(answer{4});
            settings.houghEdgeThreshold = str2double(answer{5});
            settings.intensityFeatureThreshold = str2double(answer{6});
            performAutomaticDetection;
            updateVisualization;
        end
    elseif (strcmp(evt.Character, '1'))
        settings.featureMode = 1;
        updateVisualization;
    elseif (strcmp(evt.Character, '2'))
        settings.featureMode = 2;
        updateVisualization;
    elseif (strcmp(evt.Character, '3'))
        settings.featureMode = 3;
        updateVisualization;
    elseif (strcmp(evt.Character, '4'))
        settings.featureMode = 4;
        updateVisualization;
    elseif (strcmp(evt.Character, '5'))
        if (settings.useWatershed == false)
            settings.featureMode = 5;
        else
            settings.featureMode = 4;
        end
        updateVisualization;
    elseif (strcmp(evt.Character, '6'))
        if (settings.useWatershed == false)
            settings.featureMode = 6;
        else
            settings.featureMode = 4;
        end
        updateVisualization;
    elseif (strcmp(evt.Character, 'a'))
        settings.performAutoUpdate = ~settings.performAutoUpdate;
    end
end