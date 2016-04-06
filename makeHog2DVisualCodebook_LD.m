% ======================================================================= %
% Name: makeHog2DVisualCodebook_LD.m
% Author: Shubhra Aich
% Affiliation: M.Eng.(Ongoing), Chonnam National University
% E-mail: s.aich.72@gmail.com
% Description: This is the third file to extract HOG features from 
% Oxford-102 flower dataset. It calculates the visual
% codebook from the HOG descriptor set using "vlfeat" library downloaded 
% from the link http://www.vlfeat.org/. For codebook calculation in this 
% large dimension, "Approximate Nearest Neighbor" (ANN) option of vlfeat 
% library is used. The file hierarchy for HOG features extraction and 
% testing using multiple kernel learning (Oxford-102 dataset) 
% is listed as follows: (1) extractHog2DFeatures.m, (2) makeHog2DDesMat.m, 
% (3) makeHog2DVisualCodebook_LD.m, (4) makeHog2DFeaMat.m, 
% (5) makeHog2DSimMat.m, (6) classifyMKL_Hog2D.m
% N.B. If the command "resourcedefaultpath" shows error, just restart
% MATLAB.
% ======================================================================= %

clear all; close all; clc;
restoredefaultpath;
echo on;

%image_version = 'Images_Segmented_Adjusted';
image_version = 'Images_Min_500';
%image_version = 'Images_Min_500_Extended';
featName = 'hog2D';
cellSize = 8; % default
blockSize = 2; % default
numBins = 9; % default
blockLap = 0;
%blockLap = ceil(blockSize/2);
K = 1500;

featName = [featName,'_',num2str(cellSize),'x',num2str(cellSize),'_', ...
    num2str(blockSize),'x',num2str(blockSize),'_bin_',num2str(numBins)];

dbPath = ['../../Databases/Oxford/Features/',image_version,'/'];

run('vlfeat-0.9.20/toolbox/vl_setup.m');

load([dbPath,'TrainDesc_',featName,'.mat']);
trainDesc = trainDesc';

tic; 
[VC,~] = vl_kmeans(trainDesc,K,'verbose','distance','l2',...
    'algorithm','ann'); 
toc;
VC = VC';

save([dbPath,'VC_',num2str(K),'_',featName,'.mat'],'VC');

clear all; close all;

echo off;
