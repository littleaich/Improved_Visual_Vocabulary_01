function [features] = modifiedBoFColorExtractor(I, colorModel , ...
    blockSize, cform, ratio, alpha) 

% I must be double and in the range [0,1]

Irgb = I;

blueThresh = [0.66,0.68,0.98,1,0.98,1];

if strcmp(colorModel,'rgb')
    Ilab = I;
    tmp = rgb2hsv(I);
elseif strcmp(colorModel, 'hsv')
    Ilab = rgb2hsv(I);    
    tmp = Ilab;
    Ilab = Ilab.^alpha;
elseif strcmp(colorModel, 'lab')
    Ilab = applycform(I, cform);
    tmp = rgb2hsv(I);
elseif strcmp(colorModel, 'mixed')
    f_r = I(:,:,1); f_g = I(:,:,2); f_b = I(:,:,3);
    tmp = rgb2hsv(I);
    f_h = tmp(:,:,1); f_s = tmp(:,:,2); f_v = tmp(:,:,3);
    tmp2 = applycform(I,cform);
    f_l = tmp2(:,:,1); f_a = tmp2(:,:,2); f_bb = tmp2(:,:,3);
    % normalization of Lab
    f_l = (f_l-min(f_l(:)))/(max(f_l(:))-min(f_l(:)));
    f_a = (f_a-min(f_a(:)))/(max(f_a(:))-min(f_a(:)));
    f_bb = (f_bb-min(f_bb(:)))/(max(f_bb(:))-min(f_bb(:)));

    Ilab = cat(3, ratio(1)*f_r + ratio(2)*f_h + ratio(3)*f_l, ...
        ratio(1)*f_g + ratio(2)*f_s + ratio(3)*f_a, ...
        ratio(1)*f_b + ratio(2)*f_v + ratio(3)*f_bb);
end

% Compute the "average" L*a*b* color within 16-by-16 pixel blocks. The
% average value is used as the color portion of the image feature. An
% efficient method to approximate this averaging procedure over
% 16-by-16 pixel blocks is to reduce the size of the image by a factor
% of 16 using IMRESIZE. 
% % formulation -01
% stdMat = stdfilt(Ilab); %%%%%%%%
% stdMat = 1-sigmoid(stdMat); %%%%%%%
% stdMat = mat2gray(stdMat);
% formulation - 02

Ilab = imresize(Ilab, 1/blockSize); % previously blockSize = 16
tmp = imresize(tmp,1/blockSize);
Irgb = imresize(Irgb, 1/blockSize);

% ====== std + range + entropy ========= %
%stdMat = stdfilt(Ilab);
%rangeMat = rangefilt(Ilab);
%entropyMat = entropyfilt(Ilab);
stdMat = stdfilt(Ilab);
rangeMat = rangefilt(Ilab);
entropyMat = entropyfilt(Ilab);
stdMat = mat2gray(stdMat);
rangeMat = mat2gray(rangeMat);
entropyMat = mat2gray(entropyMat);
%Ilab = cat(3,Ilab,stdMat,rangeMat);
Ilab = cat(3,Ilab,stdMat,rangeMat,entropyMat);
% ======================================= %

% % =========== variable combinations ============= %
% Ilab(:,:,4) = bsxfun(@times,Ilab(:,:,1),Ilab(:,:,2)); % H x S
% Ilab(:,:,5) = bsxfun(@times,Ilab(:,:,2),Ilab(:,:,3)); % S x V
% Ilab(:,:,6) = bsxfun(@times,Ilab(:,:,1),Ilab(:,:,3)); % H x V
% Ilab(:,:,7) = bsxfun(@times,Ilab(:,:,4),Ilab(:,:,3)); % H x S x V
% % =============================================== %

% Ilab = imresize(Ilab, 1/blockSize); % previously blockSize = 16
% tmp = imresize(tmp,1/blockSize);
% Note, the average pixel value in a block can also be computed using
% standard block processing or integral images.

% Reshape L*a*b* image into "number of features"-by-3 matrix.
[Mr,Nr,~] = size(Ilab);    
features = reshape(Ilab, Mr*Nr, []);
%features = features - min(features(:));
tmp = reshape(tmp,Mr*Nr,[]);
% Remove Blue Background Pixels
pos = []; k = 0;
for i = 1:size(features,1)
    if tmp(i,1)>=blueThresh(1) && tmp(i,1)<=blueThresh(2) && ...
            tmp(i,2)>=blueThresh(3) && tmp(i,2)<=blueThresh(4) && ...
            tmp(i,3)>=blueThresh(5) && tmp(i,3)<=blueThresh(6) 
        k = k+1; pos(k,1) = i;
    end
end

features(pos,:) = [];

end

