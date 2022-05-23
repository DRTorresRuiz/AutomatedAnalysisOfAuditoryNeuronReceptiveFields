function f = plotDotRasters(trials, neuronNumber, passes, levels, showFreq, isRelative, figurePosition)
%PLOTDOTRASTER Given a list of trials, you can configure it to plot
%different dot raster configurations.
%
%  Usage examples:
%
% Plot a single trial for neuron 2:
% >> plotDotRasters(trials.neuron(1), 2 );
%
% Plot the results for all trials grouped by dB SPL, being
% `trials.Neuron2` a list of Trial objects:
% >> plotDotRasters(trials.Neuron2, 2, [], 0:10:80 );
%
% $Author: DRTorresRuiz$
arguments
    trials (1,:) Trial
    neuronNumber (1,1)
    passes (1,:) {mustBeNumeric} = []
    levels (1,:) {mustBeNumeric} = []
    showFreq (1,1) logical = true
    isRelative (1,1) logical = true
    figurePosition (1,4) {mustBeNumeric} = [100 100 1500 800]
end

    if isempty(levels)
        
        subTitle = "Neuron: " + neuronNumber;
        for t = trials
            f = figure;
            Title = "Dot raster plot of Spike Times (dB SPL: " + t.Level + ")";    
            plotSpikeRaster(t.getSpikes(), passes, t.Num_Sweeps,...
                t.Rep_Interval, t.Delay, t.Duration, ...
                Title, subTitle, showFreq, t.Channels, t.getSweeps(), ...
                isRelative);
            f.Position = figurePosition;
        end
    else

        groupedTrials = groupTrialsByLevel(trials, levels);
        subTitle = "Neuron: " + neuronNumber + " (Multiple Trials)";
        for gTrials = groupedTrials
            
            if ~isempty(gTrials.Trials)
                
                t = gTrials.Trials(1);
                spikes = getAllSpikes(gTrials.Trials);
                f = figure;
                Title = "Dot raster plot of Spike Times (dB SPL: " + t.Level + ")";
                plotSpikeRaster( spikes, passes, t.Num_Sweeps,...
                    t.Rep_Interval, t.Delay, t.Duration, Title, subTitle, ...
                    showFreq, t.Channels, t.getSweeps(), isRelative);
                f.Position = figurePosition;
            end
        end
    end
end

