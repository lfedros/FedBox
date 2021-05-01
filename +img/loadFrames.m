function [frames, headers] = loadFrames(tiff, firstIdx, lastIdx, stride, progress)
%loadFrames Loads the frames of a Tiff file into an array (Y,X,T)
%   MOVIE = loadFrames(TIFF, [FIRST], [LAST], [STRIDE], [PROGRESS]) loads
%   frames from the Tiff file specified by TIFF, which should be a filename
%   or an already open Tiff object. Optionallly FIRST, LAST and STRIDE
%   specify the range of frame indices to load, and PROGRESS, a handle to a
%   MATLAB progress dialog.

initChars = overfprintf(0, 'Loading TIFF frame ');
warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');

warningsBackOn = onCleanup(...
  @() warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning'));

if nargin <1                    % added by LFR on 4/10/16
    [tiff, path] = uigetfile;   % added by LFR on 4/10/16
     cd(path);                  % added by LFR on 4/10/16
end

if ischar(tiff)
  tiff = Tiff(tiff, 'r');
  closeTiff = onCleanup(@() close(tiff));
end

if nargin < 2
  firstIdx = 1;
end

if nargin < 3
  lastIdx = img.nFrames(tiff);
end

if nargin < 4
  stride = 1;
end

if nargout > 1
  loadHeaders = true;
else
  loadHeaders = false;
end

w = tiff.getTag('ImageWidth');
h = tiff.getTag('ImageLength');
dataClass = class(read(tiff));
nFrames = ceil((lastIdx - firstIdx + 1)/stride);
frames = zeros(h, w, nFrames, dataClass);
if loadHeaders
  headers = cell(1, nFrames);
end

nMsgChars = 0;
setDirectory(tiff, firstIdx);
for t = 1:nFrames
  if mod(t, 100) == 0
    nMsgChars = overfprintf(nMsgChars, '%i/%i', t, nFrames);
  end
  
  if nargin > 4
    waitbar(t/nframes, progress, sprintf('Loading frame %i/%i...', t, nFrames));
  end
  
  frames(:,:,t) = read(tiff);
  
  if loadHeaders
    headers{t} = getTag(tiff, 'ImageDescription');
  end
  
  if t < nFrames
    for i = 1:stride
      nextDirectory(tiff);
    end
  end
end
overfprintf(initChars + nMsgChars, '');

end

