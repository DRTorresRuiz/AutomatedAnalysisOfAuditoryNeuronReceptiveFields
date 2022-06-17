function FRA = getFRA( x, y, z, y_values, x_values, additional_interval )
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
    y_values = unique(y)
    x_values = unique(z)
    additional_interval = 10
end

%% Init FRA
FRA.y_values = y_values;
FRA.x_values = x_values;
FRA.raw_data = zeros( length(FRA.x_values), length(FRA.y_values) );

%% Amplify y_values and x_values
m_y = min(diff(y_values));
if ~isempty(y_values)
    y_values = [ (y_values(1) - additional_interval * m_y):m_y:(y_values(1) - m_y), y_values, (y_values(end) + m_y):m_y:(y_values(end) + additional_interval * m_y) ];
end

 m_x = min(diff(x_values));
 if ~isempty(x_values)
    x_values = [ (x_values(1) - additional_interval * m_x):m_x:(x_values(1) - m_x), x_values, (x_values(end) + m_x):m_x:(x_values(end) + additional_interval * m_x) ];
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

end

