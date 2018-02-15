global settings;

settings.currentSelectedSeedIndices = [];
settings.currentDeSelectedSeedIndices = [];
for i=1:size(settings.currentSeeds,1)
    if (settings.currentSeeds(i,3) == 1)
        settings.currentSelectedSeedIndices = [settings.currentSelectedSeedIndices; settings.watershedImage(settings.currentSeeds(i,2), settings.currentSeeds(i,1))];
    else
        settings.currentDeSelectedSeedIndices = [settings.currentDeSelectedSeedIndices; settings.watershedImage(settings.currentSeeds(i,2), settings.currentSeeds(i,1))];
    end
end
    
settings.currentDetections = [];
for i=1:length(settings.currentRegionProps)
    
    isInteriorSegment = (settings.currentRegionProps(i).Centroid(1)-settings.currentRegionProps(i).EquivDiameter) > 1 && ...
                        (settings.currentRegionProps(i).Centroid(2)-settings.currentRegionProps(i).EquivDiameter) > 1 && ...    
                        (settings.currentRegionProps(i).Centroid(1)+settings.currentRegionProps(i).EquivDiameter) < size(settings.currentImage, 2) && ...
                        (settings.currentRegionProps(i).Centroid(2)+settings.currentRegionProps(i).EquivDiameter) < size(settings.currentImage, 1);
                    
    
%     if (isInteriorSegment == false)
%         plot(settings.currentRegionProps(i).Centroid(1), settings.currentRegionProps(i).Centroid(2), '*r');
%     else
%         plot(settings.currentRegionProps(i).Centroid(1), settings.currentRegionProps(i).Centroid(2), '*g');
%     end        
    
   if ((settings.currentRegionProps(i).Area >= settings.minArea && ...
       settings.currentRegionProps(i).Eccentricity <= settings.maxEccentricity && ...
       settings.currentRegionProps(i).MeanIntensity >= settings.minIntensity && ...
       isInteriorSegment == true && ...
       ~ismember(i, settings.currentDeSelectedSeedIndices)) || ismember(i, settings.currentSelectedSeedIndices))
       settings.currentDetections = [settings.currentDetections; ...
                                     settings.currentRegionProps(i).Centroid, ...
                                     settings.currentRegionProps(i).EquivDiameter/2, i];
   end    
end

settings.dirtyFlag = true;