% $Author: DRTorresRuiz$

%% Random examples. 

% Noisy Raster
samples = 1000;
sweeps = 10;
interval = 250;
delay = 10;
duration = 75;

x = rand(1, samples) * interval;
freqs = mod( round(rand(1, samples)*sweeps), sweeps) + 1;

figure;
timeSpikeRaster(x, freqs, 1:sweeps, "Sweeps", sweeps, interval, delay, ...
            duration, "Spike Raster", "Noisy Raster", false, 0, [], true)
        
% Spike simulation

x = [rand(1, 7*samples/10) * duration + delay, rand(1, 3*samples/10) * interval];
freqs = mod( round(rand(1, samples)*sweeps), sweeps) + 1;

figure;
timeSpikeRaster(x, freqs, 1:sweeps, "Sweeps", sweeps, interval, delay, ...
            duration, "Spike Raster", "Spike Simulation", false, 0, [], true)

