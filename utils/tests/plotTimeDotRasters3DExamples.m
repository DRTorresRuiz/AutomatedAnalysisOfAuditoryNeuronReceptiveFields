% $Author: DRTorresRuiz$

%% READ TRIALS
readingTrials

%% CONFIGURE EXAMPLE VARIABLES
t = trials.Neuron2;
levels = 0:10:80;
showFreq = true;
cleanSA = true; 
show = true;
figurePosition = [ 100 100 1000 800 ];
showFigure = true;
save = true;
output_filenames = "./neuron2";
showTitle = false;

%% PLOT
im = plotTimeDotRasters3D(t, levels, showFreq, cleanSA, show, figurePosition, showFigure,...
    save, output_filenames, showTitle);

%% SAVE INTO A GIF IMAGE
saveGIF('animatedDotRaster3D.gif', im);