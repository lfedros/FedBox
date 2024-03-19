function [aveY, aveX, Xbin, stdY] = binYonX(X,Y, edges, med_flag)

if nargin <4
    med_flag = 0;
end

X = X(:); Y = Y(:);

nQuant = numel(edges)-1;

[~,~,idx] = histcounts(X, edges);

Xbin = edges(1:end-1) + 0.5*diff(edges);

for iQ = 1:nQuant

    chosenY = Y(idx == iQ);
    chosenX = X(idx == iQ);

    if isempty(chosenY)
        aveY(iQ) = NaN;
        stdY(iQ) = NaN;
        if med_flag
            aveX(iQ)= nanmedian(chosenX);
        else
            aveX(iQ)= nanmean(chosenX);

        end

    else
        if med_flag
            aveY(iQ) = nanmedian(chosenY);
            stdY(iQ) = nanstd(chosenY)/sqrt(numel(chosenY));
            aveX(iQ)= nanmedian(chosenX);
        else
            aveY(iQ) = nanmean(chosenY);
            stdY(iQ) = nanstd(chosenY)/sqrt(numel(chosenY));
            aveX(iQ)= nanmean(chosenX);
        end
    end

end
