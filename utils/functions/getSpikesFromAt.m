function [spikes, idx] = getSpikesFromAt( sp, from, at )
%GETSPIKESFROM Return the number of spikes in a specified windows of time.
%
% Usage example:
% `getSpikesFromAt( spike_times, 10, 75 )`
%
% $Author: DRTorresRuiz$
arguments
    sp (1, :)
    from (1,1) {mustBeNumeric, mustBePositive, mustBeInteger} = 0
    at (1,1) {mustBeNumeric, mustBePositive, mustBeInteger} = 250
end

    idx =  find(sp >= from & sp <= at);
    spikes = sp(idx);
end

