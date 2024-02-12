function density_scatter(x, y)

% clear all;
% 
% %% create variables
% 
% x = randn(10000,1)*10;
% y = randn(10000,1)*5;
%% density colored scatterplot

%define density bin size (can be different in x and y)
bin_size_x = 0.5;
bin_size_y = 0.5;

% define edges
Xedges = min(x)-bin_size_x:bin_size_x:max(x)+bin_size_x;
Yedges = min(y)-bin_size_y:bin_size_y:max(y)+bin_size_y;

% 2D histogram plot
[N, ~, ~, binX, binY] = histcounts2(x, y, Xedges, Yedges); 
% % compute center of the bins
% Xbin = Xedges(1:end-1) + bin_size_x/2;
% Ybin = Yedges(1:end-1) + bin_size_y/2;
% figure; imagesc*Xbin, Ybin, N);

% smooth a little
N = imgaussfilt(N, (bin_size_x+bin_size_y)*2);
%how many colors?
n_colors = 100; 
% convert to colormap
N = ceil(n_colors*N/max(N(:))); 
c_map = summer(n_colors);

% look up which color each point should be
c_idx = sub2ind([size(N,1), size(N,2)], binX(:), binY(:));
c_idx = N(c_idx);

% plot
figure; 
scatter(x, y, 1, c_map(c_idx))

end
%%


