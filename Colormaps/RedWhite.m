function cm = RedWhite(n)

if nargin<1; n = 100; end

cm = ([ones(1,n)*n ; ...
      n-1:-1:0; ...
      n-1:-1:0]' / n);
colormap(cm);
