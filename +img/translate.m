function [movie, validX, validY] = translate(movie, dx, dy, varargin)
% rapidReg Movie frame registration to a target frame using parallelisation
% and array vectorisation for efficiency
%
%   [T, X, Y] = rapidReg(MOVIE, ...) translate each frame of MOVIE by
%   offsets specified frame-wise by DX, DY vectors.
%   Optionally takes, 'clip', meaning clip the output image to keep
%   only pixels that have valid info at all times (i.e. haven't translated
%   outside target). 
%   Also returns, the pixel coordinates of the output movie along each
%   spatial axis, X and Y, which if the image is clipped will be less than
%   the size of the input movie.

% 2013-07 CB created (heavily plagiarised from Mario Dipoppa's code)
% 2013-10 CB completely rewritten to be very efficiently vectorised
% 2014-06 MD replaced abs. with real part to avoid errors when data are
% negative

if isa(movie, 'img.ImageSeries')
  [frames, validX, validY] = img.translate(movie.Frames, dx, dy, varargin{:});
  movie = movie.with(frames, movie.X(validX), movie.Y(validY));
  movie.Info.tags = [movie.Info.tags {'registered'}];
  return
end

[h, w, ~] = size(movie);

%% Translate each frame in phase space
% dy, dy change across 3rd/time dimension
dx = single(reshape(dx, 1, 1, []));
dy = single(reshape(dy, 1, 1, []));
% fy changes along first dimension
fy = reshape(ifftshift((-fix(h/2):ceil(h/2) - 1)/h), [], 1);
% fx changes along second dimension
fx = reshape(ifftshift((-fix(w/2):ceil(w/2) - 1)/w), 1, []);
% fprintf('translating..');
%translation in space domain is rotation in frequency domain
% i.e. need to rotate each coefficient by translation times component's freq
% bsxfun expands singleton dimensions as neccessary to match sizes of its
% array arguments. Same outcome as repmat along those dimension without the
% additional memory requirements (in theory)

% using real part instead of abs. Abs was giving erroneous results for
% images which had negative pixels

movie = real(ifft2(... % fourier inverse
  fft2(movie).*exp(-1j*2*pi*(bsxfun(@plus,... % compute complex fourier coeff then rotate
    bsxfun(@times, dy, fy),...                % y rotation
    bsxfun(@times, dx, fx))))));              % x rotation

%% If requested, clip the frames to the maximum fully valid region
if any(cell2mat(strfind(varargin, 'clip')) == 1)
  dxMax = max(0, ceil(max(dx)));
  dxMin = min(0, floor(min(dx)));
  dyMax = max(0, ceil(max(dy)));
  dyMin = min(0, floor(min(dy)));
  validX = (1 + dxMax):(w + dxMin);
  validY = (1 + dyMax):(h + dyMin);
  movie = movie(validY,validX,:);
else
  validX = 1:w;
  validY = 1:h;
end

% fprintf('.done\n');

end

