% ======================================================================= %
% Name: extractSiftFeatures.m
% Author: Shubhra Aich
% Affiliation: M.Eng.(Ongoing), Chonnam National University
% E-mail: s.aich.72@gmail.com
% Description: This is the first file to extract SIFT features from 
% Oxford-102 flower dataset. It extracts the SIFT descriptors 
% from the foregound of the images in regular grid spacing. Descriptor
% extraction is performed using vlfeat library downloaded from this link 
% http://www.vlfeat.org/. The file hierarchy for SIFT features extraction 
% and testing using multiple kernel learning 
% (Oxford-102 dataset) is listed as follows: 
% (1) extractSiftFeatures.m, (2) makeSiftDesMat.m, 
% (3) makeSiftVisualCodebook_LD.m, (4) makeSiftFeaMat.m, 
% (5) makeSiftSimMat.m, (6) classifyMKL_Sift.m
% N.B. If the command "resourcedefaultpath" shows error, just restart
% MATLAB.
% ======================================================================= %

clear all; close all; clc;
restoredefaultpath;
echo off;

%MAX_PIX_VAL = 510;
image_version = 'Images_Min_500';
%image_version = 'Images_Min_500_Div';
% image_version = 'Images_Org_Min_500';
if strcmp(image_version,'Images_Min_500_Div')
    image_version_inside = 'Images_Min_500';
end

MAXMIN_BG = 10;
MINMAX_BG = 245;
THRESH_DES_NORM = 200;
%THRESH_DES_NORM = 0;
featName = 'sift';
radius = 5; % for internal sift
spacing = 5; % both internal and boundary sift

if strcmp(image_version,'Images_Min_500_Div')
    imgPath = ['../../Databases/Oxford/',image_version_inside,'/'];
    imgPath_div = ['../../Databases/Oxford/',image_version,'/'];
else
    imgPath = ['../../Databases/Oxford/',image_version,'/'];
end
outPath = ['../../Databases/Oxford/Features/',image_version,'/'];
%imPref = 'adj_seg_image_';
imPref = '';
addpath('../../Databases/Oxford/');

run('vlfeat-0.9.20/toolbox/vl_setup.m');

addpath(imgPath);
featName = [featName,'_rad_',num2str(radius),'_spc_',num2str(spacing)];
outPath_deep = [outPath,featName,'/'];
mkdir(outPath_deep);

numImg = length(dir(imgPath))-2;

%kernelGauss = fspecial('gaussian', radius); % gaussian averaging
% kernelDisk = fspecial('disk', (spacing-1)/2); % circular averaging
for i = 1:numImg
    
    disp(['Processing Image = ', num2str(i)]);
%     if i<10
%         addZeros = '000';
%     elseif i>=10 && i<100
%         addZeros = '00';
%     elseif i>=100 && i<1000
%         addZeros = '0';
%     else
%         addZeros = '';
%     end
    addZeros = '';
    im_rgb = imread([imPref,addZeros,num2str(i),'.jpg']);
    im = im2double(rgb2gray(im_rgb));
    % grid sift processing
    x = 1:spacing:size(im,1);
    y = 1:spacing:size(im,2);
    [X,Y] = meshgrid(x,y);
    X = X(:)'; Y = Y(:)';    
    count = 0;
    countVal = 0;
    for j = 1:length(X)
        if im_rgb(X(j),Y(j),1) <= MAXMIN_BG && ...
                im_rgb(X(j),Y(j),2) <= MAXMIN_BG && ...
                im_rgb(X(j),Y(j),3) >= MINMAX_BG
            count = count+1;
            pos_bg(count) = j;
        end
    end
  
    X(pos_bg) = []; Y(pos_bg) = [];
    R = radius*ones(1,length(X));
    fc = [Y; X; R; zeros(1,length(X))];

    [~,desc] = vl_sift(single(im_rgb(:,:,1)),'frames',fc,'orientations'); 
    [~,desc2] = vl_sift(single(im_rgb(:,:,2)),'frames',fc,'orientations'); 
    [~,desc3] = vl_sift(single(im_rgb(:,:,3)),'frames',fc,'orientations'); 
    desc = single(desc');
    desc2 = single(desc2');
    desc3 = single(desc3');
    
    desc = [desc; desc2; desc3];
    
    
    clear pos_bg;
    tmp = sqrt(sum(desc.^2,2));
    desc = desc(tmp > THRESH_DES_NORM,:);
    if i == 4320 % special
        save([outPath_deep,num2str(i),'_problematic.mat'],'desc');
    else
        save([outPath_deep,num2str(i),'.mat'],'desc');
    end
end

clear all; close all; 
