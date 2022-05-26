function timeSpikeRaster( x, y, y_ticks, property, num_sweeps, interval, delay, ...
            duration, Title, subTitle, showFreq, channels, sweeps, isRelative)
%TIMESPIKERASTER Plot a Spike Raster with the specified arguments.
%   The difference with `plotDotRaster` is that `plotDotRaster()` accepts a
%   list of Trials and plot them all.
%   This function is mainly used to plot the figure.
%
%  Usage examples:
%
% >> timeSpikeRaster(x, y, y_ticks, "Sweep", [], 25, 250, 10, 75,...
%      "Spike Raster", "Level: 80 dB SPL", true, 2, t(1).getSweeps(), true)
%
% To see more examples, refer to the documentation.
%
% $Author: DRTorresRuiz$
        
        function setFigure( y_ticks, property, Title, subTitle, showFreq )

            ax = gca;
            ax.XGrid = 'off';
            ax.YGrid = 'on';
            title( Title, subTitle );
            yticks(y_ticks);
            if showFreq && isequal(property, "Sweep")
                ylim([min(y_ticks)-(min(y_ticks)/2), max(y_ticks)+max(y_ticks)/2]);
                y_textlabel = {"Freq (Hz)", "[Log scale]"};
                set(gca, 'YScale', 'log')
                set(gca, 'YMinorTick','off')
                ax.YMinorGrid = 'off';
            else
                ylim([min(y_ticks)-1,max(y_ticks)+1]);
                y_textlabel = property + " number";
            end
            ylabel(y_textlabel);
        end
        
        if showFreq && isequal(property, "Sweep")
            % Replace sweep number by frequency
            y = sweepToFreq( y, sweeps, channels );
            y_ticks = sweepToFreq( y_ticks, sweeps, channels );
        end
        
        dotRaster(x, y);
        setFigure(y_ticks, property, Title, subTitle, showFreq );      
        plotStimBlock(delay, duration, interval, num_sweeps, isRelative);
    end