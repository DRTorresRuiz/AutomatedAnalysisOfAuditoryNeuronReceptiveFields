function y = sweepToFreq(y, sweeps, channels)
%SWEEPTOFREQ This function transforms the given list of sweep id number to the frequency value specified in the Trial information.
% 
% Usage example:
% 
% - Being `t` a Trial and `y` a list of sweep number for a specific spike:
% 
% >> `sweepToFreq(y, t.getSweeps(), t.Channels)`
%
% $Author: DRTorresRuiz$
    for i = 1:length(y)
        y(i) = sweeps( round(y(i)) * channels - (channels - 1) ).CarFreq;
    end
end

