function [stats, rf] = analyzeAuditoryNeuron( folder, year, animalID, neuronNumber, channels, ...
    levels, FRAConfiguration, PSTHConfiguration, SpikeRaster3DConfiguration, ...
    FrequencyResponseProfileConfiguration, output_folder, ...
    showFigures, saveExcel, showWarnings, resetFigures, resetConsole )
% ANALYZEAUDITORYNEURON. Main function
arguments
    folder
    year
    animalID
    neuronNumber
    channels
    levels
    FRAConfiguration
    PSTHConfiguration
    SpikeRaster3DConfiguration
    FrequencyResponseProfileConfiguration
    output_folder = "."
    showFigures = false
    saveExcel = true
    showWarnings = true
    resetFigures = true
    resetConsole = true
end

    function trials = readTrials( folder, year, animalID, neuronNumber, channels )
        % Reading files and getting all trials for each neuron
        f = filesForNeuron(folder, year, animalID, neuronNumber);
        trials = getTrials(f, channels);
    end


if resetConsole
    clc
end

if resetFigures
    close all
end

if ~showWarnings
    % Set up warning to off
    warning ('off','all');
end

if isempty(FRAConfiguration)
    FRAConfiguration = struct(...
        "save", true,...
        "show", true,...
        "displayInfo", true,...
        "saveTXT", true,...
        "saveExcel", true,...
        "showPeriphery", true,...
        "showTitle", true,...
        "showCore", true,...
        "showBF", true,...
        "showCF", true,...
        "showSlopes", true,...
        "showFreq", true,...
        "cleanSA", true,...
        "figurePosition", []);
end

if isempty(PSTHConfiguration)
    PSTHConfiguration = struct(...
        "show", true,...
        "save", true,...
        "showDensityFunction", true,...
        "bins", [],...
        "figurePosition", []);
end

if isempty(SpikeRaster3DConfiguration)
    SpikeRaster3DConfiguration = struct(...
        "show", true,...
        "showTitle", true,...
        "save", true,... 
        "saveGIF", true,...
        "cleanSA", true,...
        "figurePosition", [] );
end

if isempty(FrequencyResponseProfileConfiguration)
    FrequencyResponseProfileConfiguration = struct(...
        "show", true,...
        "showTitle", true,...
        "save", true,...
        "figurePosition", [] );
end

% Create folder
if FRAConfiguration.save || FRAConfiguration.saveTXT ||...
        PSTHConfiguration.save || SpikeRaster3DConfiguration.save || ...
        SpikeRaster3DConfiguration.saveGIF || FrequencyResponseProfileConfiguration.save ||...
        FRAConfiguration.saveExcel || saveExcel
mkdir( output_folder );
end

% Get trials
trials = readTrials( folder, year, animalID, neuronNumber, channels );

%For each neuron, plot the FRA as configured, and plot what requires
fnames = fieldnames( trials );
neurons = fnames( contains(fnames, "Neuron") );
if FrequencyResponseProfileConfiguration.show
    xvar = [];
    yvar = [];
    profile = [];
end

if saveExcel
    names = [];
    means = [];
    medians = [];
    modes = [];
    stds = [];
    variances = [];
    maxs = [];
    mins = [];
    nspikes = [];
    detectedsas = [];
    nRFspikes = [];
    RFareas = [];
    RFminumunthresholds = [];
    RFCFs = [];
    RFBFs = [];
    RFOctaves = [];
    RFWidths = [];
    RFWidthDifferences = [];
end

for i = 1:length(neurons)
    
    if FRAConfiguration.save || FRAConfiguration.saveTXT ||...
        PSTHConfiguration.save || SpikeRaster3DConfiguration.save || ...
        SpikeRaster3DConfiguration.saveGIF || FRAConfiguration.saveExcel || saveExcel
   
    animal_folder = year + "_" + animalID;
    mkdir( output_folder, animal_folder );
    neuron_folder = year + "_" + animalID + "_" + neurons{i};
    mkdir( output_folder + "\" + animal_folder, neuron_folder);
    
    end
    
    t = trials.(neurons{i});
    % Get common neuron inforation
    sweep_number = t(1).Num_Sweeps;
    delay = t(1).Delay;
    duration = t(1).Duration;
    interval = t(1).Rep_Interval;
    channels = t(1).Channels;
    sweeps = t(1).getSweeps();
    
    % Plot FRA
    if FRAConfiguration.displayInfo
        fprintf("\n" + neurons{i} + ": \n" );
    end
    
    if FRAConfiguration.showTitle
        Title = {"Frequency Response Area (FRA)","Neuron number: "+i};
        subTitle = "Freq vs dB SPL";
    else
        Title = "";
        subTitle = "";
    end
    
    if FRAConfiguration.save || FRAConfiguration.saveInformation || saveExcel
        mkdir( output_folder + "\" + animal_folder +"\"+neuron_folder, "FRA");
    end
    [FRA, ~] = plotFRA( t, levels, Title, subTitle,...
        FRAConfiguration.showPeriphery, FRAConfiguration.showCore,...
        FRAConfiguration.showBF, FRAConfiguration.showCF, ...
        FRAConfiguration.showSlopes, FRAConfiguration.displayInfo,...
        FRAConfiguration.showFreq, FRAConfiguration.cleanSA,...
        FRAConfiguration.figurePosition, showFigures && FRAConfiguration.show,...
        FRAConfiguration.save, FRAConfiguration.saveTXT, FRAConfiguration.saveExcel, ...
        strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\FRA\', year+"_"+animalID+"_"+neurons{i}));
    
    if saveExcel
        names = [names;  year+"_"+animalID+"_"+neurons{i}];
        means = [means; FRA.stats.mean];
        medians = [medians; FRA.stats.median];
        modes = [modes; FRA.stats.mode];
        stds = [stds; FRA.stats.std];
        variances = [variances; FRA.stats.var];
        maxs = [maxs;FRA.stats.max];
        mins = [mins;FRA.stats.min];
        nspikes = [nspikes;FRA.stats.total_spikes];
        detectedsas = [detectedsas; FRA.stats.spontaneous_activity_detected * 100];
        
        nRFspikes = [nRFspikes;FRA.receptive_field.spikes_RF];
        RFareas = [RFareas;FRA.receptive_field.area_RF * 100];
        RFminumunthresholds = [RFminumunthresholds;FRA.receptive_field.minimum_threshold];
        RFCFs = [RFCFs;sweepToFreq( FRA.receptive_field.response_threshold, sweeps, channels )];
        RFBFs = [RFBFs;sweepToFreq( FRA.receptive_field.best_frequency, sweeps, channels )];
        RFOctaves = [RFOctaves;FRA.receptive_field.distance_to_BF_from_CF];
        
        RFwidth = maxWidthRF(FRA.receptive_field.periphery_receptive_field.width_PRF, sweeps, channels);
        RFWidths = [RFWidths; RFwidth(1:2)];
        RFWidthDifferences = [RFWidthDifferences; RFwidth(3)];
    end
    
    if PSTHConfiguration.show || PSTHConfiguration.save
        % Get all spikes
        spikes = getAllSpikes(t);
        % Get all spike times
        x = [spikes.SpikeTimes];
        if isempty(PSTHConfiguration.bins)
            x_values = 0:interval;
        else
            x_values = PSTHConfiguration.bins;
        end
        
        if showFigures && PSTHConfiguration.show
            fpsth = figure;
        else
            fpsth = figure('visible', 'off');
        end
        if ~isempty(PSTHConfiguration.figurePosition)
            fpsth.Position = PSTHConfiguration.figurePosition;
        end
        hold on;
            % Using an updated version of Shimazaki's `ssvkernel()` function.
            if PSTHConfiguration.showDensityFunction
                ssvkernel( x, x_values, PSTHConfiguration.showDensityFunction ); % Set last value to true to plot
                ylabel( "Spike Density (%)" );
                % Plot PSTH
                yyaxis right
            end
            PSTH( x, x_values );
            plotStimBlock( delay, duration, interval, sweep_number, true )
        hold off;
        
        if PSTHConfiguration.save
            mkdir( output_folder + "\" + animal_folder+"\"+neuron_folder, "PSTH");
            filename = strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\PSTH\', year+"_"+animalID+"_"+neurons{i}+"_PSTH");
            exportgraphics(fpsth, filename + ".pdf",...
                'BackgroundColor','none','ContentType','vector');
            exportgraphics(fpsth, filename + ".png");
        end
        
        if ~(showFigures && PSTHConfiguration.show)
            close(fpsth);
        end
    end
    
    if SpikeRaster3DConfiguration.show || SpikeRaster3DConfiguration.save || SpikeRaster3DConfiguration.saveGIF
        
        if SpikeRaster3DConfiguration.save || SpikeRaster3DConfiguration.saveGIF
            mkdir( output_folder + "\" + animal_folder+"\"+neuron_folder, "spikeRaster3D");
        end
        
        imspikeraster3d = plotTimeDotRasters3D(t, levels, true, ...
            SpikeRaster3DConfiguration.cleanSA, true,...
            SpikeRaster3DConfiguration.figurePosition,...
            showFigures && SpikeRaster3DConfiguration.show,...
            SpikeRaster3DConfiguration.save, ...
            strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\spikeRaster3D\', year+"_"+animalID+"_"+neurons{i}+"_spikeRaster3D") );
        
        if SpikeRaster3DConfiguration.saveGIF
            filename = strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\spikeRaster3D\', year+"_"+animalID+"_"+neurons{i}+"_spikeRaster3D.gif");
            saveGIF(filename, imspikeraster3d);
        end
    end
    
    if FrequencyResponseProfileConfiguration.show
        yvar = [yvar; "Neuron " + i];
        profile = [profile; FRA.stats.spikes_per_freq(:,2)'/max(FRA.stats.spikes_per_freq(:,2))];
    end
end

if (FrequencyResponseProfileConfiguration.show || FrequencyResponseProfileConfiguration.save) && length(neurons) > 1
    % FREQUENCY-RESPONSE PROFILE
    if showFigures && FrequencyResponseProfileConfiguration.show
        fprofile = figure;
    else
        fprofile = figure('visible', 'off');
    end
    if ~isempty(FrequencyResponseProfileConfiguration.figurePosition)
        fprofile.Position = FrequencyResponseProfileConfiguration.figurePosition;
    end
    xvar = [xvar; round(sweepToFreq( FRA.y_values, sweeps, channels) / 1000, 3)];
    
    if FrequencyResponseProfileConfiguration.showTitle
        Title = {"Frequency-Response Profile", "Firing rate per neuron"};
    else
        Title = "";
    end
    
    heatmap(xvar, yvar, profile, "Title", Title,...
        'Colormap', parula, 'CellLabelColor','none' );
    xlabel( "Frequencies (KHz)" );
    
    if FrequencyResponseProfileConfiguration.save
        exportgraphics(fprofile,output_folder  + "\" + animal_folder + "\" + year + "_" + animalID + "_FRProfile.pdf",...
            'BackgroundColor','none','ContentType','vector');
        exportgraphics(fprofile,output_folder  + "\" + animal_folder + "\" + year + "_" + animalID + "_FRProfile.png");
    end
    
    if ~( showFigures && FrequencyResponseProfileConfiguration.show )
        close(fprofile);
    end
end

if saveExcel
    filename = output_folder  + "\" + animal_folder + "\NeuronStats.xls";
    varNames = { 'Neuron', 'Mean', 'Median', 'Mode', 'Standard Deviation', 'Variance',...
        'Max', 'Min', '#Spikes', 'SA detected (%)' };
    stats = table(  names, means, medians, modes,stds,variances,maxs,mins,...
            nspikes, detectedsas,...
            'VariableNames', varNames );
    writetable(stats, filename, 'Sheet', 'Stats' );

    rf = table( names, nRFspikes, RFareas,RFminumunthresholds,RFCFs,...
        RFBFs, RFOctaves,RFWidths, RFWidthDifferences );
    writetable(rf, filename, 'Sheet', 'Receptive Field' );
end

if ~showWarnings
    % Set up back warning to on
    warning ('on','all');
end

end

