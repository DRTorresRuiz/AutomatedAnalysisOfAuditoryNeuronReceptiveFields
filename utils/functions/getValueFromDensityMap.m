function prob = getValueFromDensityMap( x, x_values, y, y_values, z,  z_values,  densityMap )
%GETVALUEFROMDENSITYMAP Given a density map, obtain the value for a
%specific point.
%
%  Usage examples:
%
% >> getValueFromDensityMap( x_i, x_values, ...
%             y_i, y_values, ...
%             z_i, z_values, ...
%             xyz_density);
%
% $Author: DRTorresRuiz$
arguments
    x (1,1) {mustBeNumeric}
    x_values (1,:) {mustBeNumeric}
    y (1,1) {mustBeNumeric}
    y_values (1,:) {mustBeNumeric}
    z (1,1) {mustBeNumeric} = -1
    z_values = []
    densityMap (:,:,:) = []
end
    [~, idx] = min( abs(x_values - x) );
    [~, idy] = min( abs(y_values - y) );
    if z == -1 || isempty(z_values)
        % Consider that we are working on 2D
        prob = densityMap( idx, idy );
    else
        [~, idz] = min( abs(z_values - z) );
        % Consider that we are working on 3D
        prob = densityMap(idx, idy, idz );
    end
    
end