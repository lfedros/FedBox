function [ETAmat, ETA, ETAse, window] = magicETA2(t, signal, etaT, periT)
% t are the timestamps of each sample in signal. etaT are the event
% timestasmps you want to trigger the average to, periT is a 2 element
% vector that specifies the window around etaT to be considered

%% one line magic peri-stimulus triggered average, courtesy of CB
nS = size(signal, 2);
if numel(periT) ==2
    window = linspace(periT(1), periT(2), range(periT)*10);
else
    window = periT;
end

bsl = periT(periT <0);
% ETAmat = interp1(t,signal,bsxfun(@plus,window,etaT'));
% [nStim, nRep] = size(etaT);
newT = permute(etaT, [2, 3, 1]);

[x, y] = meshgrid(1:nS, t);
yq = repmat(bsxfun(@plus,window,newT),1,1,1,nS);
xq = repmat(permute(makeVec(1:nS), [2 3 4 1]), [size(newT,1), numel(window), size(newT,3),1]);

ETAmat = interp2(x, y, signal, xq, yq, 'linear', 0);

if ~isempty(bsl)
    bsl = bsl(1);
    yq = repmat(bsxfun(@plus,bsl,newT),1,1,1,nS);
    xq = repmat(permute(makeVec(1:nS), [2 3 4 1]), [size(newT,1), numel(bsl), size(newT,3),1]);
    ETAbsl = prctile(interp2(x, y, signal, xq, yq), 30,2);
    ETAmat = bsxfun(@minus,ETAmat, ETAbsl);

% else
%
%     ETAbsl = ETAmat(:, 1,:,:);
%     ETAmat = bsxfun(@minus,ETAmat, ETAbsl);

end
%% compute median resp and se
ETA = shiftdim(mean(ETAmat,1),1);
ETAse = shiftdim(std(ETAmat,1,1)/sqrt(size(etaT,2)),1); 

% %% plotting
% figure
% shadePlot(window, ETA(:,4,1), ETAse(:,4,1),'b');
end