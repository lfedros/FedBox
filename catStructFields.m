function S = catStructFields(S1, S2, dim)

if nargin < 3
    dim = 1;
end

% assume fields of S1 and S2 are the same and in same order
fields = fieldnames(S1);

% add flexibility to handle different fields and different oreder?
% fields1 = fieldnames(S1);
% fields2 = fieldnames(S2);
% etc...

for k = 1:numel(fields)
  aField     = fields{k};
  S.(aField) = cat(dim, S1.(aField), S2.(aField));
end

%%