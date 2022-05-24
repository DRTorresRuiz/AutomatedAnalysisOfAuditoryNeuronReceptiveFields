function y = sweepToFreq(y, sweeps, channels)
%SWEEPTOFREQ Summary of this function goes here
%   Detailed explanation goes here
    for i = 1:length(y)
        y(i) = sweeps( y(i) * channels - (channels - 1) ).CarFreq;
    end
end

