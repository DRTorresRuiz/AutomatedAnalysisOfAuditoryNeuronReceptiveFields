function [FRAs, stats, rf] = analyzeAuditoryNeuron( folders, years, animalIDs, neuronNumbers, channels, ...
    levels, FRAConfiguration, PSTHConfiguration, SpikeRaster3DConfiguration, ...
    FrequencyResponseProfileConfiguration, output_folder, ...
    showFigures, saveExcel, showWarnings, resetFigures, resetConsole )
% ANALYZEAUDITORYNEURON. Main function
arguments
    folders
    years
    animalIDs
    neuronNumbers
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
        "showColorbar", true,...
        "showCore", true,...
        "showBF", true,...
        "showCF", true,...
        "showMT", true,...
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

% List all values for each neuron analysed
FRAs = [];
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
RFWidthDifferenceOctaves = [];
Q10s = [];
PeripheryTHs = [];
CoreTHs = [];


all_yvar = [];
if FrequencyResponseProfileConfiguration.show || FrequencyResponseProfileConfiguration.save   
        all_profiles = [];
end

for i = 1:length(folders)
    
    % Get trials
    if size( neuronNumbers, 1) > 1
        neuronIDs = neuronNumbers{i};
    else
        neuronIDs = neuronNumbers;
    end
    trials = readTrials( folders(i), years(i), animalIDs(i), neuronIDs, channels );

    %For each neuron, plot the FRA as configured, and plot what requires
    fnames = fieldnames( trials );
    neurons = fnames( contains(fnames, "Neuron") );
    
    yvar = [];
    if FrequencyResponseProfileConfiguration.show || FrequencyResponseProfileConfiguration.save   
        profile = [];
    end


    for j = 1:length(neurons)

        animal_folder = years(i) + "_" + animalIDs(i);
        neuron_folder = years(i) + "_" + animalIDs(i) + "_" + neurons{j};
        if FRAConfiguration.save || FRAConfiguration.saveTXT ||...
            PSTHConfiguration.save || SpikeRaster3DConfiguration.save || ...
            SpikeRaster3DConfiguration.saveGIF || FRAConfiguration.saveExcel || saveExcel

            
            mkdir( output_folder, animal_folder );
            mkdir( output_folder + "\" + animal_folder, neuron_folder);
        end

        t = trials.(neurons{j});
        % Get common neuron inforation
        sweep_number = t(1).Num_Sweeps;
        delay = t(1).Delay;
        duration = t(1).Duration;
        interval = t(1).Rep_Interval;
        channels = t(1).Channels;
        sweeps = t(1).getSweeps();
        neuronNumber = regexp(neurons{j},"Neuron(?<neuron>\d+)",'names').neuron;
        
        % Plot FRA
        if FRAConfiguration.displayInfo
            fprintf("\nNeuron " + neuronNumber + ": \n" );
        else
            fprintf("\nAnalysing neuron " + neuronNumber + " of animal " +...
                years(i) + "_" + animalIDs(i) + "...\n" );
        end

        if FRAConfiguration.showTitle
            Title = {"Frequency Response Area (FRA)","Neuron number: "+neuronNumber};
            subTitle = "Freq vs dB SPL";
        else
            Title = "";
            subTitle = "";
        end

        if FRAConfiguration.save || FRAConfiguration.saveTXT || FRAConfiguration.saveExcel
            mkdir( output_folder + "\" + animal_folder +"\"+neuron_folder, "FRA");
        end
        [FRA, ~] = plotFRA( t, levels, Title, subTitle,...
            FRAConfiguration.showPeriphery, FRAConfiguration.showCore,...
            FRAConfiguration.showBF, FRAConfiguration.showCF, FRAConfiguration.showMT, ...
            FRAConfiguration.showSlopes, FRAConfiguration.displayInfo,...
            FRAConfiguration.showFreq, FRAConfiguration.cleanSA, FRAConfiguration.showColorbar, ...
            FRAConfiguration.figurePosition, showFigures && FRAConfiguration.show,...
            FRAConfiguration.save, FRAConfiguration.saveTXT, FRAConfiguration.saveExcel, ...
            strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\FRA\', years(i)+"_"+animalIDs(i)+"_"+neuronNumber));

        FRAs = [FRAs; FRA];
        names = [names;  years(i)+"_"+animalIDs(i)+"_"+neuronNumber];
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
        RFWidthDifferenceOctaves = [ RFWidthDifferenceOctaves; RFwidth(4)];
        RFWidths = [RFWidths; RFwidth(1:2)];
        RFWidthDifferences = [RFWidthDifferences; RFwidth(3)];
        Q10s = [ Q10s; FRA.receptive_field.Q10 ];
        PeripheryTHs = [ PeripheryTHs; FRA.receptive_field.periphery_receptive_field.periphery_threshold ];
        CoreTHs = [ CoreTHs; FRA.receptive_field.core_receptive_field.core_threshold ];
        
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
                filename = strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\PSTH\', years(i)+"_"+animalIDs(i)+"_"+neuronNumber+"_PSTH");
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
                strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\spikeRaster3D\', years(i)+"_"+animalIDs(i)+"_"+neuronNumber+"_spikeRaster3D") );

            if SpikeRaster3DConfiguration.saveGIF
                filename = strcat(output_folder, '\', animal_folder, '\', neuron_folder, '\spikeRaster3D\', years(i)+"_"+animalIDs(i)+"_"+neuronNumber+"_spikeRaster3D.gif");
                saveGIF(filename, imspikeraster3d);
            end
        end

        if FrequencyResponseProfileConfiguration.show || FrequencyResponseProfileConfiguration.save

            yvar = [yvar; years(i) + "-" + animalIDs(i) + "-" + neuronNumber];
            profile = [profile; FRA.stats.spikes_per_freq(:,2)'/max(FRA.stats.spikes_per_freq(:,2))];
        end
    end

    if (FrequencyResponseProfileConfiguration.show || FrequencyResponseProfileConfiguration.save) && length(yvar) > 1
        % FREQUENCY-RESPONSE PROFILE
        if showFigures && FrequencyResponseProfileConfiguration.show
            fprofile = figure;
        else
            fprofile = figure('visible', 'off');
        end
        if ~isempty(FrequencyResponseProfileConfiguration.figurePosition)
            fprofile.Position = FrequencyResponseProfileConfiguration.figurePosition;
        end

        xvar = [round(sweepToFreq( FRA.y_values, sweeps, channels) / 1000, 3)];
        all_profiles = [ all_profiles; profile];
        all_yvar = [ all_yvar; yvar ];
        
        if FrequencyResponseProfileConfiguration.showTitle
            Title = {"Frequency-Response Profile", "Firing rate per neuron"};
        else
            Title = "";
        end

        heatmap(xvar, yvar, profile, "Title", Title,...
            'Colormap', parula, 'CellLabelColor','none' );
        xlabel( "Frequencies (KHz)" );
        ylabel( "Neuron ID" );
        
        if FrequencyResponseProfileConfiguration.save
            exportgraphics(fprofile,output_folder  + "\" + animal_folder + "\" + years(i) + "_" + animalIDs(i) + "_FRProfile.pdf",...
                'BackgroundColor','none','ContentType','vector');
            exportgraphics(fprofile,output_folder  + "\" + animal_folder + "\" + years(i) + "_" + animalIDs(i) + "_FRProfile.png");
        end

        if ~( showFigures && FrequencyResponseProfileConfiguration.show )
            close(fprofile);
        end
    end
end

if (FrequencyResponseProfileConfiguration.show || FrequencyResponseProfileConfiguration.save) && length(all_yvar) > length(yvar)
    % FREQUENCY-RESPONSE PROFILE FOR ALL NEURONS EACH ANIMAL
    if showFigures && FrequencyResponseProfileConfiguration.show
        fprofile = figure;
    else
        fprofile = figure('visible', 'off');
    end
    if ~isempty(FrequencyResponseProfileConfiguration.figurePosition)
        fprofile.Position = FrequencyResponseProfileConfiguration.figurePosition;
    end

    if FrequencyResponseProfileConfiguration.showTitle
        Title = {"Frequency-Response Profile", "Firing rate per neuron"};
    else
        Title = "";
    end

    heatmap(xvar, all_yvar, all_profiles, "Title", Title,...
        'Colormap', parula, 'CellLabelColor','none' );
    xlabel( "Frequencies (KHz)" );
    ylabel( "Neuron ID" );
    if FrequencyResponseProfileConfiguration.save
        exportgraphics(fprofile,output_folder  + "\FRProfile.pdf",...
            'BackgroundColor','none','ContentType','vector');
        exportgraphics(fprofile,output_folder  + "\FRProfile.png");
    end

    if ~( showFigures && FrequencyResponseProfileConfiguration.show )
        close(fprofile);
    end
end

varNames = { 'Neuron', 'Mean', 'Median', 'Mode', 'Standard Deviation', 'Variance',...
    'Max', 'Min', '#Spikes', 'SA detected (%)' };
stats = table(  names, means, medians, modes,stds,variances,maxs,mins,...
    nspikes, detectedsas, 'VariableNames', varNames );
varNames = { 'Neuron', '#RF_spikes', 'RFArea (%)', 'Mininum_Threshold (dB SPL)', 'Characteristic Frequency, CF, (Hz)',...
    'Best Frequency, BF (Hz)', 'Distance from CF to BF (octaves)', ...
    'RFWidth (Hz)', 'RFWidth Difference (Hz)', 'RFWidth Difference (octaves)', 'Q10', 'Periphery Threshold', 'Core Threshold' };
rf = table( names, nRFspikes, RFareas, RFminumunthresholds,RFCFs, RFBFs, RFOctaves,RFWidths,...
    RFWidthDifferences, RFWidthDifferenceOctaves, Q10s, PeripheryTHs, CoreTHs, 'VariableNames', varNames );
if saveExcel
    filename = output_folder  + "\NeuronStats.xls";

    writetable(stats, filename, 'Sheet', 'Stats' );
    writetable(rf, filename, 'Sheet', 'Receptive Field' );
end

if ~showWarnings
    % Set up back warning to on
    warning ('on','all');
end

if ~FRAConfiguration.displayInfo
    clc
    fprintf("\nEnd of the program.\n\n");
end

end

