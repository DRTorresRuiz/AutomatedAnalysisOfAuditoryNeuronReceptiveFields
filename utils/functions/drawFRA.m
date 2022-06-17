function p = drawFRA(FRA, Title, subTitle, xLabel, yLabel, x_ticks, y_ticks, x_tick_labels, y_tick_labels, sweeps, channels, showPeriphery, showCore, showBF, showCF, showMT, showSlopes, showColorbar)
%DRAWFRA Summary of this function goes here
%   Detailed explanation goes here
arguments
    FRA
    Title = ""
    subTitle = ""
    xLabel = "Freq (KHz)"
    yLabel = {'Sound Level', '(dB SPL)'}
    x_ticks = FRA.y_values
    y_ticks = FRA.x_values
    x_tick_labels = x_ticks
    y_tick_labels = y_ticks
    sweeps = []
    channels = 1
    showPeriphery = true
    showCore = true
    showBF = true
    showCF = true
    showMT = true
    showSlopes = true
    showColorbar = true
end
    function [xi, yi] = getPolygon( x, y, x_values, y_values )
            xi = x;
            yi = y;
            if xi(end) >= max(x_values) 
                xi = [xi; max(x_values)];
                yi = [yi; max(y_values)];
            elseif xi(1) >= max(x_values)
                xi = [max(x_values); xi];
                yi = [max(y_values); yi];
            end

            if xi(1) <= min(x_values) 
                xi = [min(x_values); xi];
                yi = [max(y_values); yi];
            elseif x(end) <= min(x_values)
                xi = [xi; min(x_values)];
                yi = [yi; max(y_values)];
            end
    end

    p = pcolor(x_ticks, y_ticks, FRA.transform.conv);
    
    p.FaceColor = 'interp';
    p.EdgeColor = 'white';
    p.EdgeAlpha = 0.1;
    hold on
    if showPeriphery
        [xp, yp] = getPolygon( ...
            FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1),...
            FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2),...
            x_ticks, y_ticks );
        pgon = polyshape( xp, yp ); 
        plot( pgon, 'FaceColor', 'none', 'EdgeColor', '#EDB120', 'LineWidth', 1 );
    end
    
    if showCore
        [xp, yp] = getPolygon( ...
            FRA.receptive_field.core_receptive_field.core_bounds(:,1),...
            FRA.receptive_field.core_receptive_field.core_bounds(:,2),...
            x_ticks, y_ticks );
        pgon = polyshape( xp, yp ); 
        plot( pgon, 'FaceColor', 'none', 'EdgeColor', '#A2142F', 'LineWidth', 1 );
    end
    
    if showBF
        plot( FRA.receptive_field.best_frequency, FRA.receptive_field.best_intensity, 'kp', 'linewidth', 2 );
        if ~isempty(sweeps)
            txt = sprintf('\n\n\n BF\n%0.2f (KHz)', sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels ) / 1000 );
        else
            txt = sprintf('\n\n\n BF\n%0.2f (KHz)', FRA.receptive_field.best_frequency / 1000 );
        end
        text(FRA.receptive_field.best_frequency,...
            FRA.receptive_field.best_intensity,txt, 'FontSize',10, 'HorizontalAlignment', 'center'  );
    end
    
    if showCF
        if ~isempty(sweeps)
            cf = sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels );
        else
            cf = FRA.receptive_field.response_threshold;
        end
        txt = sprintf(' CF\n %0.2f (KHz)', cf / 1000);
        xl = xline( FRA.receptive_field.response_threshold, 'w-', {txt}, 'linewidth', 2 );
        xl.LabelVerticalAlignment = 'bottom';
        if FRA.receptive_field.response_threshold > FRA.y_values(end-round(length(FRA.y_values)/5)) 
            xl.LabelHorizontalAlignment = 'left';
        else
            xl.LabelHorizontalAlignment = 'right';
        end
        xl.LabelOrientation = 'horizontal';
        xl.FontSize = 9;
    end
    
    if showMT
        
        txt = sprintf(' Min Threshold\n %0.2f (dB SPL)', FRA.receptive_field.minimum_threshold);
        yl = yline( FRA.receptive_field.minimum_threshold, 'w-', {txt}, 'linewidth', 2 );
        
        if FRA.receptive_field.minimum_threshold > FRA.x_values(end-2)
            yl.LabelVerticalAlignment = 'bottom';
        else
            yl.LabelVerticalAlignment = 'top';
        end
        
        yl.LabelHorizontalAlignment = 'left';
        yl.FontSize = 9;
    end
    
    if showSlopes
        
        x_continuous = min(x_ticks):0.001:max(x_ticks);
        
        %%% Periphery RF
        % right
        f = @(x) FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF(1) * x + FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF(2);
        % left
        g = @(x) FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF(1) * x + FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF(2);
        fy = f( x_continuous );
        gy = g( x_continuous );
        plot( x_continuous( fy > FRA.receptive_field.minimum_threshold ), fy( fy > FRA.receptive_field.minimum_threshold ), 'y:', 'linewidth',2 );
        plot( x_continuous( gy > FRA.receptive_field.minimum_threshold ), gy( gy > FRA.receptive_field.minimum_threshold ), 'y:', 'linewidth',2 );
       
        
        %%% Core RF
        % right
        f = @(x) FRA.receptive_field.core_receptive_field.down_right_slope_CRF(1) * x + FRA.receptive_field.core_receptive_field.down_right_slope_CRF(2);
        % left
        g = @(x) FRA.receptive_field.core_receptive_field.down_left_slope_CRF(1) * x + FRA.receptive_field.core_receptive_field.down_left_slope_CRF(2);
        fy = f( x_continuous );
        gy = g( x_continuous );
        plot( x_continuous( fy > FRA.receptive_field.minimum_threshold ), fy( fy > FRA.receptive_field.minimum_threshold ), 'r:', 'linewidth',2 );
        plot( x_continuous( gy > FRA.receptive_field.minimum_threshold ), gy( gy > FRA.receptive_field.minimum_threshold ), 'r:', 'linewidth',2 );
    end
    
    xlabel(xLabel);
    ylabel(yLabel);
    
    xlim([min(x_ticks), max(x_ticks)]);
    ylim([min(y_ticks), max(y_ticks)]);
    if ~isempty(sweeps)
        xticks(x_ticks);
        xticklabels( round( x_tick_labels / 1000, 3) );
    end
    yticks(y_ticks);
    yticklabels( y_tick_labels );
    [t, s] = title(Title, {subTitle, ""});
    t.FontSize = 16;
    s.FontAngle = 'italic';

    % Colorbar
    if showColorbar
        caxis([0, max(FRA.transform.conv, [], 'all')]);
        c = colorbar;
        c.Label.Position(1) = 0;
        c.Label.String = "Spike rate";
    end
    drawnow;
end

