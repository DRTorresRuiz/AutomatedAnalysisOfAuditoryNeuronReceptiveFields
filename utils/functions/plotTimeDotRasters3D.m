function im = plotTimeDotRasters3D(trials, levels,...
    showFreq, cleanSA, showSeparation, figurePosition )
%PLOTTIMEDOTRASTERS3D. This function will show a time dot raster in 3D for
% all spikes in the variable `trials`, for each value in `levels`. This is
% a function developed for the sake of simplicity. If you require lower
% level of programming please, refer to `spikeRaster3D` function and
% `spikeRaster3DExamples`.
%
%  Usage examples:
%
% >> im = plotTimeDotRasters3D( trials, levels );
%
% To see more examples, refer to the documentation.
%
% $Author: DRTorresRuiz$
arguments
    trials (1,:) Trial
    levels
    showFreq = true
    cleanSA = false
    showSeparation = true
    figurePosition (1,:) {mustBeNumeric} = []
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
    
    %% Set variables
    x_ticks = 0:10:interval;
    x_values = [0 linspace(delay, delay+duration, duration/4) linspace( delay+duration+duration/4, interval, 10)];
    
    y_ticks = 1:num_sweeps;
    y_values = unique(y);

    z_ticks = levels;
    z_values = unique(z);
    %% Get Z == 0, base case
    baseCase = z == 0;
    
    %% Get probability distribution function
    probs = getProbabilities( x, x_values, y, y_values, z, z_values,...
                delay, duration, interval );
    max_prob = max(probs, [], 'all'); % to limit the colorbar
    
    %% Get frequecies if required
    if showFreq
        y_tick_labels = sweepToFreq(y_ticks, sweeps, channels);
    else
        y_tick_labels = y_ticks;
    end
    
    %% Clean spontaneuous activity according to the base case with 0 dB SPL.
    threshold = 0;
    if cleanSA
        [spikes, sa, threshold] = getSpontaneousActivity( x, y, z, probs, probs( baseCase ) );

        if showSeparation && ~isempty(spikes)
            
            Title = "SPIKES w/o SA";
            subTitle = "Freq vs dB SPL vs Time";
            f3 = figure;
            if ~isempty(figurePosition)
                f3.Position = figurePosition;
            end
            spikeRaster3D( spikes(:,1), spikes(:,2), spikes(:,3), spikes(:,4), threshold, interval, max_prob, Title, subTitle,...
                x_ticks, y_ticks, z_ticks, x_ticks, y_tick_labels, z_ticks, 40, 0.2 );
            drawnow;

            frame = getframe(f3);
            im{length(im)+1} = frame2im(frame);
        end
        
        if showSeparation && ~isempty(sa)
            Title = "SA";
            subTitle = "Freq vs dB SPL vs Time";
            f2 = figure;
            if ~isempty(figurePosition)
                f2.Position = figurePosition;
            end
            spikeRaster3D( sa(:,1), sa(:,2), sa(:,3), sa(:,4), threshold, interval, max_prob, Title, subTitle,...
                x_ticks, y_ticks, z_ticks, x_ticks, y_tick_labels, z_ticks, 40, 0.2 );
            drawnow;
            
            frame = getframe(f2);
            im{length(im)+1} = frame2im(frame);
        end
    end
    
    %% Plot all spikes.
    Title = "All spikes";
    subTitle = "Time vs Freq vs dB SPL";
    f1 = figure;
    if ~isempty(figurePosition)
        f1.Position = figurePosition;
    end
    spikeRaster3D( x, y, z, probs, threshold, interval, max_prob, Title, subTitle,...
        x_ticks, y_ticks, z_ticks, x_ticks, y_tick_labels, z_ticks, 40, 0.2 );
    drawnow;

    frame = getframe(f1);
    im{length(im)+1} = frame2im(frame);
end

