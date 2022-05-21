function plotStimBlock(delay, duration, interval, num_sweeps,...
            isRelative)
%PLOTSTIMBLOCK Draw a block that specify the stimulation period.
%
%   You must specify the delay of the stimulus and its duration.
%   Besides, need to provide the duration of the trial (`interval`),
%   the total number of considered sweeps in the trial (`num_sweeps`), and
%   say if you want to repeat this over the time (for each sweep) or you
%   want to draw it relatively.
%
%  Usage example:
%
% >> plotStimBlock(10, 75, 250, 25, true);
%
% $Author: DRTorresRuiz$
    yl = ylim;
    yBox = [yl(1), yl(2), yl(2), yl(1)];

    if isRelative
        text_xlabel = "Relative ";
        xticks(0:10:interval);  
        xBox = [delay, delay, delay+duration, delay+duration];
        patch(xBox, yBox,...
            'black', 'EdgeColor', 'none', 'FaceAlpha', 0.05);
        xticks(0:10:interval); 
        xlim([-10, interval + 10]);
        xline(0,':');
    else
        text_xlabel = "Real ";
        for repetition = 1:num_sweeps
            start_at = interval*(repetition-1);
            xBox = [start_at + delay, start_at + delay,...
                start_at + delay+duration, start_at+ delay+duration];
            patch(xBox, yBox, ...
                'black', 'EdgeColor', 'none', 'FaceAlpha', 0.05);
        end
        xticks(0:interval:(num_sweeps*interval )); 
        xlim([-100, num_sweeps*interval ]);
    end
    xlabel(text_xlabel + "Time (ms)");
end

