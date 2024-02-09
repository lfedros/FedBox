function [rf, envelope, envelopeEdges] = quantileReg(X,Y, quantiles)

X = X(:); Y = Y(:);

nQuant = numel(quantiles);

quantileEdges = prctile(X, quantiles);

[~,~,idx] = histcounts(X, quantileEdges); 


for iQ = 1:nQuant-1
    
    chosenY = Y(idx == iQ);
    chosenX = X(idx == iQ);
    
    envelope(iQ) = mean(chosenY(chosenY < prctile(chosenY, 50)));
    
    envelopeEdges(iQ)= mean(chosenX);

end


rf = robustfit(envelopeEdges, envelope);
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