function s = dotRaster(x, y)
%DOTRASTER Plots a dot raster and returns a scatter object.
%
%Usage example:
% `dot( spike_times, spike_freqs )`
%
% $Author: DRTorresRuiz$
    s = scatter( x, y, 'filled', '|');
    s.SizeData = 100;
    s.MarkerEdgeColor = 'k';
    s.MarkerFaceColor = [0 0.5 0.5];
end