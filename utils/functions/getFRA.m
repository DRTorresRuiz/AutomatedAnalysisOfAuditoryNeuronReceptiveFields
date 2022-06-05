function FRA = getFRA( x, y, z, y_values, z_values )
%GETFRA Given a specific number of points, that represent spikes, this
%function returns a FRA struct with:
% - raw: The number of spikes for each (z,y) cell in a ZxY matrix.
% - normalized: FRA.raw normalized.
% 
% More information using FRA.raw:
% - mean
% - median
% - mode
% - std
% - var
% - max
% - min
%
% Smoothed normalized FRA using convolution operation:
% - conv: With kernel [1 1 1; 1 1 1; 1 1 1].
% - negconv: Negative conv operation. With kernel [-1 -1 -1; -1 -1 -1; -1
% -1 -1].
% 
% Also:
% - sorted: All FRA.conv values in ascending order.
% - less_significant_mean: mean of less significant values
% - less_significant_std: Standard deviation of less significant values
% - significant_threshold: Value in which the most abrupt change occurs
% (obtained using `findchangepts` MATLAB R2022a function).
%
% Usage example:
%
% >> FRA = getFRA( x, y, z, y_values, z_values );
% >> FRA
%
%         FRA = 
% 
%           struct with fields:
% 
%                               raw: [9×25 double]
%                        normalized: [9×25 double]
%                              mean: 3.3422
%                            median: 0
%                              mode: 0
%                               std: 7.6405
%                               var: 58.3779
%                               max: 49
%                               min: 0
%                              conv: [9×25 double]
%                           negconv: [9×25 double]
%                            sorted: [225×1 double]
%             less_significant_mean: 0.0141
%              less_significant_std: 0.0194
%             significant_threshold: 0.0971
%
% $Author: DRTorresRuiz$
arguments
    x (1,:) 
    y (1,:)
    z (1,:)
    y_values = unique(y)
    z_values = unique(z) 
end

%% Init FRA
FRA.raw = zeros( length(z_values), length(y_values) );

%% Count values for each position of FRA
for yi = y_values
    for zi = z_values
        % For each frequency and intensity
        % Count the total number of spikes
        total_spikes =  numel( x( y == yi & z == zi ) );
        
        % Save the number of spikes for a specific frequency and intensity
        idy = find( y_values == yi); % Frequency index
        idz = find( z_values == zi); % Intensity index
        FRA.raw( idz, idy ) = total_spikes;
    end
end

%% Statistical information about the FRA
FRA.normalized = FRA.raw / sum(FRA.raw, 'all');
FRA.mean = mean(FRA.raw, 'all');
FRA.median = median(FRA.raw, 'all');
FRA.mode = mode(FRA.raw,'all');
FRA.std = std(FRA.raw, [], 'all');
FRA.var = var(FRA.raw, [], 'all');
FRA.max = max(FRA.raw, [], 'all');
FRA.min = min(FRA.raw, [], 'all');
% Smooth convolution
FRA.conv = conv2(FRA.normalized, [ 1 1 1; 1 1 1; 1 1 1], 'same'); 
% Negative smooth convolution
FRA.negconv = conv2(FRA.normalized, [ -1 -1 -1; -1 -1 -1; -1 -1 -1], 'same'); 
FRA.sorted = sort(FRA.conv(:)); % Save all values from conv in order.

% Find abrupt changes: https://es.mathworks.com/help/signal/ref/findchangepts.html#bu3nws1-ipt
ipt = findchangepts(FRA.sorted, 'MaxNumChanges', 1);

% Significant information
FRA.less_significant_mean = mean(FRA.sorted(1:ipt-1));
FRA.less_significant_std = std(FRA.sorted(1:ipt-1));
FRA.significant_threshold = FRA.sorted(ipt);

end

