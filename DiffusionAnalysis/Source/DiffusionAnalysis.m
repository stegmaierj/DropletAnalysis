% close all;

%% parameters
inputPath = uigetdir(pwd, 'Select folder containing fluorescence images of two channels with prefix GFP / RFP');   %% input path containing the images of interest
inputPath          = [inputPath filesep];
numPoints          = 360;          % the number of sampling points along the circle, i.e., an angle step of 2*pi / numPoints
numCircleFitPoints = 8;            % for mask 'auto'
debugFigures       = true;
mask               = 'auto';       % 'full', 'manual', 'auto'


%% add third party tools for ellipse fitting and tiff io
addpath(genpath('ThirdParty/'));


%% load the input images and clear any previous images
inputFilesGFP = dir([inputPath 'GFP*.tif']);
inputFilesRFP = dir([inputPath 'RFP*.tif']);
numImagesGFP  = length(inputFilesGFP);
numImagesRFP  = length(inputFilesRFP);
if (numImagesGFP ~= numImagesRFP)
    error('Please make sure the folder contains the same amount of GFP and RFP images!');
end

clear inputImages;
clear inputImagesRFP;
clear inputImagesGFP;
for i=1:length(inputFilesGFP)
   inputImagesGFP{i} = double(imread([inputPath inputFilesGFP(i).name]));
   inputImagesRFP{i} = double(imread([inputPath inputFilesRFP(i).name]));
end
[m,n] = size( inputImagesGFP{1} );


%% Region of interest / mask
centroid  = zeros(numImagesGFP,2);
switch mask
    
    case 'full'
        maskImage = ones(m,n,numImagesGFP);
        centroid  = repmat([m/2, n/2],3,1);
        
    case 'manual'
        %% plot the first frame to fit the ellipses
        figure; set(gcf,'Units','normalized','outerposition',[0.05 0 0.95 1],...
                        'PaperPositionMode','Manual');
        imagesc(inputImagesGFP{1});
        axis equal;
        hold on;
        
        %% initialize the mask image
        maskImage = zeros(m, n, numImagesGFP);

        %% specify the region of interest
        for i=1:2
            if (i==1)
                title('Provide 8 points on the outer boundary of the circle (start on top and proceed clock-wise).');
            else
                title('Provide 8 points on the inner boundary of the circle (start on top and proceed clock-wise).');
            end

            %% get input points
            [ellipsePointsX, ellipsePointsY] = ginputc(numCircleFitPoints, 'Color', 'r');
            currentEllipse = fit_ellipse(ellipsePointsX, ellipsePointsY);

            %% initialize the temporary current mask
            currentMask = zeros(m, n);

            %% convert the indices of the mask to xy coordinates
            [y, x]   = ind2sub(size(currentMask), 1:length(currentMask(:)));
            x        = x - currentEllipse.X0_in;
            y        = y - currentEllipse.Y0_in;
            params   = currentEllipse.params;
            centroid = repmat([currentEllipse.X0_in, currentEllipse.Y0_in],3,1);

            %% check if the points lie in the fitted ellipse and set the contained pixels to 1
            isInside = (params(1)*x.^2 + params(2)*x.*y + params(3)*y.^2 + params(4)*x + params(5)*y) <= 1;
            currentMask(isInside) = 1;
            maskImage(:,:,i) = currentMask;

            currentBoundary = bwboundaries(currentMask);

            if (i == 1)
                plot(currentBoundary{1}(:,2), currentBoundary{1}(:,1), 'r', 'LineWidth', 1);
                plot(ellipsePointsX, ellipsePointsY, '*r');
            else
                plot(currentBoundary{1}(:,2), currentBoundary{1}(:,1), 'g', 'LineWidth', 1);
                plot(ellipsePointsX, ellipsePointsY, '*g');
            end
            
        end

        %% combine the inner and the outer mask
        maskImage = repmat(maskImage(:,:,1) & ~maskImage(:,:,2),1,1,3);
        
            
    case 'auto'
        % Find region of interest with simple edge filter and morphological
        % operations (same mask for GFP and RFP images). Assumption: 
        % circle/ellipse fills nearly the whole image (for the dilation).
        maskImage = false(m,n,numImagesGFP);

        for h = 1 : numImagesGFP

            % binomial filtering of the sum of GFP and RFP image
            inputImageFiltered = binFilter( inputImagesGFP{h} + inputImagesRFP{h} );

            % Find edges in filtered image
            [BW,threshold] = edge(inputImageFiltered, 'sobel');

            % Dilation
            maskImage(:,:,h) = imdilate(BW, ones(ceil(m/20), ceil(n/20) ) );
            
            % Remove objects smaller than m*n/150 pixels. 
            maskImage(:,:,h) = bwareaopen(maskImage(:,:,h), ceil(m*n/150)  );

            % Find centroid with ellipsoidal-fit (use only 0.05% of the
            % values given).
            maskImageIndices = find( maskImage(:,:,h) == 1 );
            ellipseIndices   = maskImageIndices(randperm( length( maskImageIndices ), ceil(0.0005 * length(maskImageIndices))));
            [yEll,xEll]      = ind2sub([m n],ellipseIndices);
            currentEllipse   = fit_ellipse(xEll,yEll);
            centroid(h,:)    = [currentEllipse.X0_in, currentEllipse.Y0_in];  

            % Estimate maskImage
            [columnsInImage, rowsInImage] = meshgrid(1:n, 1:m);
            centerX = currentEllipse.X0_in;
            centerY = currentEllipse.Y0_in;
            radiusXmax = currentEllipse.a * 1.15;
            radiusYmax = currentEllipse.b * 1.15;
            radiusXmin = currentEllipse.a * 0.85;
            radiusYmin = currentEllipse.b * 0.85;
            maskImage(:,:,h) = ( (rowsInImage - centroid(h,2)).^2 ./ radiusYmax^2 ...
                + (columnsInImage - centroid(h,1)).^2 ./ radiusXmax^2 <= 1 ) ...
                ~= ( (rowsInImage - centroid(h,2)).^2 ./ radiusYmin^2 ...
                + (columnsInImage - centroid(h,1)).^2 ./ radiusXmin^2 <= 1 );

            % Plot ROI
            if debugFigures
                figure;
                set(gcf,'Units','normalized','outerposition',[0.05 0 0.95 1],...
                        'PaperPositionMode','Manual');
                imshowpair(inputImagesGFP{h}+inputImagesRFP{h},maskImage(:,:,h),'blend');
                hold on;
                plot(centroid(h,1),centroid(h,2),'+');
                hold off;
                title('ROI');
            end
        end

end


%% specify the pixels of interest (only the ones that lie within the mask band)
resultMatrixGFP = zeros(numImagesGFP, numPoints);
resultMatrixRFP = zeros(numImagesGFP, numPoints);
for i=1 : numImagesGFP
    validIndices = find(maskImage(:,:,i) > 0);
    [y, x] = ind2sub([m,n], validIndices);
    x = x - centroid(i,1);
    y = y - centroid(i,2);
    [theta,rho] = cart2pol(x, y);

    
    % perform the average fluorescence measurements
    stepSize = 2*pi / numPoints;
    for j=0:(numPoints-1)
        currentAngleRange = [j*stepSize-pi, (j+1)*stepSize-pi];
        currentAngleIndices = find(theta > currentAngleRange(1) & theta <= currentAngleRange(2));

        if ~isempty(currentAngleIndices) 
            resultMatrixGFP(i ,j+1) = max(inputImagesGFP{i}(validIndices(currentAngleIndices)));
            resultMatrixRFP(i, j+1) = max(inputImagesRFP{i}(validIndices(currentAngleIndices)));
        end
    end
    
end


%% get the maximum intensity for axis scaling
maxIntensity    = max(max(resultMatrixGFP(:)), max(resultMatrixRFP(:)));
maxIntensityGFP = max([inputImagesGFP{1}(:); inputImagesGFP{2}(:); inputImagesGFP{3}(:)]);
maxIntensityRFP = max([inputImagesRFP{1}(:); inputImagesRFP{2}(:); inputImagesRFP{3}(:)]);


%% save data to scixminer project
d_org = zeros(numImagesGFP, 3);
timePosition = strfind(inputFilesGFP(1).name, '-t');
for i=1:numImagesGFP
   d_org(i,1) = str2double(inputFilesGFP(i).name((timePosition+2):(timePosition+4)));
   d_org(i,2) = mean(inputImagesGFP{i}(:));
   d_org(i,3) = mean(inputImagesRFP{i}(:));
   d_org(i,4) = min(inputImagesGFP{i}(:));
   d_org(i,5) = min(inputImagesRFP{i}(:));
   d_org(i,6) = max(inputImagesGFP{i}(:));
   d_org(i,7) = max(inputImagesRFP{i}(:));
end
dorgbez = char('TimePoint', 'MeanIntensityGFP', 'MeanIntensityRFP', 'MinIntensityGFP', 'MinIntensityRFP', 'MaxIntensityGFP', 'MaxIntensityRFP');
d_orgs = zeros(numImagesGFP, numPoints, 2);
d_orgs(:,:,1) = resultMatrixGFP;
d_orgs(:,:,2) = resultMatrixRFP;
var_bez = char('RadialMaxIntensityGFP', 'RadialMaxIntensityRFP');
code = ones(numImagesGFP, 1);
save([inputPath 'SciXMinerResults.prjz'], '-mat', 'd_orgs', 'd_org', 'dorgbez', 'var_bez', 'code');


%% plot the results
if (debugFigures == true)
    figure; set(gcf,'Units','normalized',...
        'outerposition',[0.05 0 0.95 1],...
        'PaperPositionMode','Manual');
    
    for i=1:numImagesGFP
        subplot(3,numImagesGFP,i);
        plot(1:numPoints, resultMatrixGFP(i,:), '-g'); hold on;
        plot(1:numPoints, resultMatrixRFP(i,:), '-r');
        axis([0, 360, 0, maxIntensity]);
        ylabel('Max Intensity (a.u.)');
        xlabel('Angle (°)');
        title(strrep(inputFilesGFP(i).name, '_', '\_'));
        legend('GFP', 'RFP');
        box off;

        subplot(3,numImagesGFP,i+numImagesGFP);
        %imagesc(cat(3, zeros(size(inputImagesGFP{i})), inputImagesGFP{i}, zeros(size(inputImagesGFP{i}))));
        imagesc(inputImagesGFP{i});
        hold on;
        plot(centroid(i,1),centroid(i,2),'+');
        hold off;
        
        title('GFP');
        %axis equal;
        axis tight;
        caxis([0, maxIntensityGFP]);

        subplot(3,numImagesGFP,i+2*numImagesGFP);
        imagesc(inputImagesRFP{i});
        hold on;
        plot(centroid(i,1),centroid(i,2),'+');
        hold off;     
        
        title('RFP');
        colormap gray;
        %axis equal;
        axis tight;
        caxis([0, maxIntensityRFP]);
    end
    
end