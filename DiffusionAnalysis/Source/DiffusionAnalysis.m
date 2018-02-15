
%% parameters
inputPath = uigetdir(pwd, 'Select folder containing fluorescence images of two channels with prefix GFP / RFP');   %% input path containing the images of interest
inputPath = [inputPath filesep];
numPoints = 360;          %% the number of sampling points along the circle, i.e., an angle step of 2*pi / numPoints
numCircleFitPoints = 8;
useMask = false;
debugFigures = true;

%% add third party tools for ellipse fitting and tiff io
addpath('ThirdParty/saveastiff_4.3/');
addpath('ThirdParty/fit_ellipse/');
addpath('ThirdParty/ginputc/');

%% load the input images
inputFilesGFP = dir([inputPath 'GFP*.tif']);
inputFilesRFP = dir([inputPath 'RFP*.tif']);
numImagesGFP = length(inputFilesGFP);
numImagesRFP = length(inputFilesRFP);
if (numImagesGFP ~= numImagesRFP)
    error('Please make sure the folder contains the same amount of GFP and RFP images!');
end

%% clear any previous images
clear inputImages;
clear inputImagesRFP;
clear inputImagesGFP;
for i=1:length(inputFilesGFP)
   inputImagesGFP{i} = double(imread([inputPath inputFilesGFP(i).name]));
   inputImagesRFP{i} = double(imread([inputPath inputFilesRFP(i).name]));
end

%% reference image
referenceImage = inputImagesGFP{1};

%% initialize the mask image
if (useMask == true)
    %% plot the first frame to fit the ellipses
    figure(1); clf;
    imagesc(referenceImage);
    axis equal;
    hold on;
    
    %% initialize the mask image
    maskImage = zeros(size(referenceImage,1), size(referenceImage,2), 2);

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
        currentMask = zeros(size(referenceImage,1), size(referenceImage,2));

        %% convert the indices of the mask to xy coordinates
        [y, x] = ind2sub(size(currentMask), 1:length(currentMask(:)));
        x = x - currentEllipse.X0_in;
        y = y - currentEllipse.Y0_in;
        params = currentEllipse.params;
        centroid = [currentEllipse.X0_in, currentEllipse.Y0_in];

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
    maskImage = maskImage(:,:,1) & ~maskImage(:,:,2);
else
    maskImage = ones(size(referenceImage));
    centroid = [size(referenceImage,2)/2, size(referenceImage,1)/2];
end

%% specify the pixels of interest (only the ones that lie within the mask band)
validIndices = find(maskImage > 0);
[y, x] = ind2sub(size(referenceImage), validIndices);
x = x - centroid(1);
y = y - centroid(2);
[theta,rho] = cart2pol(x, y);

resultMatrixGFP = zeros(numImagesGFP, numPoints);
resultMatrixRFP = zeros(numImagesGFP, numPoints);

angleImage = zeros(size(referenceImage));

%% perform the average fluorescence measurements
for i=1:numImagesGFP
    stepSize = 2*pi / numPoints;
    for j=0:(numPoints-1)
        currentAngleRange = [j*stepSize-pi, (j+1)*stepSize-pi];
        currentAngleIndices = find(theta > currentAngleRange(1) & theta <= currentAngleRange(2));

        resultMatrixGFP(i ,j+1) = max(inputImagesGFP{i}(validIndices(currentAngleIndices)));
        resultMatrixRFP(i, j+1) = max(inputImagesRFP{i}(validIndices(currentAngleIndices)));
        
        angleImage(validIndices(currentAngleIndices)) = j+1;
    end
end

%% get the maximum intensity for axis scaling
maxIntensity = max(max(resultMatrixGFP(:)), max(resultMatrixRFP(:)));
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
    figure(2); clf;
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
        title('GFP');
        %axis equal;
        axis tight;
        caxis([0, maxIntensityGFP]);

        subplot(3,numImagesGFP,i+2*numImagesGFP);
        imagesc(inputImagesRFP{i});
        title('RFP');
        colormap gray;
        %axis equal;
        axis tight;
        caxis([0, maxIntensityRFP]);
    end
end