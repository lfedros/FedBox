function [xy,bins] = xy_projection(data, opts)
% detailed help goes here

sigma = opts.smooth_sigma; % bins
bins = opts.lmin:opts.bin_size:opts.lmax; % microns

% calculate xy density and marginals
[xy, ~] = hist3(double([data(:,2),data(:,1)]), {bins, bins});  
xy = imgaussfilt(xy, sigma);
xy = xy/sum(xy(:));

end