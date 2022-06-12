function [FRA, im] = plotFRA( trials, levels, Title, subTitle, showPeriphery, showCore, ...
    showBF, showCF, showSlopes, displayInfo, showFreq, cleanSA, figurePosition, showFigure,...
    saveFigures, saveInformation, saveExcel, output_filename)
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
    showSlopes = true
    displayInfo = true
    showFreq = true
    cleanSA = false
    figurePosition (1,:) {mustBeNumeric} = []
    showFigure = true
    saveFigures = true
    saveInformation = true
    saveExcel = true
    output_filename = ".\FRA"
end

    function [xi, yi] = getPolygon( x, y, x_values, y_values )
        xi = x;
        yi = y;
        if xi(end) == max(x_values) 
            xi = [xi; max(x_values)];
            yi = [yi; max(y_values)];
        elseif xi(1) == max(x_values)
            xi = [max(x_values); xi];
            yi = [max(y_values); yi];
        end
            
        if xi(1) == min(x_values) 
            xi = [min(x_values); xi];
            yi = [max(y_values); yi];
        elseif x(end) == min(x_values)
            xi = [xi; min(x_values)];
            yi = [yi; max(y_values)];
        end
    end

    function printInformation( fID, FRA, sweeps, channels, cleanSA )
        fprintf( fID, "\n\tStatistical Information (number of spikes):"+...
                "\n\t\tMean:\t%f"+...
                "\n\t\tMedian:\t%f" +...
                "\n\t\tMode:\t%f" +...
                "\n\t\tStandard Deviation:\t%f" +...
                "\n\t\tVariance:\t%f" +...
                "\n\t\tMax:\t%f" +...
                "\n\t\tMin:\t%f" +...
                "\n\t\tTotal number of spikes:\t%f" +...
                "\n", FRA.stats.mean, FRA.stats.median, FRA.stats.mode,...
                FRA.stats.std, FRA.stats.var, FRA.stats.max, FRA.stats.min,...
                FRA.stats.total_spikes);

        fprintf( fID, "\n\tReceptive field (RF) information:"+...
            "\n\t\tSpikes in RF:\t%f"+...
            "\n\t\tArea of RF (%%):\t%f" +...
            "\n\t\tMinimum Threshold (dB SPL):\t%f" +...
            "\n\t\tCharacteristic Frequency, CF (Hz):\t%f" +...
            "\n\t\tBest Frequency, BF (Hz):\t%f" +...
            "\n\t\tDistance from CF to BF (octaves):\t%f" +...
            "\n\t\tBiggest frequency interval of RF (Hz):\t[%f, %f]"+...
            "\n\t\t\tSeparation (Hz):\t%f" +...
            "\n", FRA.receptive_field.spikes_RF,...
            FRA.receptive_field.area_RF * 100,...
            FRA.receptive_field.minimum_threshold,...
            sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels ),...
            sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels ),...
            FRA.receptive_field.distance_to_BF_from_CF,...
            maxWidthRF(FRA.receptive_field.periphery_receptive_field.width_PRF, sweeps, channels));
        
        if cleanSA
            fprintf(fID, "\n\tSpontaneous Activity (SA) detected (%%):\t%f\n\n",...
                FRA.stats.spontaneous_activity_detected * 100 );
        end
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
            'RFWidth (Hz)', 'RFWidth Difference (Hz)' };
        
        RFwidth = maxWidthRF(FRA.receptive_field.periphery_receptive_field.width_PRF, sweeps, channels);
        rf = table( FRA.receptive_field.spikes_RF,...
            FRA.receptive_field.area_RF * 100,...
            FRA.receptive_field.minimum_threshold,...
            sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels ),...
            sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels ),...
            FRA.receptive_field.distance_to_BF_from_CF,...
            RFwidth(1:2), RFwidth(3),...
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
    
    FRA = getFRA( x, y, z, sweeps, channels, y_ticks, z_ticks );
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
    
    p = pcolor(y_ticks, z_ticks, FRA.transform.conv);
    
    p.FaceColor = 'interp';
    p.EdgeColor = 'white';
    p.EdgeAlpha = 0.1;
    hold on
    if showPeriphery
        [xp, yp] = getPolygon( ...
            FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,1),...
            FRA.receptive_field.periphery_receptive_field.periphery_bounds(:,2),...
            y_values, z_values );
        pgon = polyshape( xp, yp ); 
        plot( pgon, 'FaceColor', 'none', 'EdgeColor', '#EDB120', 'LineWidth', 1 );
    end
    
    if showCore
        [xp, yp] = getPolygon( ...
            FRA.receptive_field.core_receptive_field.core_bounds(:,1),...
            FRA.receptive_field.core_receptive_field.core_bounds(:,2),...
            y_values, z_values );
        pgon = polyshape( xp, yp ); 
        plot( pgon, 'FaceColor', 'none', 'EdgeColor', '#A2142F', 'LineWidth', 1 );
    end
    
    if showBF
        plot( FRA.receptive_field.best_frequency, FRA.receptive_field.best_intensity, 'kp', 'linewidth', 2 );
        txt = "   BF = "+sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels );
        text(FRA.receptive_field.best_frequency,...
            FRA.receptive_field.best_intensity - 1,txt, 'FontSize',10 );
    end
    
    if showCF
        cf = sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels );
        txt = " CF = "+ cf+" ";
        xl = xline( FRA.receptive_field.response_threshold, 'w-', {txt}, 'linewidth', 2 );
        xl.LabelVerticalAlignment = 'middle';
        xl.LabelHorizontalAlignment = 'center';
        xl.FontSize = 12;
    end
    
    if showSlopes
        
        x_continuous = min(y_ticks):0.001:max(y_ticks);
        
        %%% Periphery RF
        % right
        f = @(x) FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF(1) * x + FRA.receptive_field.periphery_receptive_field.down_right_slope_PRF(2);
        % left
        g = @(x) FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF(1) * x + FRA.receptive_field.periphery_receptive_field.down_left_slope_PRF(2);
        plot( x_continuous, f( x_continuous ), 'y:', 'linewidth',2 );
        plot( x_continuous, g( x_continuous ), 'y:', 'linewidth',2 );
        
        %%% Core RF
        % right
        f = @(x) FRA.receptive_field.core_receptive_field.down_right_slope_CRF(1) * x + FRA.receptive_field.core_receptive_field.down_right_slope_CRF(2);
        % left
        g = @(x) FRA.receptive_field.core_receptive_field.down_left_slope_CRF(1) * x + FRA.receptive_field.core_receptive_field.down_left_slope_CRF(2);
        plot( x_continuous, f( x_continuous ), 'r:', 'linewidth',2 );
        plot( x_continuous, g( x_continuous ), 'r:', 'linewidth',2 );
    end
    
    xlabel("Freq (KHz)");
    ylabel({'Sound Level', '(dB SPL)'});
    
    xlim([min(y_ticks), max(y_ticks)]);
    ylim([min(z_ticks), max(z_ticks)]);
    xticks(y_ticks);
    yticks(z_values);
    xticklabels( round( y_tick_labels / 1000, 3) );
    yticklabels( levels );
    [t, s] = title(Title, {subTitle, ""});
    t.FontSize = 16;
    s.FontAngle = 'italic';
    drawnow;
    
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
        printInformation( 1, FRA, sweeps, channels, cleanSA );
    end

    if saveInformation
        fID = fopen(output_filename+".txt", 'w');
        printInformation( fID, FRA, sweeps, channels, cleanSA )
        fclose(fID);
    end

    if saveExcel
        writeExcel( output_filename+".xls", FRA, sweeps, channels, cleanSA );
    end
end

