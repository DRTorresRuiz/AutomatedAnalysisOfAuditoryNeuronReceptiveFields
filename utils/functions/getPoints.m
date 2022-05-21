function [x, y] = getPoints( spikes, property, num_sweeps,...
            rep_Interval, isRelative )
%GETPOINTS Given a list of spikes and some configurable values, this
% function returns x and y coordinates to plot.
%
% Usage example:
%
% Being `trials.Neuron2(1)` a trial object and its getSpikes() function returns 
% a list of spikes,
%
% >> [x, y] = getPoints( trials.Neuron2(1).getSpikes(), "Sweep", 25, 250, true );
% >> whos x y
%   Name      Size            Bytes  Class     Attributes
% 
%   x         1x62              496  double              
%   y         1x62              496  double 
% $Author: DRTorresRuiz$
    y = [];
    x = [];
    for spike = spikes
        if ~isempty(spike.SpikeTimes)

            for i = 1:length(spike.SpikeTimes)
                if isRelative
                    x_value = spike.SpikeTimes(i);        
                else
                    x_value = mod((spike.n-1), num_sweeps) * rep_Interval + spike.SpikeTimes(i);
                end
                x = [x  x_value];
                y = [y  spike.(property)];
            end
        end
    end
end

