function imgOut = BanterleTMO(img)
%
%
%        imgOut = BanterleTMO(img)
%
%
%       Input:
%           -img: an HDR image
%
%       Output:
%           -imgOut: the tone mapped image using the HybridTMO
% 
%       This TMO is an hybrid operator which merges different
%       Tone Mapping Operators: DragoTMO and ReinhardTMO
%
%     Copyright (C) 2013  Francesco Banterle
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

if(~exist('bFast'))
    bFast = 0;
end

%Segmentation
segments = CreateSegments(img);

%TMO look-up table for determing the best
%TMO depending on the luminance zone. These
%values were extracted from a psychophysical
%experiment.
% 0 ---> Drago et al. 2003
% 1 ---> Reinhard et al. 2002
LumZone     = [-2, -1, 0, 1, 2, 3, 4];
TMOForZone =  [ 0,  0, 1, 0, 1, 0, 0];

%Tone mapping
img_dra_tmo = DragoTMO(img, 100, 0.85);
img_rei_tmo = ReinhardBilTMO(img);

%mask
mask = zeros(size(img(:,:,1)));

for i=1:length(LumZone)
    mask(segments==LumZone(i)) = TMOForZone(i);
end

%Check if only DragoTMO is used
indx0 = find(mask==1);
if(isempty(indx0))
    imgOut = img_dra_tmo;
    disp('The HybridTMO is using only the Drago TMO');
end

%Check if only ReinhardBilTMO is used
indx1 = find(mask==0);
if(isempty(indx1))
    imgOut = img_rei_tmo;
    disp('The HybridTMO is using Reinhard TMO');
end

if(~isempty(indx0)&&~isempty(indx1))%pyramid blending in gamma space
    imgA   = ClampImg(img_rei_tmo.^(1.0/2.2),0,1);
    imgB   = ClampImg(img_dra_tmo.^(1.0/2.2),0,1);
    imgOut = pyrBlend(imgA,imgB,mask).^2.2;
end

end