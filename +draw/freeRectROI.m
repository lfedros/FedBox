function [ROI, roiID, corners] = freeRectROI(avgImage, cm, doPlot)

if nargin <2
    cm = 'bone'
end

if nargin <3
    doPlot = 0; 
end

ROI = cell(0,0);
corners = cell(0,0);

% select ROIs

ff = figure; sd = imagesc(avgImage);
caxis([prctile(avgImage(:),1), prctile(avgImage(:),80)]);
axis image;colormap(cm); hold on

fprintf('free hand ROI selection: \n press r to draw an ROI \n double click to confirm ROI \n press e to end \n')
rn=0;
map = zeros(size(avgImage,1), size(avgImage,2));
todo = 'd';
while ~strcmp(todo(end), 'e')
    waitforbuttonpress;
    todo(rn+1) = get(gcf, 'CurrentCharacter');
    switch todo(rn+1)
        case 'r'
            rn =rn+1;
            roi = imrect(gca);
            wait(roi);
            cellbody = createMask(roi,sd);
            %             for ipx = 1: numel(cellbody)
            %
            %                 if cellbody(ipx) && spines(ipx)
            %                     spines(ipx) = 0;
            %                 end
            %
            %             end
            
            ROI{rn} = find(cellbody);     
            
            [i, j] = ind2sub( size(avgImage), ROI{rn});
            
            corners{rn} = [min(i), max(i), min(j), max(j)];
        case 'e'
            
            hold off
            
    end
end

close(ff); 

for iRoi = 1:rn
map(ROI{iRoi}) = iRoi;
roiID{iRoi} = todo(iRoi+1);

end

if doPlot
figure; imagesc(label2rgb(map)); axis image
set (gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [0.015 0.015],'FontSize',15)
end

end