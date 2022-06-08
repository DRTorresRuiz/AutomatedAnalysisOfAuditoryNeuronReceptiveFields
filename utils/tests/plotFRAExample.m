% $Author: DRTorresRuiz$

%% READ TRIALS
readingTrials

%% CONFIGURE EXAMPLE VARIABLES
t = trials.Neuron1;

levels = 0:10:80;
showFreq = true;
cleanSA = true;
figurePosition = [ 100 100 1000 800 ];

showPeriphery = true;
showCore= true;
showBF = true;
showCF = true;
showSlopes = true;
displayInfo = true;

%% PLOT

[FRA, im] = plotFRA( t, levels, showPeriphery, showCore, ...
    showBF, showCF, showSlopes, displayInfo, showFreq, cleanSA, figurePosition );
