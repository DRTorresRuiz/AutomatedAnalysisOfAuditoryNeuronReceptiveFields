function [FRA, im] = plotFRA( trials, levels, Title, subTitle, showPeriphery, showCore, ...
    showBF, showCF, showMT, showSlopes, displayInfo, showFreq, cleanSA, showColorbar,...
    figurePosition, showFigure, saveFigures, saveInformation, saveExcel, output_filename)
%PLOTFRA Given a set of trials for a neuron, plot its FRA.
%
% Usage example:
%
% >> [FRA, im] = plotFRA( t, levels, showPeriphery, showCore, ...
%     showBF, showCF, showSlopes, displayInfo, showFreq,...
%     cleanSA, figurePosition, showFigure );
%
% To see more examples, refer to the documentation.
%
% $Author: DRTorresRuiz$
arguments
    trials (1, :) Trial
    levels
    Title = "Frequency Response Area (FRA)";
    subTitle = "Freq vs dB SPL";
    showPeriphery = true
    showCore = true
    showBF = true
    showCF = true
    showMT = true
    showSlopes = true
    displayInfo = true
    showFreq = true
    cleanSA = false
    showColorbar = true
    figurePosition (1,:) {mustBeNumeric} = []
    showFigure = true
    saveFigures = true
    saveInformation = true
    saveExcel = true
    output_filename = ".\FRA"
end


    function writeExcel( output_filename, FRA, sweeps, channels )
        varNames = { 'Mean', 'Median', 'Mode', 'Standard Deviation', 'Variance', 'Max', 'Min', '#Spikes', 'SA detected (%)' };
        stats = table(  FRA.stats.mean, FRA.stats.median, FRA.stats.mode,...
                FRA.stats.std, FRA.stats.var, FRA.stats.max, FRA.stats.min,...
                FRA.stats.total_spikes, FRA.stats.spontaneous_activity_detected * 100,...
                'VariableNames', varNames );
        writetable(stats, output_filename, 'Sheet', 'Stats' );
        
        varNames = { '#RF_spikes', 'RFArea (%)', 'Mininum_Threshold (dB SPL)', 'Characteristic Frequency, CF, (Hz)',...
            'Best Frequency, BF (Hz)', 'Distance from CF to BF (octaves)', ...
            'RFWidth (Hz)', 'RFWidth Difference (Hz)', 'RFWidth Difference (octaves)', 'Q10', 'Periphery Threshold', 'Core Threshold' };
        
        RFwidth = maxWidthRF(FRA.receptive_field.periphery_receptive_field.width_PRF, sweeps, channels);
        rf = table( FRA.receptive_field.spikes_RF,...
            FRA.receptive_field.area_RF * 100,...
            FRA.receptive_field.minimum_threshold,...
            sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels ),...
            sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels ),...
            FRA.receptive_field.distance_to_BF_from_CF,...
            RFwidth(1:2), RFwidth(3), RFwidth(4), FRA.receptive_field.Q10,...
            FRA.receptive_field.periphery_receptive_field.periphery_threshold,...
            FRA.receptive_field.core_receptive_field.core_threshold,...
             'VariableNames', varNames );
        writetable(rf, output_filename, 'Sheet', 'Receptive Field' );
    end

    im = [];
    
    %% Get common configuration for all trials
    num_sweeps = trials(1).Num_Sweeps;
    interval = trials(1).Rep_Interval;
    delay = trials(1).Delay;
    duration = trials(1).Duration;
    channels = trials(1).Channels;
    sweeps = trials(1).getSweeps();
    num_passes = trials(1).Num_Passes;
    
    %% Get 3D points
    groupedTrials = groupTrialsByLevel(trials, levels);
    [x, y, z] = get3DPoints( groupedTrials );
    total_spikes = length(x);
    
    %% Set variables
%     x_ticks = 0:10:interval;
    x_values = [0 linspace(delay, delay+duration, duration/4) linspace( delay+duration+duration/4, interval, 10)];

    y_ticks = 1:num_sweeps;
    y_values = unique(y);

    z_ticks = levels;
    z_values = unique(z);
    
    %% Get frequecies if required
    if showFreq
        y_tick_labels = sweepToFreq(y_ticks, sweeps, channels);
    else
        y_tick_labels = y_ticks;
    end
    
    %% Clean SA and get spikes without spikes less likely to be a response
    if cleanSA
        probs = getProbabilities( x, x_values, y, y_values, z, z_values,...
            delay, duration, interval );
        [spikes, ~, ~] = getSpontaneousActivity( x, y, z, probs, probs( z == 0 ) );
        if ~isempty(spikes)
            x = spikes(:,1);
            y = spikes(:,2);
            z = spikes(:,3);
        end
    end
    
    %% GET FRA
    
    FRA = getFRA( x, y, z, y_ticks, z_ticks, num_passes );
    FRA = analyzeFRA( FRA, sweeps, channels );
    if cleanSA
        
        FRA.stats.spontaneous_activity_detected = 1 - length(x)/total_spikes;
    else
        FRA.stats.spontaneous_activity_detected = 0;
    end
    
    %% PLOT   
    if showFigure
        f1 = figure;
    else
        f1 = figure('visible', 'off');
    end
    if ~isempty(figurePosition)
        f1.Position = figurePosition;
    end
    
    if showFreq
        drawFRA(FRA, Title, subTitle, "Freq (kHz)", {'Sound Level', '(dB SPL)'},...
            y_ticks, z_ticks, y_tick_labels, levels, sweeps, channels, showPeriphery,...
            showCore, showBF, showCF, showMT, showSlopes, showColorbar);
    else
        drawFRA(FRA, Title, subTitle, "Freq (kHz)", {'Sound Level', '(dB SPL)'},...
            y_ticks, z_ticks, y_tick_labels, levels, [], channels, showPeriphery,...
            showCore, showBF, showCF, showMT, showSlopes, showColorbar);
    end
%     p = pcolor(y_ticks, z_ticks, FRA.transform.conv);
%     
%     p.FaceColor = 'interp';
%     p.EdgeColor = 'white';
%     p.EdgeAlpha = 0.1;
%     hold on
%     if showPeriphery
%         [xp, yp] = getPolygon( ...
%             FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1),...
%             FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2),...
%             y_ticks, z_ticks );
%         pgon = polyshape( xp, yp ); 
%         plot( pgon, 'FaceColor', 'none', 'EdgeColor', '#EDB120', 'LineWidth', 1 );
%     end
%     
%     if showCore
%         [xp, yp] = getPolygon( ...
%             FRA.receptive_field.core_receptive_field.core_bounds(:,1),...
%             FRA.receptive_field.core_receptive_field.core_bounds(:,2),...
%             y_ticks, z_ticks );
%         pgon = polyshape( xp, yp ); 
%         plot( pgon, 'FaceColor', 'none', 'EdgeColor', '#A2142F', 'LineWidth', 1 );
%     end
%     
%     if showBF
%         plot( FRA.receptive_field.best_frequency, FRA.receptive_field.best_intensity, 'kp', 'linewidth', 2 );
%         txt = sprintf('\n\n\n BF\n%0.2f (KHz)', sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels ) / 1000 );
%         text(FRA.receptive_field.best_frequency,...
%             FRA.receptive_field.best_intensity,txt, 'FontSize',10, 'HorizontalAlignment', 'center'  );
%     end
%     
%     if showCF
%         cf = sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels );
%         txt = sprintf(' CF\n %0.2f (KHz)', cf / 1000);
%         xl = xline( FRA.receptive_field.response_threshold, 'w-', {txt}, 'linewidth', 2 );
%         xl.LabelVerticalAlignment = 'bottom';
%         if FRA.receptive_field.response_threshold > FRA.y_values(end-round(length(FRA.y_values)/5)) 
%             xl.LabelHorizontalAlignment = 'left';
%         else
%             xl.LabelHorizontalAlignment = 'right';
%         end
%         xl.LabelOrientation = 'horizontal';
%         xl.FontSize = 9;
%     end
%     
%     if showMT
%         
%         txt = sprintf(' Min Threshold\n %0.2f (dB SPL)', FRA.receptive_field.minimum_threshold);
%         yl = yline( FRA.receptive_field.minimum_threshold, 'w-', {txt}, 'linewidth', 2 );
%         
%         if FRA.receptive_field.minimum_threshold > FRA.x_values(end-2)
%             yl.LabelVerticalAlignment = 'bottom';
%         else
%             yl.LabelVerticalAlignment = 'top';
%         end
%         
%         yl.LabelHorizontalAlignment = 'left';
%         yl.FontSize = 9;
%     end
%     
%     if showSlopes
%         
%         x_continuous = min(y_ticks):0.001:max(y_ticks);
%         
%         %%% Periphery RF
%         % right
%         f = @(x) FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF(1) * x + FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF(2);
%         % left
%         g = @(x) FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF(1) * x + FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF(2);
%         fy = f( x_continuous );
%         gy = g( x_continuous );
%         plot( x_continuous( fy > FRA.receptive_field.minimum_threshold ), fy( fy > FRA.receptive_field.minimum_threshold ), 'y:', 'linewidth',2 );
%         plot( x_continuous( gy > FRA.receptive_field.minimum_threshold ), gy( gy > FRA.receptive_field.minimum_threshold ), 'y:', 'linewidth',2 );
%        
%         
%         %%% Core RF
%         % right
%         f = @(x) FRA.receptive_field.core_receptive_field.down_right_slope_CRF(1) * x + FRA.receptive_field.core_receptive_field.down_right_slope_CRF(2);
%         % left
%         g = @(x) FRA.receptive_field.core_receptive_field.down_left_slope_CRF(1) * x + FRA.receptive_field.core_receptive_field.down_left_slope_CRF(2);
%         fy = f( x_continuous );
%         gy = g( x_continuous );
%         plot( x_continuous( fy > FRA.receptive_field.minimum_threshold ), fy( fy > FRA.receptive_field.minimum_threshold ), 'r:', 'linewidth',2 );
%         plot( x_continuous( gy > FRA.receptive_field.minimum_threshold ), gy( gy > FRA.receptive_field.minimum_threshold ), 'r:', 'linewidth',2 );
%     end
%     
%     xlabel("Freq (KHz)");
%     ylabel({'Sound Level', '(dB SPL)'});
%     
%     xlim([min(y_ticks), max(y_ticks)]);
%     ylim([min(z_ticks), max(z_ticks)]);
%     xticks(y_ticks);
%     yticks(z_ticks);
%     xticklabels( round( y_tick_labels / 1000, 3) );
%     yticklabels( levels );
%     [t, s] = title(Title, {subTitle, ""});
%     t.FontSize = 16;
%     s.FontAngle = 'italic';
%     
%     % Colorbar
%     if showColorbar
%         caxis([0, max(FRA.transform.conv, [], 'all')]);
%         c = colorbar;
%         c.Label.Position(1) = 0;
%         c.Label.String = "Spike rate";
%     end
%     drawnow;
    
    frame = getframe(f1);
    im{1} = frame2im(frame);
    
    if saveFigures
        exportgraphics(f1,output_filename+"_FRA.pdf",...
            'BackgroundColor','none','ContentType','vector');
        exportgraphics(f1, output_filename + "_FRA.png");
    end
    
    if ~showFigure
        close(f1);
    end
    
    if displayInfo
        printInformation( FRA, 1, sweeps, channels );
        if cleanSA
            fprintf("\n\tSpontaneous Activity (SA) detected (%%):\t%f\n\n",...
                FRA.stats.spontaneous_activity_detected * 100 );
        end
    end

    if saveInformation
        fID = fopen(output_filename+".txt", 'w');
        printInformation( FRA, fID, sweeps, channels )
        if cleanSA
            fprintf(fID, "\n\tSpontaneous Activity (SA) detected (%%):\t%f\n\n",...
            FRA.stats.spontaneous_activity_detected * 100 );
        end
        fclose(fID);
    end

    if saveExcel
        writeExcel( output_filename+".xls", FRA, sweeps, channels );
    end
end

