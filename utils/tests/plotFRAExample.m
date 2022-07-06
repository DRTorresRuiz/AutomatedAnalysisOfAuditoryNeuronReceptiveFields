% $Author: DRTorresRuiz$

%% READ TRIALS
readingTrials

%% CONFIGURE EXAMPLE VARIABLES
t = trials.Neuron1;

levels = 0:10:80;
showFreq = true;
cleanSA = true;
figurePosition = [ 100 100 1000 800 ];

showPeriphery = false;
showCore= false;
showBF = false;
showMT = false;
showCF = false;
showSlopes = false;
showColorbar = true;
displayInfo = true;
showFigures = true;
saveFigures = true;
saveInformation = false;
saveExcel = false;
output_filename = "./neuron1";

%% PLOT
Title = "Frequency Response Area (FRA)";
subTitle = "Freq vs dB SPL";
Title = "";
subTitle = "";
[FRA, im] = plotFRA( t, levels, Title, subTitle, showPeriphery, showCore, ...
    showBF, showCF, showMT, showSlopes, displayInfo, showFreq, cleanSA, showColorbar,...
    figurePosition, showFigures, saveFigures, saveInformation, saveExcel, output_filename );
