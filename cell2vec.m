function y = cell2vec(x)
% catenate all the elements in the cell array x into the vector y. x must
% contains only numeric elements

 c = numel(x);
 y = [];
 for ic = 1:c
     if ~isempty(x{ic})
     y = [y; x{ic}(:)];
     end
 end

end