function [jointFit, lowX, lowY, madX, madY] = jointDistReg(X,Y, numN, pLow, maxNp, minNp)

if nargin <3
    numN = 1000;
end
if nargin < 4
    pLow = 50;
end

if nargin<5
    maxNp =100; %95
end

X = X(:); Y = Y(:);

if nargin <6
minN = max(prctile(cat(1,X,Y), 5), 0);
% minN =prctile(X,minNp);
else
minN = prctile(cat(1,X,Y), 0);

end
maxN=prctile(cat(1,X,Y),maxNp);

discrX=round(numN*(X-minN)/(maxN-minN));
discrY=round(numN*(Y-minN)/(maxN-minN));

%discrX are the discretized values of X between minN and
% maxN, with numN elements

for iN=1:numN
    lowY(iN)= prctile(Y(discrX==iN),pLow);
    madY(iN) = mad(Y(discrX==iN));

    lowX(iN)= prctile(X(discrY==iN),pLow);
    madX(iN) = mad(X(discrY==iN));
end

% fitY=(1:numN).*(maxN-minN)/numN+minN;
% 
% fitY(isnan(lowY)) = [];

% lowY(isnan(lowY)) = [];
% lowX(isnan(lowX)) = [];

[jointFit, stats] = robustfit(lowX(~isnan(lowY) & ~isnan(lowX)),lowY((~isnan(lowY) & ~isnan(lowX))));

% nQuant = numel(quantiles);
% 
% quantileEdges = prctile(X, quantiles);
% 
% [~,~,idx] = histcounts(X, quantileEdges); 
% 
% 
% for iQ = 1:nQuant-1
%     
%     chosenY = Y(idx == iQ);
%     chosenX = Y(idx == iQ);
%     
%     envelope(iQ) = mean(chosenY(chosenY < prctile(chosenY, 25)));
%     
%     envelopeEdges(iQ)= mean(chosenX);
% 
% end
% 
% 
% rf = robustfit(envelopeEdges, envelope);
% % 

end