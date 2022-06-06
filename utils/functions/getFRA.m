function FRA = getFRA( x, y, z, y_values, z_values, cleanSA )
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
% - core_threshold: Value in which the most abrupt change occurs
% (obtained using `findchangepts` MATLAB R2022a function). Higher values
% are in the core part of the receptive field of the neuron.
% - periphery_threshold: Higher values of this threshold are in the
% periphery part of the receptive field of the neuron.
% - periphery_bounds: points of the contour that delimit periphery RF.
% - core_bounds: points of the contour that delimit core RF.
% - spikes_per_freq: Sum of all spikes per Frequency.
% - spikes_per_db: Sum of all spikes per sound level (dB SPL).
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
%                    core_threshold: 0.0971
%               periphery_threshold: 0.0342
%                   spikes_per_freq: [25×2 double]
%                     spikes_per_db: [9×2 double]
%                  periphery_bounds: [21×2 double]
%                       core_bounds: [21×2 double]
% 
% $Author: DRTorresRuiz$
arguments
    x (1,:) 
    y (1,:)
    z (1,:)
    y_values = unique(y)
    z_values = unique(z)
    cleanSA = false
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

% Significant information to obtain the RF.
FRA.less_significant_mean = mean(FRA.sorted(1:ipt-1));
FRA.less_significant_std = std(FRA.sorted(1:ipt-1));
FRA.core_threshold = FRA.sorted(ipt);

FRA.periphery_threshold = FRA.less_significant_mean;
if cleanSA
    FRA.periphery_threshold = FRA.periphery_threshold + FRA.less_significant_std;
end

% Total spikes per Freq
FRA.spikes_per_freq = [y_values', sum(FRA.raw,1)'];
% Total spikes per dB
FRA.spikes_per_db = [z_values', sum(FRA.raw,2)];

%% Contours
% Bounds of the Periphery RF (PRF)
[xPRF, yPRF] = getBiggestArea( FRA.conv, FRA.periphery_threshold, y_values, z_values );
FRA.periphery_bounds = [xPRF', yPRF'];
% Bounds of the Core RF (CRF)
[xCRF, yCRF] = getBiggestArea( FRA.conv, FRA.core_threshold, y_values, z_values );
FRA.core_bounds = [xCRF', yCRF'];

%% RF Characteristics

% Total spikes in the PRF
% Total spikes in the CRF

% Total area of the PRF
% Total area of the CRF

% Width of the PRF
% Width of the CRF

% Height of the PRF
% Height of the CRF

% Response threshold (Characteristic Frequency, CF) - the frequency where
% the sound level is minimum.

% Best Frequency (BF). The frequency eliciting the highest response in the
% frequency-response profile was defined as the BF.

% Center Frequency

% Point at which there is the highest rate of spikes

% Function Slopes

end

