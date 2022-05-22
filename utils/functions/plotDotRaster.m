function f = plotDotRaster(trials, neuronNumber, passes, levels, showFreq, isRelative, figurePosition)
%PLOTDOTRASTER Given a list of trials, you can configure it to plot
%different dot raster configurations.
%
%  Usage examples:
%
% Plot a single trial for neuron 2:
% >> plotDotRaster(trials.neuron(1), 2 );
%
% Plot the results for all trials grouped by dB SPL, being
% `trials.Neuron2` a list of Trial objects:
% >> plotDotRaster(trials.Neuron2, 2, [], 0:10:80 );
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

    function dotRaster(x, y)        
        s = scatter( x, y, 'filled', '|');
        s.SizeData = 100;
        s.MarkerEdgeColor = 'k';
        s.MarkerFaceColor = [0 0.5 0.5];
    end

    function f = setFigure(f, sets, interval, delay, duration, num_sweeps, ...
            property, Title, subTitle, showFreq, isRelative, figurePosition)
        f.Position = figurePosition;
        ax = gca;
        ax.XGrid = 'off';
        ax.YGrid = 'on';
        title( Title, subTitle );
        
        yticks(sets);
        if showFreq && isequal(property, "Sweep")
            ylim([min(sets)-(min(sets)/2), max(sets)+max(sets)/2]);
            y_textlabel = {"Freq (Hz)", "[Log scale]"};
            set(gca, 'YScale', 'log')
            set(gca, 'YMinorTick','off')
            ax.YMinorGrid = 'off';
        else
            ylim([min(sets)-1,max(sets)+1]);
            y_textlabel = property + " number";
        end
        ylabel(y_textlabel);
        
        plotStimBlock(delay, duration, interval, num_sweeps,...
            isRelative);
    end

    function [sets, property] = settingPlot(num_sweeps, passes)
        if ~isempty(passes)
            % Plot by passes
            sets = passes;
            property = "Pass";
        else
            % Plot by sweeps
            sets = 1:num_sweeps;
            property = "Sweep";
        end
    end

    function f = plotTrial(passes, spikes, num_sweeps, rep_Interval, delay, ...
            duration, Title, subTitle, showFreq, channels, sweeps, isRelative, figurePosition)
        
        [sets, property] = settingPlot(num_sweeps, passes);
        
        [x, y] = getPoints( spikes, property, num_sweeps, rep_Interval,...
             isRelative );
        
        if showFreq && isequal(property, "Sweep")
            % Replace sweep number by frequency
            for i = 1:length(y)
                y(i) = sweeps( y(i) * channels - (channels - 1) ).CarFreq;
            end
            
            for i = 1:max(sets)
                sets(i) = sweeps( sets(i) * channels - (channels - 1) ).CarFreq;
            end
        end
        
        f = figure;
        hold on;

        dotRaster(x, y);
        
        f = setFigure(f, sets, rep_Interval, delay, duration, num_sweeps, ...
            property, Title, subTitle, showFreq, isRelative, figurePosition);
        hold off;
    end

    if isempty(levels)
        
        subTitle = "Neuron: " + neuronNumber;
        for t = trials
            Title = "Dot raster plot of Spike Times (dB SPL: " + t.Level + ")";    
            f = plotTrial(passes, t.getSpikes(), t.Num_Sweeps,...
                t.Rep_Interval, t.Delay, t.Duration, ...
                Title, subTitle, showFreq, t.Channels, t.getSweeps(), ...
                isRelative, figurePosition);
        end
    else

        groupedTrials = groupTrialsByLevel(trials, levels);
        subTitle = "Neuron: " + neuronNumber + " (Multiple Trials)";
        for gTrials = groupedTrials
            
            if ~isempty(gTrials.Trials)
                
                t = gTrials.Trials(1);
                spikes = getAllSpikes(gTrials.Trials);
                Title = "Dot raster plot of Spike Times (dB SPL: " + t.Level + ")";
                f = plotTrial(passes, spikes, t.Num_Sweeps,...
                    t.Rep_Interval, t.Delay, t.Duration, ...
                    Title, subTitle, showFreq, t.Channels, t.getSweeps(),...
                    isRelative, figurePosition);
            end
        end
    end
end

