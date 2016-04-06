% ======================================================================= %
% Name: extractMsdSiftFeatures.m
% Author: Shubhra Aich
% Affiliation: M.Eng.(Ongoing), Chonnam National University
% E-mail: s.aich.72@gmail.com
% Description: This is the first file to extract MSD-SIFT features from 
% Oxford-102 flower dataset. It extracts MSD-SIFT descriptors 
% from the foregound of the images in regular grid spacing. Descriptor
% extraction is performed using vlfeat library downloaded from this link 
% http://www.vlfeat.org/. The file hierarchy for MSD-SIFT features 
% extraction and testing using multiple kernel learning 
% (Oxford-102 dataset) is listed as follows: 
% (1) extractMsdSiftFeatures.m, (2) makeMsdSiftDesMat.m, 
% (3) makeMsdSiftVisualCodebook_LD.m, (4) makeMsdSiftFeaMat.m, 
% (5) makeMsdSiftSimMat.m, (6) classifyMKL_MsdSift.m
% N.B. If the command "resourcedefaultpath" shows error, just restart
% MATLAB.
% ======================================================================= %

clear all; close all; clc; 
restoredefaultpath;
echo off;

image_version = 'Images_Min_500';
%image_version = 'Images_Org_Min_500';
MAXMIN_BG = 10;
MINMAX_BG = 245;
THRESH_DES_NORM = 200;
featName = 'msdsift';
stepSize = 5; 
scales = [4,6,8,10];
mag = 6;

imgPath = ['../../Databases/Oxford/',image_version,'/'];
outPath = ['../../Databases/Oxford/Features/',image_version,'/'];
%imPref = 'adj_seg_image_';
imPref = '';
addpath('../../Databases/Oxford/');

run('vlfeat-0.9.20/toolbox/vl_setup.m');

addpath(imgPath);
featName = [featName,'_step_',num2str(stepSize),'_mag_',num2str(mag)];
outPath_deep = [outPath,featName,'/'];
mkdir(outPath_deep);

%th = 3*THRESH_DES_NORM;
th = THRESH_DES_NORM;
numImg = length(dir(imgPath))-2;

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
    im_rgb_single = im2single(im_rgb);
%    im_hsv = rgb2hsv(im_rgb_single);
    %im = im2single(rgb2gray(im_rgb));
    % grid sift processing
%     [frames,desc] = vl_phow(im,'Sizes',scales,'Step',stepSize, ...
%         'Magnif',mag,'FloatDescriptors',true);
    [frames,desc] = vl_phow(im_rgb_single(:,:,1),'Sizes',scales, ...
        'Step',stepSize,'Magnif',mag,'FloatDescriptors',true);
    [~,desc2] = vl_phow(im_rgb_single(:,:,2),'Sizes',scales, ...
        'Step',stepSize,'Magnif',mag,'FloatDescriptors',true);
    [~,desc3] = vl_phow(im_rgb_single(:,:,3),'Sizes',scales, ...
        'Step',stepSize,'Magnif',mag,'FloatDescriptors',true);    
%     [~,desc4] = vl_phow(im_hsv(:,:,1),'Sizes',scales, ...
%         'Step',stepSize,'Magnif',mag,'FloatDescriptors',true);
%     [~,desc5] = vl_phow(im_hsv(:,:,2),'Sizes',scales, ...
%         'Step',stepSize,'Magnif',mag,'FloatDescriptors',true);
%     [~,desc6] = vl_phow(im_hsv(:,:,3),'Sizes',scales, ...
%         'Step',stepSize,'Magnif',mag,'FloatDescriptors',true);        
    Y = frames(1,:); X = frames(2,:);
    
    count = 0;
    for j = 1:length(X)
        if im_rgb(X(j),Y(j),1) <= MAXMIN_BG && ...
                im_rgb(X(j),Y(j),2) <= MAXMIN_BG && ...
                im_rgb(X(j),Y(j),3) >= MINMAX_BG
            count = count+1;
            pos_bg(count) = j;
        end
    end
    if exist('pos_bg','var')
        %desc(:,pos_bg) = [];
        desc(:,pos_bg) = [];
        desc2(:,pos_bg) = [];
        desc3(:,pos_bg) = [];
%         desc4(:,pos_bg) = [];
%         desc5(:,pos_bg) = [];
%         desc6(:,pos_bg) = [];        
    end
    %desc = [desc; desc2; desc3; desc4; desc5; desc6];
    desc = [desc; desc2; desc3];
    desc = desc';
    clear pos_bg desc2 desc3; 
    tmp = sqrt(sum(desc.^2,2));
    desc = desc(tmp > th,:);
    if i == 4320 % special
        save([outPath_deep,num2str(i),'_problematic.mat'],'desc');
    else
        save([outPath_deep,num2str(i),'.mat'],'desc');
    end    
end

clear all; close all;
