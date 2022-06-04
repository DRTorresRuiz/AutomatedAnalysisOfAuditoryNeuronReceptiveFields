% $Author: DRTorresRuiz$

%% READ TRIALS
readingTrials

%% CONFIGURE EXAMPLE VARIABLES
cleanSA = false; 

%% LOAD COMMON INFORMATION
t = trials.Neuron2;

num_sweeps = t(1).Num_Sweeps;
interval = t(1).Rep_Interval;
delay = t(1).Delay;
duration = t(1).Duration;
channels = t(1).Channels;
sweeps = t(1).getSweeps();

showFreq = true;

x_interval = 1;
x_ticks = 0:10:interval; % Time
x_values = 0:x_interval:interval;

y_interval = 1;
y_ticks = 1:y_interval:num_sweeps; % Sweeps
z_interval = 10;
z_ticks = 0:z_interval:80; % dB SPL

%% GET GROUPED TRIALS

groupedTrials = groupTrialsByLevel(t, z_ticks);
%% GET X, Y, Z values
[x, y, z] = get3DPoints( groupedTrials );
y_values = unique(y);
z_values = unique(z);

%% GET PROBABILITY DISTRIBUTION FUNCTION
probs = getProbabilities( x, x_values, y, y_values, z, z_values,...
    delay, duration, interval );
max_prob = max(probs, [], 'all');

%% CLEAN SPONTANEOUS ACTIVITY ACCORDING TO THE BASE CASE
if cleanSA
    [response, sa, threshold] = getSpontaneousActivity( x, y, z, probs, probs( z == 0 ) );
    
    %% PLOT SA.
    if ~isempty(sa)
        Title = "SA";
        subTitle = "Freq vs dB SPL vs Time";
        f = figure;
        f.Position = [ 100 100 1000 800 ];
        spikeRaster3D( sa(:,1), sa(:,2), sa(:,3), sa(:,4), threshold, interval, max_prob, Title, subTitle,...
            x_ticks, y_ticks, z_ticks, x_ticks, sweepToFreq(y_ticks, sweeps, channels), z_ticks, 40, 0.2 );
    end

    %% PLOT RESPONSE
    if ~isempty(response)
        Title = "SPIKES w/o SA";
        subTitle = "Freq vs dB SPL vs Time";
        f = figure;
        f.Position = [ 100 100 1000 800 ];
        spikeRaster3D( response(:,1), response(:,2), response(:,3), response(:,4), threshold, interval, max_prob, Title, subTitle,...
            x_ticks, y_ticks, z_ticks, x_ticks, sweepToFreq(y_ticks, sweeps, channels), z_ticks, 40, 0.4 );
    end

end

%% PLOT ALL SPIKES
Title = "All spikes";
subTitle = "Freq vs dB SPL vs Time";
f = figure;
f.Position = [ 100 100 1000 800 ];
spikeRaster3D( x, y, z, probs, 0, interval, max_prob, Title, subTitle,...
   x_ticks, y_ticks, z_ticks, ...
   x_ticks, sweepToFreq(y_ticks, sweeps, channels), z_ticks, 40, 0.4 );

