function plotSpikeRaster(spikes, passes, num_sweeps, rep_Interval, delay, ...
            duration, Title, subTitle, showFreq, channels, sweeps, isRelative)
%PLOTSPIKERASTER Plot a Spike Raster with the specified arguments.
%   The difference with `plotDotRaster` is that `plotDotRaster()` accepts a
%   list of Trials and plot them all.
%   This function is mainly used to plot the figure.
%
%  Usage examples:
%
% >> plotSpikeRaster(spikes, [], 25, 250, 10, 75,...
%      "Spike Raster", "Level: 80 dB SPL", true, 2, t(1).getSweeps(), true)
%
% $Author: DRTorresRuiz$
        function dotRaster(x, y)        
            s = scatter( x, y, 'filled', '|');
            s.SizeData = 100;
            s.MarkerEdgeColor = 'k';
            s.MarkerFaceColor = [0 0.5 0.5];
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
        
        function setFigure( sets, property, Title, subTitle, showFreq )

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
        end
        
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
        
        hold on;
        dotRaster(x, y);
        setFigure(sets, property, Title, subTitle, showFreq );      
        plotStimBlock(delay, duration, rep_Interval, num_sweeps, isRelative);
        hold off;
    end