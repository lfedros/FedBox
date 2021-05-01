function nCounts = countCellArr(C)

% C is a 2-D cell array, cells containing different number of elements Eij.
% nCounts is a vector, with nRows = total number of elements sum(Eij) in the cells
% of C, and 2 colums. Columns contain sub index i and j of the mother cells respectively.

dims = size(C);

C = reshape(C, 1,prod(dims));

% nDims = numel(dims);

nCounts = [];
for iCell = 1: prod(dims)
    
    [i j] = ind2sub(dims, iCell); % if ind2sub didn't want to specify output per dim we could work with any size of C
    count = numel(C{iCell});
    pos = repmat([i j], count,1);

    nCounts = [nCounts; pos];
    
end


return

% 
% %test the fun
% 
% C = cell(2);
% C{1} = [1 2];
% C{4} = [ 4 5 6 6];
% 
% nCounts = countCellArr(C);