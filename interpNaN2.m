function ZI = interpNaN2(Z)
% interpolate NaN holes in 2D matrix


[y, x] = size(Z);

[Y, X] = meshgrid(1:x, 1:y);

idxgood = ~isnan(Z);

% ZI = griddata(Y(idxgood) , X(idxgood), double(Z(idxgood)), Y, X);

% idxgood = ~isnan(ZI);

F = scatteredInterpolant(Y(idxgood) , X(idxgood), double(Z(idxgood)));
ZI = F(Y, X);



% F = griddedInterpolant(Y', X', ZI');
% ZI = F(Y', X');
% 
% ZI = ZI';

% EXAMPLE INTERPOLATION OF SCATTERED DATA, missing values both in the GRID
% (A,B) and in the values Z

% %// identify indices valid for the 3 matrix 
% idxgood=~(isnan(A) | isnan(B) | isnan(C)); 
% 
% %// define a "uniform" grid without holes (same boundaries and sampling than original grid)
% [AI,BI] = meshgrid(-3:0.25:3) ;
% 
% %// re-interpolate scattered data (only valid indices) over the "uniform" grid
% CI = griddata( A(idxgood),B(idxgood),C(idxgood), AI, BI ) ;

end