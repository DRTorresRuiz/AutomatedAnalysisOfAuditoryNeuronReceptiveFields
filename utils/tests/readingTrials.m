% $Author: DRTorresRuiz$
%% SET UP VARIABLES
clc
channels = 2;

%% FIND FILES
fprintf("Reading files...\n");
f = filesForNeuron(".\IC Ionto\13_128_Ionto\FRA\", 13, 128, [1, 2]);

%% GET TRIAL INFORMATIONS
fprintf("Getting trial information from files...\n")
trials = getTrials(f, channels);
clc
fprintf("Trial information loaded successfully.\n\n\ttrials:\n");
disp(trials)