function cm = GreenBlackRed(n, gamma)

if nargin<1; n = 100; end
if nargin<2; gamma = 0.5; end

cm = ([zeros(1,n), 0:1:n; ...
       n:-1:0, zeros(1,n);...
      zeros(1, 2*n+1)]' / n).^gamma;

  
colormap(cm);
