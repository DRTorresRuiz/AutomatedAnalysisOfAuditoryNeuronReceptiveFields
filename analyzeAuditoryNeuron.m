function analyzeAuditoryNeuron( folder, year, animalID, neuronNumber, channels, ...
    levels, FRAConfiguration, figurePosition, plotPSTH, plotFrequencyResponseProfile,...
    showWarnings, resetFigures, resetConsole )
% ANALYZEAUDITORYNEURON. Main function
arguments
    folder
    year
    animalID
    neuronNumber
    channels
    levels
    FRAConfiguration
    figurePosition = []
    plotPSTH = true
    plotFrequencyResponseProfile = true
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
        "showPeriphery", true,...
        "showCore", true,...
        "showBF", true,...
        "showCF", true,...
        "showSlopes", true,...
        "displayInfo", true,...
        "showFreq", true,...
        "cleanSA", true);
end

% Get trials
trials = readTrials( folder, year, animalID, neuronNumber, channels );

%For each neuron, plot the FRA as configured, and plot what requires
fnames = fieldnames( trials );
neurons = fnames( contains(fnames, "Neuron") );
if plotFrequencyResponseProfile
    xvar = [];
    yvar = [];
    profile = [];
end
for i = 1:length(neurons)
    
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
    Title = {"Frequency Response Area (FRA)", "Neuron number: "+i};
    subTitle = "Freq vs dB SPL";
    [FRA, im] = plotFRA( t, levels, Title, subTitle,...
        FRAConfiguration.showPeriphery, FRAConfiguration.showCore,...
        FRAConfiguration.showBF, FRAConfiguration.showCF, ...
        FRAConfiguration.showSlopes, FRAConfiguration.displayInfo,...
        FRAConfiguration.showFreq, FRAConfiguration.cleanSA, figurePosition );
    
    if plotPSTH
        % Get all spikes
        spikes = getAllSpikes(t);
        % Get all spike times
        x = [spikes.SpikeTimes];
        x_values = 0:interval;
        fpsth = figure;
        if ~isempty(figurePosition)
            fpsth.Position = figurePosition;
        end
        hold on;
            % Using an updated version of Shimazaki's `ssvkernel()` function.
            ssvkernel( x, x_values, true ); % Set last value to true to plot
            ylabel( "Spike Density (%)" );
            % Plot PSTH
            yyaxis right
            PSTH( x, x_values );
            plotStimBlock( delay, duration, interval, sweep_number, true )
        hold off;
    end
    
    if plotFrequencyResponseProfile
        yvar = [yvar; "Neuron " + i];
        profile = [profile; FRA.stats.spikes_per_freq(:,2)'/max(FRA.stats.spikes_per_freq(:,2))];
    end
end

if plotFrequencyResponseProfile
    % FREQUENCY-RESPONSE PROFILE
    fprofile = figure;
    if ~isempty(figurePosition)
        fprofile.Position = figurePosition;
    end
    xvar = [xvar; sweepToFreq( FRA.y_values, sweeps, channels)];
    heatmap(xvar, yvar, profile, "Title", {"Frequency-Response Profile", "Firing rate per neuron"},...
        'Colormap', parula, 'CellLabelColor','none' );
    xlabel( "Frequencies (Hz)" );
    c = colorbar;
    c.Label.String = 'Number of spikes';
end

% TODO

if ~showWarnings
    % Set up back warning to on
    warning ('on','all');
end

end

