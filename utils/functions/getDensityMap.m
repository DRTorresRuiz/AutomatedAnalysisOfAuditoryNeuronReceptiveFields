function [x_density, x_tin, y_density, y_tin, z_density, z_tin,...
    xyz_density, xy_density ] = getDensityMap( x, x_values, ...
                        y, y_values, z, z_values, isDiscrete, plotImage )
%GETDENSITYMAP Given all points (x, y, z) return the density functions for
% all variables.
%
%  Usage examples:
%
% > x_values = 1:250;
% > y_values = 1:25;
% > z_values = 0:10:80;
% > [ x_density, x_tin, y_density, y_tin, z_density, z_tin, xyz_density, xy_density ] =...
%     getDensityMap( x, x_values, y, y_values, z, z_values );
% 
% $Author: DRTorresRuiz$
arguments
    x (1, :) {mustBeNumeric}
    x_values
    y (1, :) {mustBeNumeric}
    y_values
    z (1, :) {mustBeNumeric}
    z_values
    isDiscrete (1,3) = [ 0 1 1 ] % By default, x is the only continuous variable.
    plotImage = false
end
    
    function [density, tin] = getDiscreteDensity( x ) 
        
        [density, tin] = groupcounts( x' );  
        density = density' / sum( density );
    end

    % Obtain x_density
    if isDiscrete(1)
        [ x_density, x_tin ] = getDiscreteDensity( x );
    else
        [ x_density, x_tin ] = ssvkernel( x, x_values );
    end
    
    % Obtain y_density
    if isDiscrete(2)
        [ y_density, y_tin ] = getDiscreteDensity( y );
    else
        [ y_density, y_tin ] = ssvkernel( y, y_values );
    end
    
    % Obtain z_density
    if isDiscrete(3)
        [ z_density, z_tin ] = getDiscreteDensity( z );
    else
        [ z_density, z_tin ] = ssvkernel( z, z_values );
    end

    xy_density = y_density .* x_density';
    xyz_density = bsxfun(@times, xy_density, shiftdim(z_density,-1));

    if plotImage
        implay( xyz_density / max( xyz_density, [], 'all' ) );
    end
end

