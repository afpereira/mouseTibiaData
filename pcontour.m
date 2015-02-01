function pcontour(X, Y, Z)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

pcolor(X, Y, Z)
shading interp
hold on
contour(X, Y, Z, 'LineStyle', 'none')
set(gca,'YDir','reverse');

end

