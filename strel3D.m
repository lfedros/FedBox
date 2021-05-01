function se = strel3D(n, type)

if nargin <2
    type = 'ellipsoid';
end

switch type
    case 'ellipsoid'
        
        if size(n) ==1
            n = ones(1,3)*n;
        end
        
        m = max(n);
        [x,y,z] = ndgrid(-m:m);
        
        se = strel(sqrt(x.^2/n(1).^2 + y.^2/n(2).^2 + z.^2/n(3).^2) <=1);
        
        %figure; isosurface(sqrt(x.^2/n(1).^2 + y.^2/n(2).^2 +z.^2/n(3).^2) <=1);
end
end