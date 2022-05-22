function spikes = getAllSpikes(trialList)
%GETALLSPIKES It returns all the spikes for a set of trials.
%   `spikes = getAllSpikes(trialList)`
%   Given a list of Trial objects, this function returns all the spikes for
%   each trial together in one list of spikes.
%  Usage examples:
%
% Being `trials.Neuron2(1:2)` a list of two trials, this function will
% return all their spikes together in one array:
%
% >> spikes = getAllSpikes(trials.Neuron2(1:2));
% >> spikes
% 
% spikes = 
% 
%   1×200 struct array with fields:
% 
%     n
%     Sweep
%     X_value
%     Pass
%     SpikeTimes
%
% $Author: DRTorresRuiz$
    spikes = [];
    for trial = trialList
        spikes = [spikes trial.getSpikes()];
    end
end

