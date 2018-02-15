
global settings;
waitBarHandle = waitbar(0,'Generating tracking results ...');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);
outputFolder = settings.outputFolder;
    
if (size(d_orgs, 2) > 1)
    par.anz_dat = size(d_orgs,1);
    par.anz_merk = size(d_orgs,3);

    %% set maximum allowed distance and track the cells
    parameter.gui.tracking.zscale = 1;
    parameter.gui.tracking.max_distance = 100;
    parameter.gui.tracking.maxDist = 100;
    parameter.gui.tracking.add_missing_nucleus = false;
    parameter.gui.tracking.velocity_correction = false;

    callback_tracking_regionprops;
    callback_extract_tracklets_regionprops;

    save([settings.outputFolder filesep file '_SciXMiner.prjz'], '-mat', 'd_orgs', 'code', 'var_bez');

    %% save the tracklets. Using -v7.3 is neccessary for larger file sizes
    save([settings.outputFolder filesep file '_SciXMiner.tracklets'], '-mat', '-v7', 'tracklets', 'trackletsPerTimePoint');

    %% sort the 
    lengths = [];
    for i=1:length(tracklets)
        lengths = [lengths; length(tracklets(i).ids)];
    end

    %[sortedLengths, sortedIndices] = sort(lengths, 'descend');
    sortedIndices = 1:length(tracklets);
    meanIntensityTable = zeros(length(tracklets), size(d_orgs,2));
    meanIntensityAboveThresholdTable = zeros(length(tracklets), size(d_orgs,2));
    areaTable = zeros(length(tracklets), size(d_orgs,2));
    speedTable = zeros(length(tracklets), size(d_orgs,2));

    currentLine = 1;
    for i=sortedIndices
        currentTracklet = tracklets(i);
        
        %% skip tracklet if it's not complete
        if (currentTracklet.startTime > 1 || currentTracklet.endTime < size(d_orgs,2)-1)
            continue;
        end
        
        currentArea = d_orgs(currentTracklet.ids(1), currentTracklet.startTime:currentTracklet.endTime, settings.areaIndex);
        currentMeanIntensity = d_orgs(currentTracklet.ids(1), currentTracklet.startTime:currentTracklet.endTime, settings.meanIntensityIndex);
        currentMeanIntensityAboveThreshold = d_orgs(currentTracklet.ids(1), currentTracklet.startTime:currentTracklet.endTime, settings.meanIntensityAboveThresholdIndex);
        
        range1 = currentTracklet.startTime:currentTracklet.endTime;
        range1 = range1(1:end-1);
        range2 = 1+(currentTracklet.startTime:currentTracklet.endTime);
        range2 = range2(1:end-1);
        if (length(range1) == 1)
            currentSpeed = sqrt(sum(squeeze(d_orgs(currentTracklet.ids(1), range2, 3:4) - d_orgs(currentTracklet.ids(1), range1, 3:4))'.^2, 2));
        else
            currentSpeed = sqrt(sum(squeeze(d_orgs(currentTracklet.ids(1), range2, 3:4) - d_orgs(currentTracklet.ids(1), range1, 3:4)).^2, 2));
        end
        currentSpeed(end+1) = 0;

        areaTable(currentLine, currentTracklet.startTime:currentTracklet.endTime) = currentArea;
        meanIntensityTable(currentLine, currentTracklet.startTime:currentTracklet.endTime) = currentMeanIntensity;
        meanIntensityAboveThresholdTable(currentLine, currentTracklet.startTime:currentTracklet.endTime) = currentMeanIntensityAboveThreshold;
        speedTable(currentLine, currentTracklet.startTime:currentTracklet.endTime) = currentSpeed;
        currentLine = currentLine+1;
    end
    
    waitbar(0.1);

    dlmwrite([settings.outputFolder filesep 'Tracking' filesep 'area.csv'], areaTable, ';');
    dlmwrite([settings.outputFolder filesep 'Tracking' filesep 'meanIntensity.csv'], meanIntensityTable, ';');
    dlmwrite([settings.outputFolder filesep 'Tracking' filesep 'meanIntensityAboveThreshold.csv'], meanIntensityAboveThresholdTable, ';');
    dlmwrite([settings.outputFolder filesep 'Tracking' filesep 'speed.csv'], speedTable, ';');

    waitbar(0.2);
    
    v = VideoWriter([outputFolder filesep 'Tracking' filesep 'trackingVideo.avi']);
    v.FrameRate = 10; 
    open(v);
    
    fh = figure(2); clf;
    set(fh, 'Position', get(0,'Screensize'), 'Color', [0,0,0]); colormap gray;
    for i=1:(size(d_orgs,2)-1)
        fh = figure(2);
        currentImage = (imread(settings.inputImages{i}));
        imagesc(currentImage); 
        
        hold on;        
        axis equal;
        set(gca, 'Color', [0,0,0])
        axis off
        axis tight
        
        currentTrackletId = 1;
        for j=1:length(trackletsPerTimePoint(i).tracklets)
            currentTracklet = tracklets(trackletsPerTimePoint(i).tracklets(j));
            
            %% skip tracklet if it's not complete
            if (currentTracklet.startTime > 1 || currentTracklet.endTime < size(d_orgs,2)-1)
                continue;
            end
                        
            currentPosition = d_orgs(currentTracklet.ids(1), i, 3:5);
            plot(currentPosition(1), currentPosition(2), '.r');
            plot(d_orgs(currentTracklet.ids(1), currentTracklet.startTime:i, 3), d_orgs(currentTracklet.ids(1), currentTracklet.startTime:i, 4), '-r');
            text(currentPosition(1)+2, currentPosition(2), num2str(currentTrackletId));
            currentTrackletId = currentTrackletId+1;
        end
        
        myframe = getframe(fh);
        writeVideo(v, frame2im(myframe));
        
        hold off;
        drawnow;
        
        waitbar(0.2 + 0.8*(i/size(d_orgs,2)));
    end
    
    close(v);
    close(fh);
end

close(waitBarHandle);