% $Author: DRTorresRuiz$
close all
clear all

%% SET UP VARIABLES
clc
channels = 2;

%% FIND FILES
fprintf("Reading files...\n");
file = filesForNeuron(".\IC Ionto\13_128_Ionto\FRA\", 13, 128, [1, 2, 3, 5, 6, 7]);

%% GET TRIAL INFORMATIONS
fprintf("Getting trial information from files...\n")
trials = getTrials(file, channels);
clc
fprintf("Trial information loaded successfully.\n\n\ttrials:\n");
disp(trials)