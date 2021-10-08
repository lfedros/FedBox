function nPlanes=getNumberOfPlanes(info)

% this function analizes the Timeline data and extracts the actual number
% of planes in the dataset.
% it uses the Piezo Command signal and the Frame Trigger signal
% Currently can be used only with 'Sawtooth' pieo command waveform, which
% goes from low to high values (from shallow to deep layers, and then jumps
% back to shallow)

% 2014-02-24 - MK created
try
    load(fullfile(info.folderTLLocal, [info.basenameTL, '.mat']));
catch
    fprintf('Loading Timeline data from zserver2 (local loading failed)... \n');
    load(fullfile(info.folderTL, [info.basenameTL, '.mat']));
end

nInputs=length(Timeline.hw.inputs);
indFrames=nan;
indPiezo=nan;
for iInput=1:nInputs
    if isequal(Timeline.hw.inputs(iInput).name, 'neuralFrames')
        indFrames=iInput;
    elseif isequal(Timeline.hw.inputs(iInput).name, 'piezoCommand')
        indPiezo=iInput;
    else
    end
end

framesCount=Timeline.rawDAQData(:, indFrames);
piezoCycleStart=[0; -diff(Timeline.rawDAQData(:, indPiezo))];
nShiftSamples=1; % a correction of N time samples, which accounts for late frameCounter increase
piezoCycleStart=[zeros(nShiftSamples, 1); piezoCycleStart(1:end-nShiftSamples)];
th=mean([max(piezoCycleStart), min(piezoCycleStart)]);

piezoCycleStart=piezoCycleStart>0.99*median(piezoCycleStart(piezoCycleStart>th));


framesCycleStart=framesCount(piezoCycleStart);
framesPerCycle=diff(framesCycleStart);

nPlanes=mean(framesPerCycle);

if nPlanes~=round(nPlanes)
    fprintf('nPlanes = %d\n', nPlanes);
    warning('Uncertain about the estimate from the piezo signal, number of planes is not an integer');
    fprintf('Will now get the number of planes from the tiff header...\n');
    try
        allTiffInfo = dir([info.folder2pLocal, filesep, info.basename2p, '*.tif']);
        tiffName = allTiffInfo(1).name;
        filename=fullfile(info.folder2pLocal, tiffName);
        [data, header]=img.loadFrames(filename, 1, 1, 1);
    catch
        fprintf('Getting the tiff from the server (local tiffs do not exist)...\n');
        allTiffInfo = dir([info.folder2p, filesep, info.basename2p, '*.tif']);
        tiffName = allTiffInfo(1).name;
        filename=fullfile(info.folder2p, tiffName);
        [data, header]=img.loadFrames(filename, 1, 1, 1);
    end
    % getting some parameters from the header
    hh=header{1};
    fastZEnable = sscanf(hh(findstr(hh, 'fastZEnable = '):end), 'fastZEnable = %d');
    fastZDiscardFlybackFrames = sscanf(hh(findstr(hh, 'fastZDiscardFlybackFrames = '):end), 'fastZDiscardFlybackFrames = %d');
    stackNumSlices = sscanf(hh(findstr(hh, 'stackNumSlices = '):end), 'stackNumSlices = %d');
    
    if fastZEnable
        nPlanes=stackNumSlices+fastZDiscardFlybackFrames
    else
        nPlanes=1
    end;
    
end


