function [spikes, sa] = getSpontaneousActivity( x, y, z, p, baseCaseProbabilities )
%GETSPONTANEOUSACTIVYT Separate spontaneous activity from stimulus
%responses.
%   The base case should include only spontaneuous activity. Normally, in
%   these cases in the AC, this means 0 dB SPL.
%   If there is no spikes with 0 dB SPL, the prob is set to 0.
%   Main idea is to separate stimulus responses from spontaneous activity
%   using a threshold. This threshold is by default the mean of all probabilities.
%   However, you can introduce the probabilities of the base case to use the highest probability
%   of the base case plus its standard deviation as threshold.
%
%   Usage example:
%
%   - Where `probs( z == 0 )` is the base case for 0 dB SPL.
%
% >> [spikes, sa] = getSpontaneousActivity( x, y, z, probs, probs( z == 0 ) );
%
% $Author: DRTorresRuiz$
arguments
    x (1,:) {mustBeNumeric}
    y (1,:) {mustBeNumeric}
    z (1,:) {mustBeNumeric}
    p (1,:) {mustBeNumeric}
    baseCaseProbabilities = []
end
    
    if ~isempty(baseCaseProbabilities)
        threshold = mean( p );
    else
        threshold = max(baseCaseProbabilities, [], 'all') + std(baseCaseProbabilities);
    end

    spikes = [];
    sa = [];
    for i = 1:length(x)
        time = x(i);
        sweep = y(i);
        db = z(i);
        prob = probs(i);

        if threshold < prob
            spikes = [spikes; time, sweep, db, prob];
        else
            sa = [sa; time, sweep, db, prob];
        end
    end
end

