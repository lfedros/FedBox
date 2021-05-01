function mutInfo = mutualInformation(X, Y)
%calculates the mutual information between vectors X and Y

X = X(:); Y = Y(:);

n = numel(X); 

XY = cat(2,X,Y);

low = min(XY(:));
high = max(XY(:));
nBins = round(1+log2(numel(X)))+10;
edges = linspace(low, high, nBins);


pXY = histcounts2(X, Y, edges, edges);
pXY = pXY/sum(pXY(:));

pX = sum(pXY, 2);
pY = sum(pXY, 1);
pX_pY = pX.*pY;

nzs = pXY>0;

mutInfo = sum(pXY(nzs).*log2(pXY(nzs)./pX_pY(nzs)));

end