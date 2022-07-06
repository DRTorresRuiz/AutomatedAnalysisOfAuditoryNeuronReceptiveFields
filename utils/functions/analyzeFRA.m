function FRA = analyzeFRA( FRA, sweeps, channels, additional_interval, kernel )
%ANALYZEFRA 
arguments
    FRA
    sweeps = []
    channels = []
    additional_interval = 10
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

FRA.stats.x_size = length(FRA.x_values);
FRA.stats.y_size = length(FRA.y_values);

if ~isempty(FRA.y_values)
    FRA.stats.max_y = max(FRA.y_values);
    FRA.stats.min_y = min(FRA.y_values);
end
m_y = min(diff(FRA.y_values));
y_values = [ (FRA.y_values(1) - additional_interval * m_y):m_y:(FRA.y_values(1) - m_y), FRA.y_values, (FRA.y_values(end) + m_y):m_y:(FRA.y_values(end) + additional_interval * m_y) ];

if ~isempty(FRA.x_values)
    FRA.stats.max_x = max(FRA.x_values);
    FRA.stats.min_x = min(FRA.x_values);
end
m_x = min(diff(FRA.x_values));
x_values = [ (FRA.x_values(1) - additional_interval * m_x):m_x:(FRA.x_values(1) - m_x), FRA.x_values, (FRA.x_values(end) + m_x):m_x:(FRA.x_values(end) + additional_interval * m_x) ];

% if size(FRA.raw_data) ~=
if size(FRA.raw_data) ~= [length(x_values), length(y_values)]
    new_raw_data = zeros(length(x_values), length(y_values));
	new_raw_data( (additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval) ) = FRA.raw_data;
    FRA.raw_data = new_raw_data;
end

FRA.transform.normalized = FRA.raw_data / sum(FRA.raw_data, 'all');
FRA.stats.mean = mean(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)), 'all');
FRA.stats.median = median(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)), 'all');
FRA.stats.mode = mode(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)),'all');
FRA.stats.std = std(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)), [], 'all');
FRA.stats.var = var(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)), [], 'all');
FRA.stats.max = max(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)), [], 'all');
FRA.stats.min = min(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)), [], 'all');
%%% Smooth convolution
% FRA.transform.conv = conv2(FRA.transform.normalized, [ 1 1 1; 1 1 1; 1 1 1], 'same'); 
% FRA.transform.conv = conv2(FRA.transform.normalized, kernel, 'same');
FRA.transform.conv = conv2(FRA.raw_data, kernel, 'same');
FRA.transform.conv = FRA.transform.conv * ( max(FRA.raw_data, [], 'all') / max(FRA.transform.conv, [], 'all') );
%%% Negative smooth convolution
% FRA.transform.negconv = conv2(FRA.transform.normalized, [ -1 -1 -1; -1 -1 -1; -1 -1 -1], 'same'); 
FRA.transform.negconv = conv2(FRA.transform.normalized, (-1)*kernel, 'same'); 

realConv = FRA.transform.conv((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval));
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
FRA.stats.spikes_per_freq = [FRA.y_values', sum(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)),1)'];
%%% Total spikes per dB
FRA.stats.spikes_per_db = [FRA.x_values', sum(FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval)),2)];

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
y_points = repmat( y_values((additional_interval+1):(end-additional_interval)), 1, FRA.stats.x_size );
z_points = repmat( x_values((additional_interval+1):(end-additional_interval)), 1, FRA.stats.y_size );
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
FRA.raw_data = FRA.raw_data((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval));
FRA.transform.normalized = FRA.transform.normalized(11:end-10, 11:end-10);
FRA.transform.conv = realConv;
FRA.transform.negconv = FRA.transform.negconv((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval));
FRA.receptive_field.rf_mask = FRA.receptive_field.rf_mask((additional_interval+1):(end-additional_interval), (additional_interval+1):(end-additional_interval));

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
[~, ibf] = max( max( FRA.transform.conv, [], 1) );   
% [~, ibf] = max( max( FRA.raw_data, [], 1) );   
FRA.receptive_field.best_frequency = FRA.y_values(ibf);

%% Best Intensity (BI). Intensity with the highest response of spikes.
[~, ibi] = max( max( FRA.transform.conv, [], 2) ); 
% [~, ibi] = max( max( FRA.raw_data, [], 2) ); 
FRA.receptive_field.best_intensity = FRA.x_values(ibi);

%% FUNCTION SLOPES
%%% PERIPHERY RECEPTIVE FIELD
%%% DOWN
%%% HIGHEST RIGHT POINT
hrf = max( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) );
hrd = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) == hrf, 2 ) );
% hrf = mean( FRA.receptive_field.periphery_receptive_field.periphery_bounds(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) >= FRA.receptive_field.response_threshold,1) );
% hrd = mean( FRA.receptive_field.periphery_receptive_field.periphery_bounds(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) >= FRA.receptive_field.minimum_threshold,2) );
%%% LOWEST RIGHT POINT
% lrd = min( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) );
% lrf = max( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) == lrd, 1 )) );
lrd = FRA.receptive_field.minimum_threshold;
lrf = FRA.receptive_field.response_threshold;

x1 = [ hrf, lrf ];
y1 = [ hrd, lrd ];

FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF = polyfit( x1, y1, 1 );

%%% HIGHEST LEFT POINT
hlf = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) );
hld = min( FRA.receptive_field.periphery_receptive_field.periphery_bounds( FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) == hlf, 2 ) );
% hlf = mean( FRA.receptive_field.periphery_receptive_field.periphery_bounds(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1) < FRA.receptive_field.response_threshold,1) );
% hld = mean( FRA.receptive_field.periphery_receptive_field.periphery_bounds(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2) >= FRA.receptive_field.minimum_threshold,2) );
%%% LOWEST LEFT POINT
% lld = min( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) );
% llf = min( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds( round(FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2)) == lld, 1 )) );
lld = FRA.receptive_field.minimum_threshold;
llf = FRA.receptive_field.response_threshold;

x2 = [ hlf, llf ];
y2 = [ hld, lld ];

FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF = polyfit( x2, y2, 1 );

%%% CORE RECEPTIVE FIELD
%%% DOWN
%%% HIGHEST RIGHT POINT
hrf = max( FRA.receptive_field.core_receptive_field.core_bounds(:,1) );
hrd = min( FRA.receptive_field.core_receptive_field.core_bounds( FRA.receptive_field.core_receptive_field.core_bounds(:,1) == hrf, 2 ) );
% hrf = mean( FRA.receptive_field.core_receptive_field.core_bounds(FRA.receptive_field.core_receptive_field.core_bounds(:,1) >= FRA.receptive_field.response_threshold,1) );
% hrd = mean( FRA.receptive_field.core_receptive_field.core_bounds(FRA.receptive_field.core_receptive_field.core_bounds(:,2) >= FRA.receptive_field.minimum_threshold,2) );
%%% LOWEST RIGHT POINT
% lrd = min( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) );
% lrf = max( round(FRA.receptive_field.core_receptive_field.core_bounds( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) == lrd, 1 )) );
lrd = FRA.receptive_field.minimum_threshold;
lrf = FRA.receptive_field.response_threshold;

x1 = [ hrf, lrf ];
y1 = [ hrd, lrd ];

FRA.receptive_field.core_receptive_field.down_right_slope_CRF = polyfit( x1, y1, 1 );

%%% HIGHEST LEFT POINT
hlf = min( FRA.receptive_field.core_receptive_field.core_bounds(:,1) );
hld = min( FRA.receptive_field.core_receptive_field.core_bounds(FRA.receptive_field.core_receptive_field.core_bounds(:,1) == hlf, 2 ) );
% hlf = mean( FRA.receptive_field.core_receptive_field.core_bounds(FRA.receptive_field.core_receptive_field.core_bounds(:,1) < FRA.receptive_field.response_threshold,1) );
% hld = mean( FRA.receptive_field.core_receptive_field.core_bounds(FRA.receptive_field.core_receptive_field.core_bounds(:,2) >= FRA.receptive_field.minimum_threshold,2) );
%%% LOWEST LEFT POINT
% lld = min( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) );
% llf = min( round(FRA.receptive_field.core_receptive_field.core_bounds( round(FRA.receptive_field.core_receptive_field.core_bounds(:,2)) == lld, 1 )) );
lld = FRA.receptive_field.minimum_threshold;
llf = FRA.receptive_field.response_threshold;

x2 = [ hlf, llf ];
y2 = [ hld, lld ];

FRA.receptive_field.core_receptive_field.down_left_slope_CRF = polyfit( x2, y2, 1 );

%% Distance to BF from CF in octaves
if ~isempty(sweeps)
FRA.receptive_field.distance_to_BF_from_CF =...
    log2( ... % log2( f2 / f1 )
    sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels )...
    / sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels) );
else
FRA.receptive_field.distance_to_BF_from_CF =...
    log2( ... % log2( f2 / f1 )
    FRA.receptive_field.best_frequency...
    / FRA.receptive_field.response_threshold );    
end
%% Q10
index_minimum_threshold = ceil( FRA.receptive_field.minimum_threshold / m_x ) + 1;
FRA.receptive_field.discrete_minimum_threshold = FRA.x_values( index_minimum_threshold );
q10_values = FRA.receptive_field.periphery_receptive_field.width_PRF( index_minimum_threshold + 1, :);
if ~isempty(sweeps)
    left = sweepToFreq( q10_values(1), sweeps, channels );
    right = sweepToFreq( q10_values(2), sweeps, channels );
else
    left = q10_values(1);
    right = q10_values(2);
end

result = [ left, right, right-left ];
FRA.receptive_field.Q10_bandwidth = result;
if ~isempty(sweeps)
    FRA.receptive_field.Q10 = sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels) / result(3);
else
    FRA.receptive_field.Q10 = FRA.receptive_field.response_threshold / result(3);
end

end

