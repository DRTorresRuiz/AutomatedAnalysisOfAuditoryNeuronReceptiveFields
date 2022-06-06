function [x, y] = getBiggestArea( fra_values, threshold, y_values, z_values )
%GETBIGGESTAREA Returns the contour with the biggest area.
%
% Usage example:
%
% >> [x, y] = getBiggestArea( FRA.conv, FRA.periphery_threshold, y_values, z_values );
% >> [xC, yC] = getBiggestArea( FRA.conv, FRA.core_threshold, y_values, z_values );
%
% $Author: DRTorresRuiz$

    M = contourc(y_values, z_values, fra_values, [threshold, threshold]);
    %Need this function: https://es.mathworks.com/matlabcentral/fileexchange/43162-c2xyz-contour-matrix-to-coordinates
    [x, y, z] = C2xyz( M );

    biggest_area = 0;
    biggest_n = 1;
    for n = find(z==threshold) % only loop through the z = 0 values.
        area = polyarea( x{n}, y{n} );
        if biggest_area < area
            biggest_area = area;
            biggest_n = n;
        end
%         fprintf( "\tPoly area " + area + "\n" ); 
    end
    
    x = x{biggest_n};
    y = y{biggest_n};
end

