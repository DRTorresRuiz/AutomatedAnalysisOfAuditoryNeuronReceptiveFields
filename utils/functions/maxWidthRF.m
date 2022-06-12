function result = maxWidthRF( values, sweeps, channels )
% MAXWIDTHRF

    [ ~, idx ] = max( values(:,2) - values(:,1) );
    maximum_values = values(idx, :);
    left = sweepToFreq( maximum_values(1), sweeps, channels );
    right = sweepToFreq( maximum_values(2), sweeps, channels );

    result = [ left, right, right-left ];
end

