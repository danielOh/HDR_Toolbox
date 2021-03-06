function imgOut = MertensTMO( img, directory, format, wE, wS, wC )
%
%
%        imgOut = MertensTMO( img, format, wE, wS, wC )
%
%
%        Input:
%           -img: input HDR image
%           -directory: the directory where to fetch the exposure stack in
%           the case img=[]
%           -format: the format of LDR images ('bmp', 'jpg', etc) in case
%                    img=[] and the tone mapped images is built from a sequence of
%                    images in the current directory
%           -wE: the weight for the well exposedness in [0,1]. Well exposed
%                pixels are taken more into account if the wE is near 1
%                otherwise they are not taken into account.
%           -wS: the weight for the saturation in [0,1]. Saturated
%                pixels are taken more into account if the wS is near 1
%                otherwise they are not taken into account.
%           -wC: the weight for the contrast in [0,1]. Strong edgese are 
%                taken more into account if the wE is near 1
%                otherwise they are not taken into account.
%
%        Output:
%           -imgOut: tone mapped image
%
%        Note: Gamma correction is not needed because it works on gamma
%        corrected images.
% 
%     Copyright (C) 2010 Francesco Banterle
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

%default parameters if they are missing
if(~exist('wE'))
    wE = 1.0;
end

if(~exist('wS'))
    wS = 1.0;
end

if(~exist('wC'))
    wC = 1.0;
end

%stack generation
stack=[];

if(~isempty(img))
    %Convert the HDR image into a stack
    [stack,stack_exposure] = GenerateExposureBracketing(img,1);
else
    %load images from the current directory
    images=dir([directory,'/','*.',format]);
    n = length(images);
    for i=1:n
        stack(:,:,:,i) = single(imread([directory,'/',images(i).name]))/255.0;
    end
end

%number of images in the stack
[r,c,col,n] = size(stack);

%Computation of weights for each image
total  = zeros(r,c);
weight = ones(r,c,n);
for i=1:n
    %calculation of the weights
    if(wE>0.0)
        weightE = MertensWellExposedness(stack(:,:,:,i));
        weight(:,:,i) = weightE.^wE;
    end
    
    if(wC>0.0)
        L = mean(stack(:,:,:,i),3);  
        weightC = MertensContrast(L);
        weight(:,:,i) = weight(:,:,i) .* (weightC.^wC);
    end

    if(wS>0.0)
        weightS = MertensSaturation(stack(:,:,:,i));
        weight(:,:,i) = weight(:,:,i) .* (weightS.^wS);
    end
    
    weight(:,:,i) = weight(:,:,i) + 1e-12;
    
    total = total + weight(:,:,i);
end

%Normalization of weights
for i=1:n
    weight(:,:,i) = RemoveSpecials(weight(:,:,i)./total);
end

%empty pyramid
tf=[];
for i=1:n
    %Laplacian pyramid: image
    pyrImg = pyrImg3(stack(:,:,:,i),@pyrLapGen);
    %Gaussian pyramid: weight   
    pyrW   = pyrGaussGen(weight(:,:,i));

    %Multiplication image times weights
    tmpVal = pyrLstS2OP(pyrImg,pyrW,@pyrMul);
   
    if(i==1)
        tf = tmpVal;
    else
        %accumulation
        tf = pyrLst2OP(tf,tmpVal,@pyrAdd);    
    end
end

%Evaluation of Laplacian/Gaussian Pyramids
imgOut=zeros(r,c,col);
for i=1:col
    imgOut(:,:,i) = pyrVal(tf(i));
end

%Clamping
imgOut = ClampImg(imgOut,0.0,1.0);

disp('This algorithm outputs images with gamma encoding. Inverse gamma is not required to be applied!');

end