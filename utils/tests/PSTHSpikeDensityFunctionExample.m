% $Author: DRTorresRuiz$

%% LOAD TRIALS 
readingTrials

%% CONFIGURABLE VARIABLES
kernel = false; % If false plot PSTH
db = 70;
isRelative = true;
showFreq = true;
property = "Sweep";

%% GET NEURON TRIALS
t = trials.Neuron2;

%% GET COMMON INFORMATION FOR ALL NEURON TRIALS
sweep_number = t(1).Num_Sweeps;
delay = t(1).Delay;
duration = t(1).Duration;
interval = t(1).Rep_Interval;
channels = t(1).Channels;
sweeps = t(1).getSweeps();

%% AXIS VARIABLES 
y_ticks = 1:sweep_number;
if isRelative
    x_values = 0:interval;
else
    x_values = 0:(interval*sweep_number);
end

%% GROUP TRIALS BY INTENSITY (DB SPL)
groupedTrials = groupTrialsByLevel(t, db);
spikes = getAllSpikes(groupedTrials(1).Trials);

%% GET ALL POINTS
[x, y] = getPoints( spikes, property, sweep_number, interval, isRelative );

%% PLOT TIME SPIKE RASTER WITH PSTH OR SPIKE DENSITY FUNCTION.
f = figure;
f.Position = [ 100 100 1250 800 ];

subplot(7,7,[1:7 8:14 15:21 22:28 29:35 36:42]);
hold on

    timeSpikeRaster(x, y, y_ticks, property,...
        "Spike Raster", "Level: " +db+" dB SPL", showFreq, channels, sweeps );
    plotStimBlock(delay, duration, interval, sweep_number, isRelative);
    set(gca,'xlabel',[]) % Remove x label to avoid duplication

hold off

subplot(7,7,43:49);
hold on;

    if kernel % Plot Spike Density Function
        % Using an updated version of Shimazaki's `ssvkernel()` function.
        values = ssvkernel( x, x_values, true ); % Set last value to true to plot

    else % Plot PSTH
        values = PSTH( x, x_values );
    end
    yline( mean(values), 'LineStyle', ':', 'Color', 'r', 'LineWidth', 2);
    plotStimBlock( delay, duration, interval, sweep_number, isRelative )

hold off;



