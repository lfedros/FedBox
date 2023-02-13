function info= infoPopulateTempLFR(animal, expDate, exp, get_img_info)

% This function populates the initial info structure, which is needed to run many
% other 2p analysis functions written by MK.

% Currently the input arguments' format is very strict, may change in the
% (far) future:
% animal - string with the subject (animal) name
% expDate - string with the date (as in an example below)
% exp - experiment number
%
% Example:
% info=infoPopulate('M140108_MK005', '2014-03-05', 1)

% 2014-03 - MK created
% 2015-03 - SS added information on channels and zoom factor
% 2015-06 - MC added .ioo.ucl.ac.uk after zserver and zserver2


if nargin < 4
    get_img_info = 1;
end

if nargin == 1
    info.expRef = animal; % the first input argument is actually expref
    [info.subject, info.expDate, info.exp] = dat.parseExpRef(info.expRef);
    info.expDate = datestr(info.expDate, 'yyyy-mm-dd');
else
    info.subject=animal;
    info.expDate=expDate;
    info.exp=exp;
    info.expRef=dat.constructExpRef(info.subject, info.expDate, info.exp);
end


% try
% these may be buggy
tmp=dat.expFilePath(info.expRef, '2p-raw');
[info.folder2p, info.basename2p, ~]=fileparts(tmp{2});
[info.folder2pLocal, ~, ~] = fileparts(tmp{1});
tmp=dat.expFilePath(info.expRef, 'timeline');
[info.folderTL, info.basenameTL, ~]=fileparts(tmp{2});
[info.folderTLLocal, ~, ~] = fileparts(tmp{1});
ppbox.getTmpFolder;
info.folderProcessed=fullfile(ppbox.getTmpFolder, info.subject, info.expDate, num2str(info.exp));
% after recent paths change we should do this: (MK 2015-06-30)
% catch
% this is a hack while the previous code is buggy
% however, the paths are hard-coded, so be careful
dataFolders = { '\\zaru.cortexlab.net\Subjects\','\\zinu.cortexlab.net\Subjects\', '\\128.40.224.65\Subjects\', '\\znas.cortexlab.net\Subjects\', '\\zserver.cortexlab.net\Data\2P\', ...
    '\\zserver.cortexlab.net\Data\Subjects\', '\\zserver4.cortexlab.net\Data\2P\', '\\zserver.cortexlab.net\Data2\Subjects\', ...
    '\\zubjects.cortexlab.net\Subjects\', '\\zarchive.cortexlab.net\Data\Subjects\'};
for k = 1:length(dataFolders)
    folder = fullfile(dataFolders{k}, info.subject, info.expDate, num2str(info.exp));
    if exist(folder, 'dir') ~= 0
        info.folder2p = folder;
        thisServer = dataFolders{k};
        break
    end
end

info.basename2p=sprintf('%s_%d_%s_2P', info.expDate, info.exp, info.subject);
if ~exist(info.folderTL, 'dir') || ~exist(fullfile(info.folderTL, info.basenameTL), 'file')% LFR added on 21.04.18 to handle old datasets sitting on zserver
    info.folderTL=fullfile('\\zserver.cortexlab.net\Data\ExpInfo', info.subject, info.expDate, num2str(info.exp));
end
if ~exist(info.folderTL, 'dir')
    info.folderTL=fullfile(thisServer, info.subject, info.expDate, num2str(info.exp));
end
info.basenameTL=sprintf('%s_%d_%s_Timeline', info.expDate, info.exp, info.subject);

% end

% get the number of planes from the Timeline data (piezo trace and frame trigger).
% If this fails (usually it does), then the tiff header is used, but this
% number also might be wrong if something was wrong with the acquisition (should not happen).
% !!! Always check your data visually after doing the preliminary analysis !!!

if get_img_info

try
    try
        allTiffInfo = dir([info.folder2pLocal, filesep, info.basename2p, '*.tif']);
        tiffName = allTiffInfo(1).name;
        filename=fullfile(info.folder2pLocal, tiffName);
        [~, header]=loadFramesBuff(filename, 1, 1, 1);
    catch
        fprintf('Getting the tiff from the server (local tiffs do not exist)...\n');
        allTiffInfo = dir([info.folder2p, filesep, info.basename2p, '*.tif']);
        tiffName = allTiffInfo(1).name;
        filename=fullfile(info.folder2p, tiffName);
        [~, header]= loadFramesBuff(filename, 1, 1, 1);
    end
    % getting some parameters from the header
    hh=header{1};
    
    str = hh(strfind(hh, 'scanZoomFactor = '):end);
    ind = strfind(str, 'SI');
    info.zoomFactor = str2double(str(18 : ind(1)-1));
    
    
    try
        verStr = ['SI.VERSION_MAJOR = ',char(39),'2018b',char(39)];
        
        if ~isempty(strfind(hh, verStr)) % For scanimage 2016b, SF
            str = hh(strfind(hh,'channelSave = '):end);
            ind = strfind(str, 'SI');
            ch = str2num(str(15 : ind(1)-1));
            info.nChannels = length(ch);
            
            fastZEnable = sscanf(hh(strfind(hh,'hFastZ.enable = '):end), 'hFastZ.enable = %s');
            fastZEnable = strcmp(fastZEnable,'true');
            fastZDiscardFlybackFrames = sscanf(hh(strfind(hh, 'hFastZ.discardFlybackFrames = '):end), 'hFastZ.discardFlybackFrames = %s');
            fastZDiscardFlybackFrames = strcmp(fastZDiscardFlybackFrames,'true');
            stackNumSlices = sscanf(hh(strfind(hh, 'hStackManager.numSlices = '):end), 'hStackManager.numSlices = %d');
            
            info.nPlanes = 1;
            
            if fastZEnable
                info.nPlanes = stackNumSlices+fastZDiscardFlybackFrames;
            end
            
            str = hh(strfind(hh, 'linesPerFrame = '):end);
            ind = strfind(str, 'SI');
            info.scanLinesPerFrame = str2double(str(17 : ind(1)-1));
            str = hh(strfind(hh, 'pixelsPerLine = '):end);
            ind = strfind(str, 'SI');
            info.scanPixelsPerLine  = str2double(str(17 : ind(1)-1));
            str = hh(strfind(hh, 'scanZoomFactor = '):end);
            ind = strfind(str, 'SI');
            info.scanZoomFactor  = str2double(str(18 : ind(1)-1));
            info.zoomFactor  = str2double(str(18 : ind(1)-1));
            
        else
            
            str = hh(strfind(hh, 'channelsSave = '):end);
            ind = strfind(str, 'scanimage');
            ch = str2num(str(16 : ind(1)-1));
            info.nChannels = length(ch);
            
            fastZEnable = sscanf(hh(findstr(hh, 'fastZEnable = '):end), 'fastZEnable = %d');
            fastZDiscardFlybackFrames = sscanf(hh(findstr(hh, 'fastZDiscardFlybackFrames = '):end), 'fastZDiscardFlybackFrames = %d');
            if isempty(fastZDiscardFlybackFrames)
                fastZDiscardFlybackFrames = 0;
            end
            stackNumSlices = sscanf(hh(findstr(hh, 'stackNumSlices = '):end), 'stackNumSlices = %d');
            
            if fastZEnable
                info.nPlanes=stackNumSlices+fastZDiscardFlybackFrames;
                
            else
                fprintf('The fast scanning was disabled during this acquisition\n');
                info.nPlanes=1;
            end
            
            values = getVarFromHeader(hh, ...
                {'scanFramePeriod', 'scanZoomFactor', 'scanLinesPerFrame', 'scanPixelsPerLine'});
            %     scanFramePeriod = str2double(values{1});
            info.scanZoomFactor = str2double(values{2});
            info.zoomFactor = str2double(values{2});
            info.scanLinesPerFrame = str2double(values{3});
            info.scanPixelsPerLine = str2double(values{4});
            
        end
    catch
        info.nPlanes=1;
        info.nChannels = 1;
    end
    
    %temporary hack
    info.chData(1).color = 'green';
    if info.nChannels ==2
        info.chData(2).color = 'red';
    end
catch
    warning('NO IMAGING DATA FOUND, returning basic exp info')
end
end
end

function values = getVarFromHeader(str, fields)

% str is the header
% fields is a cell array of strings with variable names
% values is a cell array of corresponding values, they will be strings

ff = strsplit(str, {' = ', 'scanimage.SI4.'});
if ~iscell(fields)
    fields = cell(fields);
end
values = cell(size(fields));

for iField = 1:length(fields)
    ind = find(ismember(ff, fields{iField}));
    values{iField} = ff{ind+1};
end
end