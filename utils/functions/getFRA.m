function FRA = getFRA( x, y, z, sweeps, channels, y_values, x_values, kernel )
%GETFRA Given a specific number of points, that represent spikes, this
% function returns FRA information.
%
% Usage example:
%
% >> FRA = getFRA( x, y, z, sweeps, channels, y_values, x_values );
% >> FRA
%
%         FRA = 
% 
%           struct with fields:
% 
%                    y_values: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25]
%                    x_values: [0 10 20 30 40 50 60 70 80]
%                       stats: [1×1 struct]
%                    raw_data: [9×25 double]
%                   transform: [1×1 struct]
%             receptive_field: [1×1 struct]
% 
% $Author: DRTorresRuiz$
arguments
    x (1,:) 
    y (1,:)
    z (1,:)
    sweeps
    channels
    y_values = unique(y)
    x_values = unique(z)
    kernel = [  .05 .05 .05;...
                1   2   1;...
                .05 .05 .05 ]
%     kernel = [ .005 .01 .01   .01 .01 .01 .005;...
%                .01  .01  1    1   1   .01 .01;...
%                .01  1    1    2   1   1   .01;...
%                .01  .01  1    1   1   .01 .01;
%                .005 .01 .01   .01 .01 .01 .005]
%    kernel = [   .01  .01 .05 1 .05 .01 .01;...
%                 .01  .05 1   2   1   .05 .01;...
%                 .01  .01 .05 1 .05 .01 .01 ]
end

%% Init FRA
FRA.y_values = y_values;
FRA.x_values = x_values;
FRA.stats.x_size = length(x_values);
FRA.stats.y_size = length(y_values);
FRA.raw_data = zeros( FRA.stats.x_size, FRA.stats.y_size );

%% Amplify y_values and x_values
if ~isempty(y_values)
    FRA.stats.max_y = max(y_values);
    FRA.stats.min_y = min(y_values);
    m_y = min(diff(y_values));
    y_values = [ (y_values(1) - 10 * m_y):m_y:(y_values(1) - m_y), y_values, (y_values(end) + m_y):m_y:(y_values(end) + 10 * m_y) ];
end

if ~isempty(x_values)
    FRA.stats.max_x = max(x_values);
    FRA.stats.min_x = min(x_values);
    m_x = min(diff(x_values));
    x_values = [ (x_values(1) - 10 * m_x):m_x:(x_values(1) - m_x), x_values, (x_values(end) + m_x):m_x:(x_values(end) + 10 * m_x) ];
end

%% Count values for each position of FRA
for yi = y_values
    for zi = x_values
        %%% For each frequency and intensity
        %%% Count the total number of spikes
        total_spikes =  numel( x( y == yi & z == zi ) );
        
        %%% Save the number of spikes for a specific frequency and intensity
        idy = find( y_values == yi); %%% Frequency index
        idz = find( x_values == zi); %%% Intensity index
        FRA.raw_data( idz, idy ) = total_spikes;
    end
end

%% Statistical information about the FRA
FRA.transform.normalized = FRA.raw_data / sum(FRA.raw_data, 'all');
FRA.stats.mean = mean(FRA.raw_data(11:end-10, 11:end-10), 'all');
FRA.stats.median = median(FRA.raw_data(11:end-10, 11:end-10), 'all');
FRA.stats.mode = mode(FRA.raw_data(11:end-10, 11:end-10),'all');
FRA.stats.std = std(FRA.raw_data(11:end-10, 11:end-10), [], 'all');
FRA.stats.var = var(FRA.raw_data(11:end-10, 11:end-10), [], 'all');
FRA.stats.max = max(FRA.raw_data(11:end-10, 11:end-10), [], 'all');
FRA.stats.min = min(FRA.raw_data(11:end-10, 11:end-10), [], 'all');
%%% Smooth convolution
% FRA.transform.conv = conv2(FRA.transform.normalized, [ 1 1 1; 1 1 1; 1 1 1], 'same'); 
FRA.transform.conv = conv2(FRA.transform.normalized, kernel, 'same');
%%% Negative smooth convolution
% FRA.transform.negconv = conv2(FRA.transform.normalized, [ -1 -1 -1; -1 -1 -1; -1 -1 -1], 'same'); 
FRA.transform.negconv = conv2(FRA.transform.normalized, (-1)*kernel, 'same'); 

realConv = FRA.transform.conv(11:end-10, 11:end-10);
FRA.transform.sorted_conv_values = sort(realConv(:)); %%% Save all values from conv in order.

%%% Find abrupt changes: https://es.mathworks.com/help/signal/ref/findchangepts.html#bu3nws1-ipt
ipt = findchangepts(FRA.transform.sorted_conv_values, 'MaxNumChanges', 1);

%%% Significant information to obtain the RF.
FRA.receptive_field.less_significant_mean = mean(FRA.transform.sorted_conv_values(1:ipt-1));
FRA.receptive_field.less_significant_std = std(FRA.transform.sorted_conv_values(1:ipt-1));
FRA.receptive_field.most_significant_mean = mean(FRA.transform.sorted_conv_values(ipt:end));
FRA.receptive_field.most_significant_std = std(FRA.transform.sorted_conv_values(ipt:end));

% FRA.receptive_field.core_receptive_field.core_threshold = FRA.transform.sorted_conv_values(ipt);
FRA.receptive_field.core_receptive_field.core_threshold = FRA.receptive_field.most_significant_mean;

FRA.receptive_field.periphery_receptive_field.periphery_threshold = FRA.receptive_field.less_significant_mean;
FRA.receptive_field.periphery_receptive_field.periphery_threshold = FRA.receptive_field.periphery_receptive_field.periphery_threshold + FRA.receptive_field.less_significant_std;

%%% Total spikes per Freq
FRA.stats.spikes_per_freq = [FRA.y_values', sum(FRA.raw_data(11:end-10, 11:end-10),1)'];
%%% Total spikes per dB
FRA.stats.spikes_per_db = [FRA.x_values', sum(FRA.raw_data(11:end-10, 11:end-10),2)];

%% Contours
%%% Bounds of the Periphery RF (PRF)
[xPRF, yPRF] = getBiggestArea( FRA.transform.conv, FRA.receptive_field.periphery_receptive_field.periphery_threshold, y_values, x_values );
% FRA.receptive_field.periphery_receptive_field.periphery_bounds = [round(xPRF', -round( m_y / 10)), round(yPRF',-round( m_x / 10))];
% FRA.receptive_field.periphery_receptive_field.periphery_bounds = [fix(xPRF'),fix(yPRF')];
FRA.receptive_field.periphery_receptive_field.periphery_bounds = [xPRF',yPRF'];

%%% Bounds of the Core RF (CRF)
[xCRF, yCRF] = getBiggestArea( FRA.transform.conv, FRA.receptive_field.core_receptive_field.core_threshold, y_values, x_values );
% FRA.receptive_field.core_receptive_field.core_bounds = [round(xCRF', -round( m_y / 10)), round(yCRF',-round( m_x / 10))];
% FRA.receptive_field.core_receptive_field.core_bounds = [fix(xCRF'), fix(yCRF')];
FRA.receptive_field.core_receptive_field.core_bounds = [xCRF', yCRF'];

%% RF Mask
y_points = repmat( y_values(11:end-10), 1, FRA.stats.x_size );
z_points = repmat( x_values(11:end-10), 1, FRA.stats.y_size );
[Cin, ~] = inpolygon(  y_points, z_points, FRA.receptive_field.core_receptive_field.core_bounds(:,1), FRA.receptive_field.core_receptive_field.core_bounds(:,2) );
[Pin, Pon] = inpolygon(  y_points, z_points, FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1), FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) );

%%% Frequency and dB points in the periphery and the core of the RF.
FRA.receptive_field.periphery_receptive_field.points_in_periphery = [y_points(( Pin | Pon ) & ~Cin); z_points(( Pin | Pon ) & ~Cin)];
FRA.receptive_field.core_receptive_field.points_in_core = [y_points(Cin); z_points(Cin)];

FRA.receptive_field.rf_mask = zeros( size(FRA.raw_data) );
%%% PERIPHERY
for point = FRA.receptive_field.periphery_receptive_field.points_in_periphery
    [~, idz] = min( abs(x_values - point(2)) );
    [~, idy] = min( abs(y_values - point(1)) );
    FRA.receptive_field.rf_mask( idz, idy ) = 1;
end

%%% CORE
for point = [y_points(Cin); z_points(Cin)]
    [~, idz] = min( abs(x_values - point(2)) );
    [~, idy] = min( abs(y_values - point(1)) );
    FRA.receptive_field.rf_mask( idz, idy ) = 2;
end

%% After all remove amplified values
FRA.raw_data = FRA.raw_data(11:end-10, 11:end-10);
FRA.transform.normalized = FRA.transform.normalized(11:end-10, 11:end-10);
FRA.transform.conv = realConv;
FRA.transform.negconv = FRA.transform.negconv(11:end-10, 11:end-10);
FRA.receptive_field.rf_mask = FRA.receptive_field.rf_mask(11:end-10, 11:end-10);

%%% Clean bounds and points
FRA.receptive_field.periphery_receptive_field.periphery_bounds = FRA.receptive_field.periphery_receptive_field.periphery_bounds( ...
    FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) >= FRA.stats.min_y &...
    FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) <= FRA.stats.max_y &...
    FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) >= FRA.stats.min_x &...
    FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) <= FRA.stats.max_x, : );
FRA.receptive_field.periphery_receptive_field.points_in_periphery = FRA.receptive_field.periphery_receptive_field.points_in_periphery( :, ...
    FRA.receptive_field.periphery_receptive_field.points_in_periphery(1, :) >= FRA.stats.min_y &...
    FRA.receptive_field.periphery_receptive_field.points_in_periphery(1, :) <= FRA.stats.max_y &...
    FRA.receptive_field.periphery_receptive_field.points_in_periphery(2, :) >= FRA.stats.min_x &...
    FRA.receptive_field.periphery_receptive_field.points_in_periphery(2, :) <= FRA.stats.max_x );

FRA.receptive_field.core_receptive_field.core_bounds = FRA.receptive_field.core_receptive_field.core_bounds( ...
    FRA.receptive_field.core_receptive_field.core_bounds(:,1) >= FRA.stats.min_y &...
    FRA.receptive_field.core_receptive_field.core_bounds(:,1) <= FRA.stats.max_y &...
    FRA.receptive_field.core_receptive_field.core_bounds(:,2) >= FRA.stats.min_x &...
    FRA.receptive_field.core_receptive_field.core_bounds(:,2) <= FRA.stats.max_x, : );
FRA.receptive_field.core_receptive_field.points_in_core = FRA.receptive_field.core_receptive_field.points_in_core( :,...
    FRA.receptive_field.core_receptive_field.points_in_core(1, :) >= FRA.stats.min_y &...
    FRA.receptive_field.core_receptive_field.points_in_core(1, :) <= FRA.stats.max_y &...
    FRA.receptive_field.core_receptive_field.points_in_core(2, :) >= FRA.stats.min_x &...
    FRA.receptive_field.core_receptive_field.points_in_core(2, :) <= FRA.stats.max_x );

%% RF Characteristics

%%% Total spikes in all the FRA
FRA.stats.total_spikes = sum( FRA.raw_data, 'all');
%%% Total spikes in the PRF
FRA.receptive_field.periphery_receptive_field.spikes_PRF = sum( FRA.raw_data( FRA.receptive_field.rf_mask == 1 ) );
%%% Total spikes in the CRF
FRA.receptive_field.core_receptive_field.spikes_CRF = sum( FRA.raw_data( FRA.receptive_field.rf_mask == 2 ) );
%%% Total spikes in the RF
FRA.receptive_field.spikes_RF = FRA.receptive_field.periphery_receptive_field.spikes_PRF + FRA.receptive_field.core_receptive_field.spikes_CRF;

max_area = FRA.stats.x_size * FRA.stats.y_size;
%%% Total area of the PRF
FRA.receptive_field.periphery_receptive_field.area_PRF = numel( FRA.raw_data( FRA.receptive_field.rf_mask == 1 ) ) / max_area;
%%% Total area of the CRF
FRA.receptive_field.core_receptive_field.area_CRF = numel( FRA.raw_data( FRA.receptive_field.rf_mask == 2 ) ) / max_area;
%%% Total area of the RF
FRA.receptive_field.area_RF = FRA.receptive_field.periphery_receptive_field.area_PRF + FRA.receptive_field.core_receptive_field.area_CRF;

%%% Highest Frequency
FRA.receptive_field.periphery_receptive_field.highest_freq_PRF = max( FRA.receptive_field.periphery_receptive_field.points_in_periphery(1,:) );
FRA.receptive_field.core_receptive_field.highest_freq_CRF = max( FRA.receptive_field.core_receptive_field.points_in_core(1,:) );
%%% Lowest Frequency
FRA.receptive_field.periphery_receptive_field.lowest_freq_PRF = min( FRA.receptive_field.periphery_receptive_field.points_in_periphery(1,:) );
FRA.receptive_field.core_receptive_field.lowest_freq_CRF = min( FRA.receptive_field.core_receptive_field.points_in_core(1,:) );

%%% Highest sound Level
FRA.receptive_field.periphery_receptive_field.highest_db_PRF = max( FRA.receptive_field.periphery_receptive_field.points_in_periphery(2,:) );
FRA.receptive_field.core_receptive_field.highest_db_CRF = max( FRA.receptive_field.core_receptive_field.points_in_core(2,:) );
%%% Lowest sound Level
FRA.receptive_field.periphery_receptive_field.lowest_db_PRF = min( FRA.receptive_field.periphery_receptive_field.points_in_periphery(2,:) );
FRA.receptive_field.core_receptive_field.lowest_db_CRF = min( FRA.receptive_field.core_receptive_field.points_in_core(2,:) );

%%% Width of the PRF
%%% Width of the CRF
FRA.receptive_field.periphery_receptive_field.width_PRF = zeros( FRA.stats.x_size, 2 );
FRA.receptive_field.core_receptive_field.width_CRF = zeros( FRA.stats.x_size, 2 );
for i = 1:FRA.stats.x_size
    first_prf = find( FRA.receptive_field.rf_mask( i, : ) > 0, 1, 'first' );
    last_prf = find( FRA.receptive_field.rf_mask( i, : ) > 0, 1, 'last' );
    if ~isempty( first_prf )
        FRA.receptive_field.periphery_receptive_field.width_PRF(i, 1) = FRA.y_values(first_prf);
        FRA.receptive_field.periphery_receptive_field.width_PRF(i, 2) = FRA.y_values(last_prf);
    else
        FRA.receptive_field.periphery_receptive_field.width_PRF(i, 1) = -1;
        FRA.receptive_field.periphery_receptive_field.width_PRF(i, 2) = -1;
    end
    
    first_crf = find( FRA.receptive_field.rf_mask( i, : ) > 1, 1, 'first' );
    last_crf = find( FRA.receptive_field.rf_mask( i, : ) > 1, 1, 'last' );
    if ~isempty( first_crf )
        FRA.receptive_field.core_receptive_field.width_CRF(i, 1) = FRA.y_values(first_crf);
        FRA.receptive_field.core_receptive_field.width_CRF(i, 2) = FRA.y_values(last_crf);
    else
        FRA.receptive_field.core_receptive_field.width_CRF(i, 1) = -1;
        FRA.receptive_field.core_receptive_field.width_CRF(i, 2) = -1;
    end
end

%%% Height of the PRF
%%% Height of the CRF
FRA.receptive_field.periphery_receptive_field.height_PRF = zeros( 2, FRA.stats.y_size);
FRA.receptive_field.core_receptive_field.height_CRF = zeros( 2, FRA.stats.y_size );
for i = 1:FRA.stats.y_size
    first_prf = find( FRA.receptive_field.rf_mask( :, i ) > 0, 1, 'first' );
    last_prf = find( FRA.receptive_field.rf_mask( :, i ) > 0, 1, 'last' );
    if ~isempty( first_prf )
        FRA.receptive_field.periphery_receptive_field.height_PRF(2, i) = FRA.x_values(first_prf);
        FRA.receptive_field.periphery_receptive_field.height_PRF(1, i) = FRA.x_values(last_prf);
    else
        FRA.receptive_field.periphery_receptive_field.height_PRF(2, i) = -1;
        FRA.receptive_field.periphery_receptive_field.height_PRF(1, i) = -1;
    end
    
    first_crf = find( FRA.receptive_field.rf_mask( :, i ) > 1, 1, 'first' );
    last_crf = find( FRA.receptive_field.rf_mask( :, i ) > 1, 1, 'last' );
    if ~isempty( first_crf )
        FRA.receptive_field.core_receptive_field.height_CRF(2, i) = FRA.x_values(first_crf);
        FRA.receptive_field.core_receptive_field.height_CRF(1, i) = FRA.x_values(last_crf);
    else
        FRA.receptive_field.core_receptive_field.height_CRF(2, i) = -1;
        FRA.receptive_field.core_receptive_field.height_CRF(1, i) = -1;
    end
end

%% Minimum threshold - Minimum level of intensity that produces a response
%%% to the CF.
% FRA.receptive_field.minimum_threshold = min( FRA.receptive_field.periphery_receptive_field.height_PRF(FRA.receptive_field.periphery_receptive_field.height_PRF(2,:) > -1) );
FRA.receptive_field.minimum_threshold = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) );

%% Response threshold (Characteristic Frequency, CF) - the frequency where
%%% the sound level is minimum.
FRA.receptive_field.response_threshold = FRA.receptive_field.periphery_receptive_field.periphery_bounds( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) == FRA.receptive_field.minimum_threshold, 1 );
% Center Frequency for CF
FRA.receptive_field.response_threshold = prod([ max(FRA.receptive_field.response_threshold), min(FRA.receptive_field.response_threshold)])^(1/2);

%% Best Frequency (BF). Frequency with the highest response of spikes.
[~, ibf] = max( max( FRA.raw_data, [], 1) );   
FRA.receptive_field.best_frequency = FRA.y_values(ibf);

%% Best Intensity (BI). Intensity with the highest response of spikes.
[~, ibi] = max( max( FRA.raw_data, [], 2) );   
FRA.receptive_field.best_intensity = FRA.x_values(ibi);

%% FUNCTION SLOPES
%%% PERIPHERY RECEPTIVE FIELD
%%% DOWN
%%% HIGHEST RIGHT POINT
hrf = max( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) );
hrd = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) == hrf, 2 ) );
%%% LOWEST RIGHT POINT
% lrd = min( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) );
% lrf = max( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) == lrd, 1 )) );
lrd = min(FRA.x_values);
lrf = FRA.receptive_field.response_threshold;

x1 = [ hrf, lrf ];
y1 = [ hrd, lrd ];

FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF = polyfit( x1, y1, 1 );

%%% HIGHEST LEFT POINT
hlf = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) );
hld = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) == hlf, 2 ) );
%%% LOWEST LEFT POINT
% lld = min( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) );
% llf = min( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) == lld, 1 )) );
lld = min(FRA.x_values);
llf = FRA.receptive_field.response_threshold;

x2 = [ hlf, llf ];
y2 = [ hld, lld ];

FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF = polyfit( x2, y2, 1 );

%%% CORE RECEPTIVE FIELD
%%% DOWN
%%% HIGHEST RIGHT POINT
hrf = max( FRA.receptive_field.core_receptive_field.core_bounds(:,1) );
hrd = min( FRA.receptive_field.core_receptive_field.core_bounds( FRA.receptive_field.core_receptive_field.core_bounds(:,1) == hrf, 2 ) );
%%% LOWEST RIGHT POINT
% lrd = min( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) );
% lrf = max( round(FRA.receptive_field.core_receptive_field.core_bounds( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) == lrd, 1 )) );
lrd = min(FRA.x_values);
lrf = FRA.receptive_field.response_threshold;

x1 = [ hrf, lrf ];
y1 = [ hrd, lrd ];

FRA.receptive_field.core_receptive_field.down_right_slope_CRF = polyfit( x1, y1, 1 );

%%% HIGHEST LEFT POINT
hlf = min( FRA.receptive_field.core_receptive_field.core_bounds(:,1) );
hld = min( FRA.receptive_field.core_receptive_field.core_bounds(FRA.receptive_field.core_receptive_field.core_bounds(:,1) == hlf, 2 ) );
%%% LOWEST LEFT POINT
% lld = min( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) );
% llf = min( round(FRA.receptive_field.core_receptive_field.core_bounds( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) == lld, 1 )) );
lld = min(FRA.x_values);
llf = FRA.receptive_field.response_threshold;

x2 = [ hlf, llf ];
y2 = [ hld, lld ];

FRA.receptive_field.core_receptive_field.down_left_slope_CRF = polyfit( x2, y2, 1 );

%% Distance to BF from CF in octaves
FRA.receptive_field.distance_to_BF_from_CF =...
    log2( ... % log2( f2 / f1 )
    sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels )...
    / sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels) );
end

