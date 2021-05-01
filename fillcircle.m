function fillcircle(x,y,r, color)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but

ang=0:0.1:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
fill(x+xp,y+yp,color,'linestyle','none');
end