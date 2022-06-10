% $Author: DRTorresRuiz$

%% READ TRIALS
readingTrials

%% CONFIGURE EXAMPLE VARIABLES
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

%% PLOT FRA FOR DIFFERENT NEURONS

fnames = fieldnames( trials );
neurons = fnames( contains(fnames, "Neuron") );
% warning ('off','all');
for i = 1:length(neurons)
    fprintf("\n" + neurons{i} + ": \n" );
    Title = {"Frequency Response Area (FRA)", "Neuron number: "+i};
    subTitle = "Freq vs dB SPL";
    [FRA, im] = plotFRA( trials.(neurons{i}), levels, Title, subTitle, showPeriphery, showCore, ...
        showBF, showCF, showSlopes, displayInfo, showFreq, cleanSA, figurePosition );
end
% warning('on','all');