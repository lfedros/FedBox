function info = registerSinglePlane(info, options)

% this function is doing the registration of the multiple planes of a 2p
% dataset

if nargin<2 || ~isfield(options, 'targetFrame')
    options.targetFrame='auto';
end
if nargin<2 || ~isfield(options, 'nFrames4TargetSelection')
    options.nFrames4TargetSelection=100;
end
if nargin<2 || ~isfield(options, 'nFramesPerChunk')
    options.nFramesPerChunk=512;
end
if nargin<2 || ~isfield(options, 'doClipping')
    options.doClipping=true;
end
if nargin<2 || ~isfield(options, 'nParThreads')
    % define this >1 if you want to use parrallel processing
    options.nParThreads=4;
end
if nargin<2 || ~isfield(options, 'fastSave')
    % true if using fast binary saving/loading
    options.fastSave=true;
end
if nargin<2 || ~isfield(options, 'noTiff')
    % set to true if do not want to save tiffs
    options.noTiff=false;
end
if nargin<2 || ~isfield(options, 'iPlane')
    % register all planes by default
    options.iPlane=info.iPlane;
end
if nargin<2 || ~isfield(options, 'quickReg')
    options.quickReg = false;
end
if nargin<2 || ~isfield(options, 'translateAbs')
    options.translateAbs = false;
end

try
    filePath = fullfile(info.folderProcessed, info.basenameRaw);
catch
    info.basenameRaw = sprintf('%s_plane%03d_raw', info.basename2p, options.iPlane);
    filePath = fullfile(info.folderProcessed, info.basenameRaw);
end

nFrames2Skip=[1, 0]; % number of frames to skip in the beginning/end of the stack
% the first 1-2 piezo cycles may be unstable, and the last cycle can be corrupt

fprintf('registering file %s...\n', info.basenameRaw);
[sz, ~, info] = loadArrInfo(filePath);
nFrames = sz(3);

m = memmapfile([filePath, '.bin']);
m.Format =  {'int16', sz, 'frames'};

% cutting the required frames out
indStart=nFrames2Skip(1)+1;
indEnd=nFrames-nFrames2Skip(2);
nFrames=nFrames-sum(nFrames2Skip);
% updating the planeFrame indices after removing the undesired frames
info.planeFrames=info.planeFrames(indStart:indEnd);
info.planeHeaders=info.planeHeaders(indStart:indEnd);
info.meanIntensity = info.meanIntensity(indStart:indEnd);

% this is the Gaussian filter for registration frames
hGauss = fspecial('gaussian', [7 7], 1);

% the following code is adopted (and then adapted) from regTranslations()
if isequal(options.targetFrame, 'auto')
    
    nFrames2Use = min(nFrames, options.nFrames4TargetSelection);
    % select random frames
    % frames2Use = randperm(nFrames-1, nFrames2Use)+1;
    % or evenly spaced frames
    frames2Use = round(linspace(0.5*nFrames/nFrames2Use, (nFrames2Use-0.5)*nFrames/nFrames2Use, nFrames2Use));
%     data = nan([sz(1:2), nFrames2Use]);
%     for iFrame = 1:nFrames2Use
%         data(:,:,iFrame) =  loadMovieFrames(filePath, frames2Use(iFrame), frames2Use(iFrame));
%     end

    data = m.Data.frames(:,:,frames2Use);
    clear m;

%     figure
%     for iIter = 1:10
%         for iFrame = 1:size(data, 3)
%             im = imfilter(double(data(:,:,iFrame)), hGauss);
% %             im = normal_img(im, 1, 100);
%             imagesc(im);
%             colormap gray
%             axis equal tight off
%             drawnow
%         end
%     end

    options.targetFrame = selectTargetDev(1, data, nFrames2Use, floor(nFrames2Use/20), 1, hGauss);
    clear data;
    
    figure
    imagesc(options.targetFrame);
    colormap gray
    h = imrect(gca);
    pos = wait(h);
    set(h, 'Visible', 'off');
    hold on;
%     plot(cumsum([pos(1) pos(3)]), cumsum([pos(2) pos(4)]), '.r')
    plot([pos(1) pos(1) pos(1)+pos(3) pos(1)+pos(3) pos(1)], [pos(2) pos(2)+pos(4) pos(2)+pos(4) pos(2) pos(2)], 'r:');
    yInd = round(pos(2)):round(pos(2)+pos(4));
    xInd = round(pos(1)):round(pos(1)+pos(3));
    drawnow;
    
    %     %first compute a smoothed mean of each frame
    %     meanF = smooth(info.meanIntensity);
    %     %now look in the middle third of the image frames for the minimum
    %     fromFrame = round(length(info.meanIntensity)*1/3);
    %     toFrame = round(length(info.meanIntensity)*2/3);
    %     [~, idx] = min(meanF(fromFrame:toFrame));
    %     minFrame = fromFrame + idx - 1;
    %     frame = loadMovieFrames(filePath, minFrame, minFrame);
    %     %Gaussian filter the target image
    %     options.targetFrame = single(imfilter(frame, hGauss, 'same', 'replicate'));
    
elseif isnumeric(options.targetFrame) && length(options.targetFrame) == 1
    frame = loadMovieFrames(filePath, options.targetFrame, options.targetFrame);
    %Gaussian filter the target image
    options.targetFrame = single(imfilter(frame, hGauss, 'same', 'replicate'));
    
end

if options.nParThreads>1
    try
    tmp = gcp('nocreate');
    if isempty(tmp)
        ppl=parpool(options.nParThreads);
    end
    catch
        % for older vesions of matlab (prior to 2013b)
        tmp = matlabpool('size');
        if ~tmp
            ppl = [];
            matlabpool;
        end
    end
end


nChunks = ceil(nFrames/options.nFramesPerChunk);

fprintf('Calculating registration parameters...\n');
for iChunk = 1:nChunks
    
    nChars = fprintf('chunk %d/%d\n', iChunk, nChunks);
    
    frameStart = indStart + (iChunk-1)*options.nFramesPerChunk;
    frameEnd = min(frameStart + options.nFramesPerChunk - 1, indEnd);
    planeData = loadMovieFrames(filePath, frameStart, frameEnd);
%     planeData = m.Data.frames(:,:,frameStart:frameEnd);
    planeDataCropped = planeData(yInd, xInd, :);
    options.targetFrameCropped = options.targetFrame(yInd, xInd);
    
    if options.nParThreads == 1
        if options.quickReg
            [dx, dy] = img.regTranslationsMKquick(single(planeDataCropped), options.targetFrameCropped, 'noparallel');
        else
            [dx, dy] = img.regTranslationsMK(single(planeDataCropped), options.targetFrameCropped, 'noparallel');
        end
    else
        if options.quickReg
            [dx, dy] = img.regTranslationsMKquick(single(planeDataCropped), options.targetFrameCropped);
        else
            [dx, dy] = img.regTranslationsMK(single(planeDataCropped), options.targetFrameCropped);
        end
    end
    
    if iChunk == 1
        info.dx = dx(:);
        info.dy = dy(:);
    else
        info.dx = [info.dx; dx(:)];
        info.dy = [info.dy; dy(:)];
    end
    
    fprintf(repmat('\b', 1, nChars));
end

% If requested, clip the frames to the maximum fully valid region
[h, w, ~] = size(planeData);
if options.doClipping
    dxMax = max(0, ceil(max(info.dx)));
    dxMin = min(0, floor(min(info.dx)));
    dyMax = max(0, ceil(max(info.dy)));
    dyMin = min(0, floor(min(info.dy)));
    info.validX = (1 + dxMax):(w + dxMin);
    info.validY = (1 + dyMax):(h + dyMin);
else
    info.validX = 1:w;
    info.validY = 1:h;
end

% now do the translations required
fprintf('Applying registration and saving...\n');
for iChunk=1:nChunks
    nChars = fprintf('chunk %d/%d\n', iChunk, nChunks);
    idx = (iChunk-1)*options.nFramesPerChunk+1:...
        min(iChunk*options.nFramesPerChunk, nFrames);
    frameStart = indStart + (iChunk-1)*options.nFramesPerChunk;
    frameEnd = min(frameStart + options.nFramesPerChunk - 1, indEnd);
    planeData = loadMovieFrames(filePath, frameStart, frameEnd);
%     planeData = m.Data.frames(:,:,frameStart:frameEnd);
    if options.translateAbs
        [mov, ~, ~]=img.translateAbs(single(planeData), info.dx(idx), info.dy(idx));
    else
        [mov, ~, ~]=img.translate(single(planeData), info.dx(idx), info.dy(idx));
    end
    if iChunk == 1
        dataPrecision = 'int16';
        info.basenameRegistered = strrep(info.basenameRaw, 'raw', 'registered');
        fid = fopen([fullfile(info.folderProcessed, info.basenameRegistered), '.bin'], 'w');
        try
            fwrite(fid, int16(mov(info.validY, info.validX, :)), dataPrecision);
        catch ex
            fclose(fid);
            rethrow(ex);
        end
    else
        try
            fwrite(fid, int16(mov(info.validY, info.validX, :)), dataPrecision);
        catch ex
            fclose(fid);
            rethrow(ex);
        end
        
    end
    fprintf(repmat('\b', 1, nChars));
    
end
fclose(fid);
info.targetFrame = options.targetFrame;
s.arrSize = [length(info.validY), length(info.validX), length(info.dx)];
s.arrPrecision = dataPrecision;
s.meta = info;
save(fullfile(info.folderProcessed, info.basenameRegistered), '-struct', 's');

fprintf('Finished with plane %d\n\n', options.iPlane);


% close parallel pool, if it was opened here
if options.nParThreads>1 && exist('ppl', 'var')
    if isempty(ppl)
        % for older versions of matlab
        matlabpool close;
    else
        delete(ppl);
    end
    
end


