function [h cax] = imagescNaN(x,y,a,cm,nanclr,  cax)
% IMAGESC with NaNs assigning a specific color to NaNs

if nargin <6
%# find minimum and maximum
amin=min(a(:));
amax=max(a(:));
else
amin = cax(1);
amax = cax(2);
end
%# size of colormap
n = size(cm,1);
%# color step
dmap=(amax-amin)/n;

%# standard imagesc
him = imagesc(x, y, a);
%# add nan color to colormap
colormap([nanclr; cm]);
%# changing color limits

caxis([amin-dmap amax]);
cax = [amin-dmap amax];

if nargout > 0
    h = him;
end