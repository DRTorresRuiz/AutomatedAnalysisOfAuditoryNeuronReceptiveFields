function [s, c] = spikeRaster3D( x, y, z, p, threshold, interval, max_p, Title, subTitle, ...
    x_ticks, y_ticks, z_ticks, x_tick_labels, y_tick_labels, z_tick_labels, ...
    point_size, point_alpha, labels, lim, colorbarLabel)
%SPIKERASTER3D Plot a time spike raster in 3D, considering its frequencies (y),
% intensities (z), and probabilities (p).
%
% Usage example:
%
% >> s = spikeRaster3D( x, y, z, probabilities )
%
% $Author: DRTorresRuiz$
arguments
    x
    y
    z
    p
    threshold = 0
    interval = max(x)
    max_p = max(p, [], 'all')
    Title = ""
    subTitle = ""
    x_ticks = round(min(x)):round(max(x))
    y_ticks = round(min(y)):round(max(y))
    z_ticks = round(min(z)):round(max(z))
    x_tick_labels = x_ticks
    y_tick_labels = y_ticks
    z_tick_labels = z_ticks
    point_size = 40
    point_alpha = 0.6
    labels = ["Time (ms)", "Freq (Hz)", "Sound Level (dB SPL)" ]
    lim = [ -10 interval; min(y_ticks)-1 max(y_ticks)+1; min(z_ticks)-10 max(z_ticks)+10 ]
    colorbarLabel = "Probability Distribution"
end
 
    s = scatter3(x, y, z, point_size, p, 'filled');
    s.MarkerFaceAlpha = point_alpha;

    % X Axis
    xlabel(labels(1));
    xlim(lim(1,:));
    xticks(x_ticks);
    xticklabels(x_tick_labels);
    
    % Y Axis
    ylabel(labels(2));
    ylim(lim(2,:));
    yticks(y_ticks);
    yticklabels(y_tick_labels);

    % Z Axis
    zlabel(labels(3));
    zlim(lim(3,:));
    zticks(z_ticks);
    zticklabels(z_tick_labels);

    % Title
    title(Title, subTitle);
    
    % Colorbar
    caxis([0, max_p]);
    c = colorbar;
    c.Label.Position(1) = 0;
    c.Label.String = colorbarLabel;

    % Create a mark in the colorbar that indicates the threshold value
    if threshold > 0
        haxes = axes('position',c.Position,'color','none', ...
            'ytick', [], 'ylim', [0, max_p],'xtick',[]);
        hold on;
        plot(haxes,[-5 5],[threshold threshold],...
            'color',[ 1 1 1 0.3],'LineWidth', 4 );
        axis off;
        hold off;
    end
end

