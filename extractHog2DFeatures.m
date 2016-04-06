% ======================================================================= %
% Name: extractHog2DFeatures.m
% Author: Shubhra Aich
% Affiliation: M.Eng.(Ongoing), Chonnam National University
% E-mail: s.aich.72@gmail.com
% Description: This is the first file to extract HOG features from 
% Oxford-102 flower dataset. It extracts the HOG descriptors 
% from the foregound of the images in regular grid spacing. The file 
% hierarchy for Hog2D features extraction and testing using multiple kernel
% learning (Oxford-102 dataset) is listed as follows: 
% (1) extractHog2DFeatures.m, (2) makeHog2DDesMat.m, 
% (3) makeHog2DVisualCodebook_LD.m, (4) makeHog2DFeaMat.m, 
% (5) makeHog2DSimMat.m, (6) classifyMKL_Hog2D.m
% N.B. If the command "resourcedefaultpath" shows error, just restart
% MATLAB.
% ======================================================================= %

clear all; close all; clc;
restoredefaultpath;

%image_version = 'Images_Segmented_Adjusted';
image_version = 'Images_Min_500';
%image_version = 'Images_Min_500_Extended';
ORIENTATION_SIGNED = true; % default - false
THRESH_HOG = 0.0;
featName = 'hog2D';
cellSize = 8; % default
blockSize = 2; % default
numBins = 9; % default
blockLap = 0;
%blockLap = ceil(blockSize/2);
imgPath = ['../../Databases/Oxford/',image_version,'/'];
outPath = ['../../Databases/Oxford/Features/',image_version,'/'];
%imPref = 'adj_seg_image_';
imPref = '';
%imPref = 'image_';
addpath('../../Databases/Oxford/');

addpath(imgPath);
featName = [featName,'_',num2str(cellSize),'x',num2str(cellSize),'_', ...
    num2str(blockSize),'x',num2str(blockSize),'_bin_',num2str(numBins)];
outPath_deep = [outPath,featName,'/'];
mkdir(outPath_deep);

numImg = length(dir(imgPath))-2;

for i = 1:numImg
    disp(['Processing Image = ', num2str(i)]);
%     if i<10
%         addZeros = '0000';
%     elseif i>=10 && i<100
%         addZeros = '000';
%     elseif i>=100 && i<1000
%         addZeros = '00';
%     else
%         addZeros = '0';
%     end
    addZeros = '';
    im = imread([imPref,addZeros,num2str(i),'.jpg']);
    [desc,vp] = extractHOGFeatures(im(:,:,1),'CellSize',[cellSize,cellSize],...
        'BlockSize',[blockSize,blockSize],'NumBins', numBins, ...
        'BlockOverlap',[blockLap,blockLap], ...
        'UseSignedOrientation', ORIENTATION_SIGNED); % desc format single
    desc = reshape(desc,[numBins,length(desc)/numBins]);
    [desc2,~] = extractHOGFeatures(im(:,:,2),'CellSize',[cellSize,cellSize],...
        'BlockSize',[blockSize,blockSize],'NumBins', numBins, ...
        'BlockOverlap',[blockLap,blockLap], ...
        'UseSignedOrientation', ORIENTATION_SIGNED); % desc format single
    desc2 = reshape(desc2,[numBins,length(desc2)/numBins]);
    [desc3,~] = extractHOGFeatures(im(:,:,3),'CellSize',[cellSize,cellSize],...
        'BlockSize',[blockSize,blockSize],'NumBins', numBins, ...
        'BlockOverlap',[blockLap,blockLap], ...
        'UseSignedOrientation', ORIENTATION_SIGNED); % desc format single
    desc3 = reshape(desc3,[numBins,length(desc3)/numBins]);    
    desc = [desc; desc2; desc3]; % for 3D - 27D
    %desc = [desc, desc2, desc3]; % for 3D - 3D
    
    tmp1 = sum(desc);
    %th = THRESH_HOG * max(tmp1);
    th = 3*THRESH_HOG * max(tmp1); % for 3D - 27D
%    th = THRESH_HOG * max(tmp1); % for 3D - 3D
    desc = desc(:,tmp1 > th);
    desc = desc';
    if i == 4320 % special
        save([outPath_deep,num2str(i),'_problematic.mat'],'desc');
    else
        save([outPath_deep,num2str(i),'.mat'],'desc');
    end 
end

clear all; close all;
