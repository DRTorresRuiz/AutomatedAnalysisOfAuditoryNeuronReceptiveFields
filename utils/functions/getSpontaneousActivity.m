function [spikes, sa, threshold] = getSpontaneousActivity( x, y, z, p, baseCaseProbabilities )
%GETSPONTANEOUSACTIVYT Separate spontaneous activity from stimulus
%responses.
%   The base case should include only spontaneous activity. Normally, in
%   these cases in the AC, this means 0 dB SPL.
%   Main idea is to separate stimulus responses from spontaneous activity
%   using a threshold. This threshold is by default the most representative 
%   value of the less significant 25 percent of the stimuli. However,
%   you can introduce the probabilities of the base case to use the 
%   highest probability of the base case as threshold.
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

    if length( baseCaseProbabilities ) / length( x ) > 0.002
        threshold = max( baseCaseProbabilities, [], 'all' );
    else
        median_p = median( p );
        p50_less_significant = p( p < median_p );
        median_p50_less_significant = median( p50_less_significant );
        p25_less_significant = p50_less_significant( p50_less_significant < median_p50_less_significant );
        mean_p25_less_significant = mean( p25_less_significant ) - std( p25_less_significant );
        if mean_p25_less_significant < 0
            mean_p25_less_significant = mean( p25_less_significant );
            threshold = min( p( p < mean_p25_less_significant & p > 0 ) );
        else
            threshold = max( p( p < mean_p25_less_significant & p > 0 ) );
        end
    end
    
    spikes = [];
    sa = [];
    for i = 1:length(x)
        time = x(i);
        sweep = y(i);
        db = z(i);
        prob = p(i);

        if threshold < prob
            spikes = [spikes; time, sweep, db, prob];
        else
            sa = [sa; time, sweep, db, prob];
        end
    end
end

