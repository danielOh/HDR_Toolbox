function [imgOut, Lt] = CalibrateHDR(img, percentage, bRobust)
%
%       [imgOut, Lt] = CalibrateHDR(img, percentage, bRobust)
%
%
%        Input:
%           -img: input HDR image
%           -percentage: is the percentage of pixels for light threshold
%           -bRobust: if it sets to 1 robust statistics are used for
%           computing max and min
%
%        Output:
%           -imgOut: automatically calibrated HDR image
%           -Lt: threshold for light sources
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

if(~exist('bRobust'))
    bRobust = 0;
end

L = lum(img);
Lavg = mean(mean(log10(L+1e-5)));
    
if(bRobust)
	Lmin = MaxQuart(L,0.001);
	Lmax = MaxQuart(L,0.999);
else
	Lmin = min(L(L>0.0));
	Lmax = max(L(:));
end
    
k = (Lavg-log10(Lmin))/(log10(Lmax)-log10(Lmin));
f = 1e5*k/Lmax;
Lt = Lmin+(percentage+(1.0-percentage)*(1.0-k))*(Lmax-Lmin);
    
imgOut = img*f;
end