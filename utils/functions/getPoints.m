function [x, y] = getPoints( spikesPerTrial, property, num_sweeps,...
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
    for spikes = spikesPerTrial
        if ~isempty(spikes.SpikeTimes)

            for i = 1:length(spikes.SpikeTimes)
                if isRelative
                    x_value = spikes.SpikeTimes(i);        
                else
                    x_value = mod((spikes.n-1), num_sweeps) * rep_Interval + spikes.SpikeTimes(i);
                end
                x = [x  x_value];
                y = [y  spikes.(property)];
            end
        end
    end
end

