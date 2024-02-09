function [envelope, envelopeEdges, lm] = intervalReg(X,Y, edges, med_flag)

if nargin <4
    med_flag = 0;
end

X = X(:); Y = Y(:);

nQuant = numel(edges);

[~,~,idx] = histcounts(X, edges);


for iQ = 1:nQuant-1

    chosenY = Y(idx == iQ);
    chosenX = X(idx == iQ);

    if isempty(chosenY)
        envelope(iQ) = NaN;
        envelope_std(iQ) = NaN;
        if med_flag

            envelopeEdges(iQ)= nanmedian(chosenX);
        else
            envelopeEdges(iQ)= nanmean(chosenX);

        end

    else
        if med_flag
            envelope(iQ) = nanmedian(chosenY);
            envelope_std(iQ) = nanstd(chosenY)/sqrt(numel(chosenY));
            envelopeEdges(iQ)= nanmedian(chosenX);
        else
            envelope(iQ) = nanmean(chosenY);
            envelope_std(iQ) = nanstd(chosenY)/sqrt(numel(chosenY));
            envelopeEdges(iQ)= nanmean(chosenX);
        end
    end

end

lm = fitlm(envelopeEdges, envelope);

% rf = robustfit(envelopeEdges, envelope);
%
% minN=prctile(neuropRoiTrace(iCell,:),minNp);
%     maxN=prctile(neuropRoiTrace(iCell,:),maxNp);
%     discrNeuro=round(numN*(neuropRoiTrace(iCell,:)-minN)/(maxN-minN));
%     %discrNeuro are the discretized values of neuropil between minN and
%     % maxN, with numN elements
%
%     for iN=1:numN
%         lowCell(iCell,iN)= prctile(cellRoiTrace(iCell,discrNeuro==iN),pCell);
%     end
%
%     fitNeuro(iCell,:)=(1:numN).*(maxN-minN)/numN+minN;
%     corrFactor(iCell,:) = robustfit(fitNeuro(iCell,:),lowCell(iCell,:));

end