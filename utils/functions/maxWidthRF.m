function result = maxWidthRF( values, sweeps, channels )
% MAXWIDTHRF
arguments
    values
    sweeps = []
    channels = 1
end
    [ ~, idx ] = max( values(:,2) - values(:,1) );
    maximum_values = values(idx, :);
    if ~isempty(sweeps)
        left = sweepToFreq( maximum_values(1), sweeps, channels );
        right = sweepToFreq( maximum_values(2), sweeps, channels );
    else
        left = maximum_values(1);
        right = maximum_values(2);
    end
    
        
    result = [ left, right, right-left, log2( right / left ) ];
end

