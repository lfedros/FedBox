function infoOut = redoRegistration(info, options)

% This function wil redo the registration from scratch using dx, dy
% parameters present in the info structure

% Its intended use is to be able to exactly repeat the registration done
% previously (so that we don't need to keep registered arrays after
% extracting traces)

% info - info structure with all the relevant details (see infoPopulate())
% options - an options structure

% Michael Krumin, July 2014

% 2014-07 - MK Created

%% setting the default options

if nargin<2 || ~isfield(options, 'noTiff')
    % do not save the tiff file (not really needed for unregistered data)
    options.noTiff=true;
end

%% start the processing
% get all the relevant tif-file names in that folder

% the absolute paths might have changed, we update them
infoUpd = ppbox.infoPopulate(info.subject, info.expDate, info.exp);

if isfield(infoUpd, 'folder2pLocal')
    localFiles = true;
    allTiffInfo = dir([infoUpd.folder2pLocal, filesep, info.basename2p, '*.tif']);
    if isempty(allTiffInfo)
        localFiles = false;
        fprintf('There were no locally saved tiff files at %s\n', infoUpd.folder2pLocal);
        fprintf('Will now load the files from the server (slower)\n');
        allTiffInfo = dir([infoUpd.folder2p, filesep, info.basename2p, '*.tif']);
    end
else
    localFiles = false;
    allTiffInfo = dir([infoUpd.folder2p, filesep, info.basename2p, '*.tif']);
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
    
    iPlane = info.iPlane;
    
    planeFilename = sprintf(info.basenameRegistered);
    % Creating the '\Processed' sub folder, if it doesn't exist
    if ~exist(infoUpd.folderProcessed, 'dir')
        mkdir(infoUpd.folderProcessed);
    end
    
    fprintf('Extracting and reRegistering plane %d\n', iPlane);
    nFramesAccum=0;
    for iPart=1:nParts
        if localFiles
            filename=fullfile(infoUpd.folder2pLocal, tiffNames{fileIdxSorted{iAcq}(iPart)});
        else
            filename=fullfile(infoUpd.folder2p, tiffNames{fileIdxSorted{iAcq}(iPart)});
        end
        fprintf('Loading part %d/%d\n', iPart, nParts);
        if isempty(nFrames{iPart})
            if localFiles
                nFrames{iPart}=img.nFrames(fullfile(infoUpd.folder2pLocal, tiffNames{fileIdxSorted{iAcq}(iPart)}));
            else
                nFrames{iPart}=img.nFrames(fullfile(infoUpd.folder2p, tiffNames{fileIdxSorted{iAcq}(iPart)}));
            end
        end
        
        % first frame in the current tiff file which belongs to the
        % current plane
        framesIdx = info.planeFrames>nFramesAccum & info.planeFrames<=nFramesAccum+nFrames{iPart};
        frames2load =  info.planeFrames(framesIdx) - nFramesAccum;
        firstFrame=frames2load(1);
        lastFrame=frames2load(end);
        stride = mean(diff(frames2load));
        [data, ~]=img.loadFrames(filename, firstFrame, lastFrame, stride);
        [h, w, nf] = size(data);

        fprintf('Translating part %d/%d\n', iPart, nParts);
        [regData, ~, ~]=img.translate(single(data), info.dx(framesIdx), info.dy(framesIdx));
        
        if iPart==1
            dataPrecision = 'int16';
            fid = fopen([fullfile(infoUpd.folderProcessed, planeFilename), '.bin'], 'w');
        end
        try
            fprintf('Saving part %d/%d\n', iPart, nParts);
            fwrite(fid, int16(regData(info.validY, info.validX, :)), dataPrecision);
        catch ex
            fclose(fid);
            rethrow(ex);
        end
        nFramesAccum=nFramesAccum+nFrames{iPart};
    end
    
    fclose(fid);
    % I'm not sure we need these
    %     s.arrSize = [h w length(info.meanIntensity)];
    %     s.arrPrecision = dataPrecision;
    %     s.meta = info;
    %     save(fullfile(info.folderProcessed, planeFilename), '-struct', 's');
    fprintf('Plane %d complete.\n\n', iPlane);
end
