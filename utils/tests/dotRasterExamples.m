% $Author: DRTorresRuiz$

% First load the trials (example in `readingTrials.m` file)
readingTrials

%% Using one trial

    % Spikes grouped by passes.
    plotDotRasters(trials.Neuron2(1), 2, 1:4, []);

    % Spikes grouped by Freq (Hz).
    plotDotRasters(trials.Neuron2(1), 2, [], []);

    % Spikes grouped by Sweeps
    plotDotRasters(trials.Neuron2(1), 2, [], [], false);

    % Spikes grouped by Freq - showing Real Time for each pass.
    plotDotRasters(trials.Neuron2(1), 2, [], [], true, false);


%% Grouping trials by dB SPL

    % Spikes grouped by passes.
    plotDotRasters(trials.Neuron2, 2, 1:4, 0:10:80);

    % Spikes grouped by Freq (Hz).
    plotDotRasters(trials.Neuron2, 2, [], 0:10:80);

    % Spikes grouped by Sweeps
    plotDotRasters(trials.Neuron2, 2, [], 0:10:80, false);

    % Spikes grouped by Freq - showing Real Time for each pass.
    plotDotRasters(trials.Neuron2, 2, [], 0:10:80, true, false);
