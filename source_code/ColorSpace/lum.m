function l=lum(img)
%
%       l=lum(img)
%
%       This function calculates the luminance
%
%
%       input:
%           img: an RGB image
%
%       output:
%           l: luminance as XYZ color 
%
%     Copyright (C) 2011  Francesco Banterle
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

col = size(img,3);

switch col
    case 1
        l = img;
    case 3
        l=0.213*img(:,:,1)+0.715*img(:,:,2)+0.072*img(:,:,3);
    otherwise
         error('The input image is not an RGB or luminance image!');
end

end