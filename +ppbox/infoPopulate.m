function info=infoPopulate(animal, expDate, exp)

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
    dataFolders = { '\\zserver.cortexlab.net\Data\2P\', ...
        '\\zserver.cortexlab.net\Data\Subjects\', '\\zserver4.cortexlab.net\Data\2P\', '\\zserver.cortexlab.net\Data2\Subjects\', ...
        '\\zubjects.cortexlab.net\Subjects\'};
    for k = 1:length(dataFolders)
        folder = fullfile(dataFolders{k}, info.subject, info.expDate, num2str(info.exp));
        if exist(folder, 'dir') ~= 0
            info.folder2p = folder;
            break
        end
    end
    info.basename2p=sprintf('%s_%d_%s_2P', info.expDate, info.exp, info.subject);
    if ~exist(info.folderTL, 'dir') % LFR added on 21.04.18 to handle old datasets sitting on zserver
    info.folderTL=fullfile('\\zserver.cortexlab.net\Data\ExpInfo', info.subject, info.expDate, num2str(info.exp));
    end
    info.basenameTL=sprintf('%s_%d_%s_Timeline', info.expDate, info.exp, info.subject);
% end

% get the number of planes from the Timeline data (piezo trace and frame trigger). 
% If this fails (usually it does), then the tiff header is used, but this
% number also might be wrong if something was wrong with the acquisition (should not happen). 
% !!! Always check your data visually after doing the preliminary analysis !!!

info.nPlanes=ppbox.getNumberOfPlanes(info);

[info.nChannels, colors] = ppbox.getNumberOfChannels(info);
for iCh = 1:info.nChannels
    info.chData(iCh).color = colors{iCh};
end

info.zoomFactor = ppbox.getZoomFactor(info);