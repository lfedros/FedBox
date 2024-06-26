function cm = WhiteRed(n, gamma)

if nargin<1; n = 100; end
if nargin<2; gamma = 1; end


cm = ([ones(1,n)*n ; ...
      n-1:-1:0; ...
      n-1:-1:0]' / n).^gamma;
colormap(cm);
