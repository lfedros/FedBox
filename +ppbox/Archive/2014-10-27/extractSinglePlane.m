function info = extractSinglePlane(info, options)

% This function is dividing the (BScope) dataset to sub-datasets.
% Each new sub-dataset contains a single plane
% info - info structure with all the relevant details (see infoPopulate())
% options - an options structure

% Michael Krumin, February 2014

% 2014-02 - MK Created (getPlanesFromRaw)
% 2014-06 - MK modified for low mem (or large arrays) use (extractSinglePlane)

%% setting the default options

if nargin<2 || ~isfield(options, 'noTiff')
    % do not save the tiff file (not really needed for unregistered data)
    options.noTiff=true;
end

if nargin<2 || ~isfield(options, 'fastSave')
    % set to true if you want to use the fast array saving instead of
    % matlab save() function. Will be much faster, but the data is not
    % compressed (you loose approx 20-25% of space for typical BScope data)
    % make sure you have saveArr and loadArr (writeen by Chris) if you use
    % this fastSave option
    options.fastSave=true;
end

if nargin<2 || ~isfield(options, 'iPlane')
    % by default extract the first plane
    options.iPlane=1;
end


%% start the processing
% get all the relevant tif-file names in that folder

if isfield(info, 'folder2pLocal')
    localFiles = true;
    allTiffInfo = dir([info.folder2pLocal, filesep, info.basename2p, '*.tif']);
    if isempty(allTiffInfo)
        localFiles = false;
        fprintf('There were no locally saved tiff files at %s\n', info.folder2pLocal);
        fprintf('Will now load the files from the server (slower)\n');
        allTiffInfo = dir([info.folder2p, filesep, info.basename2p, '*.tif']);
    end
else
    localFiles = false;
    allTiffInfo = dir([info.folder2p, filesep, info.basename2p, '*.tif']);
end

nFiles = length(allTiffInfo);
tiffNames = cell(nFiles, 1);
acqNumber = nan(nFiles, 1);
partNumber = nan(nFiles, 1);
for iFile = 1:nFiles
    tiffNames{iFile} = allTiffInfo(iFile).name;
    acqNumber(iFile) = str2num(tiffNames{iFile}(end-10:end-8));
    partNumber(iFile) = str2num(tiffNames{iFile}(end-6:end-4));
end

acquisitions=unique(acqNumber);
nAcqs=length(acquisitions);

if nAcqs>1
    warning('There is more than one acquisition in this folder, something might be wrong');
end

for iAcq=1:nAcqs
    [partsSorted{iAcq} fileIdxSorted{iAcq}]=sort(partNumber(acqNumber==acquisitions(iAcq)));
end

for iAcq=1:nAcqs
    
    nParts=length(fileIdxSorted{iAcq});
    nPlanes=info.nPlanes;
    nFrames=cell(nParts, 1);
    
    iPlane = options.iPlane;
    info.iPlane = iPlane;
    
    if nAcqs>1
        planeFilename = sprintf('%s_acq%03d_plane%03d_raw', info.basename2p, iAcq, iPlane);
    else
        planeFilename = sprintf('%s_plane%03d_raw', info.basename2p, iPlane);
    end
    % Creating the '\Processed' sub folder, if it doesn't exist
    if ~exist(info.folderProcessed, 'dir')
        mkdir(info.folderProcessed);
    end
    
    
    fprintf('Extracting plane %d/%d\n', iPlane, nPlanes);
    nFramesAccum=0;
    for iPart=1:nParts
        if localFiles
            filename=fullfile(info.folder2pLocal, tiffNames{fileIdxSorted{iAcq}(iPart)});
        else
            filename=fullfile(info.folder2p, tiffNames{fileIdxSorted{iAcq}(iPart)});
        end
        fprintf('Loading part %d/%d\n', iPart, nParts);
        if isempty(nFrames{iPart})
            if localFiles
                nFrames{iPart}=img.nFrames(fullfile(info.folder2pLocal, tiffNames{fileIdxSorted{iAcq}(iPart)}));
            else
                nFrames{iPart}=img.nFrames(fullfile(info.folder2p, tiffNames{fileIdxSorted{iAcq}(iPart)}));
            end
        end
        
        % first frame in the current tiff file which belongs to the
        % current plane
        firstFrame=mod(iPlane-mod(nFramesAccum, nPlanes), nPlanes);
        if firstFrame==0
            firstFrame=nPlanes;
        end
        frames2load=(firstFrame:nPlanes:nFrames{iPart})';
        lastFrame=frames2load(end);
        [data, headers]=img.loadFrames(filename, firstFrame, lastFrame, nPlanes);
        [h, w, nf] = size(data);
        if iPart==1
            dataPrecision = class(data);
            info.planeFrames=frames2load;
            info.planeHeaders=headers;
            info.meanIntensity=[mean(reshape(data, h*w, nf))]';
            fid = fopen([fullfile(info.folderProcessed, planeFilename), '.bin'], 'w');
            try
                fwrite(fid, data, dataPrecision);
            catch ex
                fclose(fid);
                rethrow(ex);
            end
        else
            info.planeFrames=cat(1, info.planeFrames, frames2load+nFramesAccum);
            info.planeHeaders=[info.planeHeaders, headers];
            info.meanIntensity=cat(1, info.meanIntensity, [mean(reshape(data, h*w, nf))]');
            try
                fwrite(fid, data, dataPrecision);
            catch ex
                fclose(fid);
                rethrow(ex);
            end
        end
        nFramesAccum=nFramesAccum+nFrames{iPart};
    end
    fclose(fid);
    info.basenameRaw = planeFilename;
    s.arrSize = [h w length(info.meanIntensity)];
    s.arrPrecision = dataPrecision;
    s.meta = info;
    save(fullfile(info.folderProcessed, planeFilename), '-struct', 's');
    fprintf('Plane %d complete.\n\n', iPlane);
end
