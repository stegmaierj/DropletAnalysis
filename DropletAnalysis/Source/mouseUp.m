function mouseDown(~, ~)

%% get global variables
global settings;

%% get current modifier keys
modifiers = get(gcf,'currentModifier');        %(Use an actual figure number if known)
shiftPressed = ismember('shift',modifiers);
ctrlPressed = ismember('control',modifiers);
altPressed = ismember('alt',modifiers);
currentButton = get(gcbf, 'SelectionType');
clickPosition = get(gca, 'currentpoint');
clickPosition = round([clickPosition(1,1), clickPosition(1,2)]);

%% add the click point as a positive or negative coexpression point including mean intensity calculations
if (ctrlPressed == true && shiftPressed == false)
    settings.currentSeeds = [settings.currentSeeds; clickPosition, 1];
    %settings.currentSeedImage(clickPosition(2), clickPosition(1)) = 1;
    
    %if (settings.performAutoUpdate == true)
        updateDetectionFilters;
    %end
elseif (ctrlPressed == false && shiftPressed == true)
    settings.currentSeeds = [settings.currentSeeds; clickPosition, 0];
    %settings.currentSeedImage(clickPosition(2), clickPosition(1)) = 1;
    
    %if (settings.performAutoUpdate == true)
        updateDetectionFilters;
    %end    
elseif (shiftPressed == true && ctrlPressed == true)
    minDist = inf;
    minIndex = 1;    
    for i=1:size(settings.currentSeeds, 1)
        distance = sqrt(sum((settings.currentSeeds(i,1:2) - clickPosition).^2));
        
        if (distance < minDist)
            minDist = distance;
            minIndex = i;
        end
    end
    
    if (minDist < settings.deletionRadius)
        %settings.currentSeedImage(settings.currentSeeds(minIndex,2), settings.currentSeeds(minIndex,1)) = 0;
        settings.currentSeeds(minIndex,:) = [];
    end
    
    %if (settings.performAutoUpdate == true)
        updateDetectionFilters;
    %end
end

%% update the visualization
updateVisualization;

end