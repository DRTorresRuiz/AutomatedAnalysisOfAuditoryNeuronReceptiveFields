function trials = getTrialsWithLevel(trialList, level)
%GETTRIALSWITHLEVEL Return trials with the same level (dB SPL)
%   Return a list of trials with the same dB SPL.
%
% Usage example:
%
% Being `trials.Neuron2` a list of Trial objects,
%
% >> getTrialsWithLevel(trials.Neuron2, 0)
% 
% ans = 
% 
%   1×7 Trial array with properties:
% 
%     FilePath
%     Num_Sweeps
%     Channels
%     Num_Passes
%     Rep_Interval
%     Delay
%     Duration
%     Level
%
% $Author: DRTorresRuiz$
trials = [];
for trial = trialList
    
    if isequal(trial.Level, level)
        trials = [trials trial];
    end
end

end

