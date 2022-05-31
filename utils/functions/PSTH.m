function [values, h] = PSTH( x, edges )
%PSTH Plot a PSTH given the time of the spikes and the 
% edges to obtain the PSTH.
%
% Usage example:
%
% >> PSTH( x, x_values )
%
% $Author: DRTorresRuiz$
arguments
    x
    edges = []
end
    if isempty(edges)
        edges = 0:max(x);
    end
    
    h = histogram( x, edges );
    values = h.Values;
    ylabel( "spikes/ms" );
end

