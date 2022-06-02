% $Author: DRTorresRuiz$

% First load the trials (example in `readingTrials.m` file)
readingTrials

figurePosition = [100 100 1500 800];
%% Using one trial

    % Spikes grouped by passes.
%     im = plotTimeDotRasters(trials.Neuron2(1), 2, 1:4, [], false, true, figurePosition);

    % Spikes grouped by Freq (Hz).
%     im = plotTimeDotRasters(trials.Neuron2(1), 2, [], [], true, true, figurePosition);

    % Spikes grouped by Sweeps
%     im = plotTimeDotRasters(trials.Neuron2(1), 2, [], [], false, true, figurePosition);

    % Spikes grouped by Freq - showing Real Time for each pass.
%     im = plotTimeDotRasters(trials.Neuron2(1), 2, [], [], true, false, figurePosition);


%% Grouping trials by dB SPL

    % Spikes grouped by passes.
%     im = plotTimeDotRasters(trials.Neuron2, 2, 1:4, 0:10:80, false, true, figurePosition);

    % Spikes grouped by Freq (Hz).
    im = plotTimeDotRasters(trials.Neuron2, 2, [], 0:10:80, true, true, figurePosition);

    % Spikes grouped by Sweeps
%     im = plotTimeDotRasters(trials.Neuron2, 2, [], 0:10:80, false, true, figurePosition);

    % Spikes grouped by Freq - showing Real Time for each pass.
%     im = plotTimeDotRasters(trials.Neuron2, 2, [], 0:10:80, true, false, figurePosition);

%% Save into a GIF image
saveGIF('animatedDotRaster.gif', im(end:-1:1) );
