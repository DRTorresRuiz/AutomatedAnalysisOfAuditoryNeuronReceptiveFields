function groupepTrials = groupTrialsByLevel(trialList, levels)
%GROUPTRIALS Returns all trials grouped by Level (dB SPL).
%Arguments:
%- trials: List of Trial
%- levels: numeric array
%
% Usage example:
%
% Being `trials.Neuron2` a list of Trial objects,
%
% >> groupTrialsByLevel(trials.Neuron2, 0:10:80)
% 
% ans = 
% 
%   1×9 struct array with fields:
% 
%     Level
%     Trials
%
% $Author: DRTorresRuiz$
    groupepTrials = [];
    
    for i = levels
        trialGroup = {};
        trialGroup.Level = i;
        trialGroup.Trials = getTrialsWithLevel(trialList, i);
        groupepTrials = [ groupepTrials trialGroup ];
    end
end

