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
FRA.x_size = length(z_values);
FRA.y_size = length(y_values);
FRA.raw = zeros( FRA.x_size, FRA.y_size );

%% Amplify y_values and z_values
if ~isempty(y_values)
    FRA.max_y = max(y_values);
    FRA.min_y = min(y_values);
    m_y = min(diff(y_values));
    y_values = [ (y_values(1) - 10 * m_y):m_y:(y_values(1) - m_y), y_values, (y_values(end) + m_y):m_y:(y_values(end) + 10 * m_y) ];
end

if ~isempty(z_values)
    FRA.max_x = max(z_values);
    FRA.min_x = min(z_values);
    m_x = min(diff(z_values));
    z_values = [ (z_values(1) - 10 * m_x):m_x:(z_values(1) - m_x), z_values, (z_values(end) + m_x):m_x:(z_values(end) + 10 * m_x) ];
end

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
FRA.mean = mean(FRA.raw(11:end-10, 11:end-10), 'all');
FRA.median = median(FRA.raw(11:end-10, 11:end-10), 'all');
FRA.mode = mode(FRA.raw(11:end-10, 11:end-10),'all');
FRA.std = std(FRA.raw(11:end-10, 11:end-10), [], 'all');
FRA.var = var(FRA.raw(11:end-10, 11:end-10), [], 'all');
FRA.max = max(FRA.raw(11:end-10, 11:end-10), [], 'all');
FRA.min = min(FRA.raw(11:end-10, 11:end-10), [], 'all');
% Smooth convolution
FRA.conv = conv2(FRA.normalized, [ 1 1 1; 1 1 1; 1 1 1], 'same'); 
% Negative smooth convolution
FRA.negconv = conv2(FRA.normalized, [ -1 -1 -1; -1 -1 -1; -1 -1 -1], 'same'); 

realConv = FRA.conv(11:end-10, 11:end-10);
FRA.sorted = sort(realConv(:)); % Save all values from conv in order.

% Find abrupt changes: https://es.mathworks.com/help/signal/ref/findchangepts.html#bu3nws1-ipt
ipt = findchangepts(FRA.sorted, 'MaxNumChanges', 1);

% Significant information to obtain the RF.
FRA.less_significant_mean = mean(FRA.sorted(1:ipt-1));
FRA.less_significant_std = std(FRA.sorted(1:ipt-1));
FRA.most_significant_mean = mean(FRA.sorted(ipt:end));
FRA.most_significant_std = std(FRA.sorted(ipt:end));

% FRA.core_threshold = FRA.sorted(ipt);
FRA.core_threshold = FRA.most_significant_mean;

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
FRA.periphery_bounds = [round(xPRF', -round( m_y / 10)), round(yPRF',-round( m_x / 10))];
% Bounds of the Core RF (CRF)
[xCRF, yCRF] = getBiggestArea( FRA.conv, FRA.core_threshold, y_values, z_values );
FRA.core_bounds = [round(xCRF', -round( m_y / 10)), round(yCRF',-round( m_x / 10))];

%% RF Mask
y_points = repmat( y_values(11:end-10), 1, FRA.x_size );
z_points = repmat( z_values(11:end-10), 1, FRA.y_size );
[Cin, ~] = inpolygon(  y_points, z_points, FRA.core_bounds(:,1), FRA.core_bounds(:,2) );
[Pin, Pon] = inpolygon(  y_points, z_points, FRA.periphery_bounds(:,1), FRA.periphery_bounds(:,2) );

% Frequency and dB points in the periphery and the core of the RF.
FRA.points_in_periphery = [y_points(( Pin | Pon ) & ~Cin); z_points(( Pin | Pon ) & ~Cin)];
FRA.points_in_core = [y_points(Cin); z_points(Cin)];

FRA.rf_mask = zeros( size(FRA.raw) );
% PERIPHERY
for point = FRA.points_in_periphery
    [~, idz] = min( abs(z_values - point(2)) );
    [~, idy] = min( abs(y_values - point(1)) );
    FRA.rf_mask( idz, idy ) = 1;
end

% CORE
for point = [y_points(Cin); z_points(Cin)]
    [~, idz] = min( abs(z_values - point(2)) );
    [~, idy] = min( abs(y_values - point(1)) );
    FRA.rf_mask( idz, idy ) = 2;
end

%% RF Characteristics

% Total spikes in all the FRA
FRA.total_spikes = sum( FRA.raw, 'all');
% Total spikes in the PRF
FRA.spikes_PRF = sum( FRA.raw( FRA.rf_mask == 1 ) );
% Total spikes in the CRF
FRA.spikes_CRF = sum( FRA.raw( FRA.rf_mask == 2 ) );
% Total spikes in the RF
FRA.spikes_RF = FRA.spikes_PRF + FRA.spikes_CRF;

max_area = FRA.x_size * FRA.y_size;
% Total area of the PRF
FRA.area_PRF = numel( FRA.raw( FRA.rf_mask == 1 ) ) / max_area;
% Total area of the CRF
FRA.area_CRF = numel( FRA.raw( FRA.rf_mask == 2 ) ) / max_area;
% Total area of the RF
FRA.area_RF = FRA.area_PRF + FRA.area_CRF;

% Clean bounds and points
FRA.periphery_bounds = FRA.periphery_bounds( ...
    FRA.periphery_bounds(:,1) >= FRA.min_y &...
    FRA.periphery_bounds(:,1) <= FRA.max_y &...
    FRA.periphery_bounds(:,2) >= FRA.min_x &...
    FRA.periphery_bounds(:,2) <= FRA.max_x, : );
FRA.points_in_periphery = FRA.points_in_periphery( :, ...
    FRA.points_in_periphery(1, :) >= FRA.min_y &...
    FRA.points_in_periphery(1, :) <= FRA.max_y &...
    FRA.points_in_periphery(2, :) >= FRA.min_x &...
    FRA.points_in_periphery(2, :) <= FRA.max_x );

FRA.core_bounds = FRA.core_bounds( ...
    FRA.core_bounds(:,1) >= FRA.min_y &...
    FRA.core_bounds(:,1) <= FRA.max_y &...
    FRA.core_bounds(:,2) >= FRA.min_x &...
    FRA.core_bounds(:,2) <= FRA.max_x, : );
FRA.points_in_core = FRA.points_in_core( :,...
    FRA.points_in_core(1, :) >= FRA.min_y &...
    FRA.points_in_core(1, :) <= FRA.max_y &...
    FRA.points_in_core(2, :) >= FRA.min_x &...
    FRA.points_in_core(2, :) <= FRA.max_x );

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


%% After all remove amplified values
FRA.raw = FRA.raw(11:end-10, 11:end-10);
FRA.normalized = FRA.normalized(11:end-10, 11:end-10);
FRA.conv = realConv;
FRA.negconv = FRA.negconv(11:end-10, 11:end-10);
FRA.rf_mask = FRA.rf_mask(11:end-10, 11:end-10);
end

