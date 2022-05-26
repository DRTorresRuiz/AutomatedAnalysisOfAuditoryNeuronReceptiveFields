function plotTimeDotRasters(trials, neuronNumber, passes, levels, showFreq, isRelative, figurePosition)
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
% To see more examples, refer to the documentation.
%
% $Author: DRTorresRuiz$
arguments
    trials (1,:) Trial
    neuronNumber (1,1)
    passes (1,:) {mustBeNumeric} = []
    levels (1,:) {mustBeNumeric} = []
    showFreq (1,1) logical = true
    isRelative (1,1) logical = true
    figurePosition (1,:) {mustBeNumeric} = []
end
    function [y_ticks, property] = settingPlot(num_sweeps, passes)
        if ~isempty(passes)
            % Plot by passes
            y_ticks = passes;
            property = "Pass";
        else
            % Plot by sweeps
            y_ticks = 1:num_sweeps;
            property = "Sweep";
        end
    end

    if isempty(levels)
        
        subTitle = "Neuron: " + neuronNumber;
        for t = trials
            if ~isempty(figurePosition)
                assert( length(figurePosition) == 4, "`figurePosition` argument must contains only 4 values.");
                f = figure;
                f.Position = figurePosition;
            end
            
            % Plot a spike raster for this trial
            Title = "Dot raster plot of Spike Times (dB SPL: " + t.Level + ")"; 
            [y_ticks, property] = settingPlot(t.Num_Sweeps, passes);
            [x, y] = getPoints( t.getSpikes(), property, t.Num_Sweeps, t.Rep_Interval, isRelative );
            timeSpikeRaster(x, y, y_ticks, property, t.Num_Sweeps,...
                t.Rep_Interval, t.Delay, t.Duration, ...
                Title, subTitle, showFreq, t.Channels, t.getSweeps(), isRelative);
        end
    else

        groupedTrials = groupTrialsByLevel(trials, levels);
        subTitle = "Neuron: " + neuronNumber + " (Multiple Trials)";
        for gTrials = groupedTrials
            
            if ~isempty(gTrials.Trials)
                
                t = gTrials.Trials(1);
                spikes = getAllSpikes(gTrials.Trials);
                if ~isempty(figurePosition)
                    f = figure;
                    f.Position = figurePosition;
                end
                Title = "Dot raster plot of Spike Times (dB SPL: " + t.Level + ")";
                [y_ticks, property] = settingPlot(t.Num_Sweeps, passes);
                [x, y] = getPoints( spikes, property, t.Num_Sweeps, t.Rep_Interval, isRelative );
                timeSpikeRaster(x, y, y_ticks, property, t.Num_Sweeps,...
                    t.Rep_Interval, t.Delay, t.Duration, ...
                    Title, subTitle, showFreq, t.Channels, t.getSweeps(), isRelative);
            end
        end
    end
end

