# Automated Analysis of Auditory Neuron Receptive Fields
> Master's thesis. M.S. in Neuroscience 2021-2022. USAL

Functions:
1. [`filesForNeuron(folderPath, yearExperiment, animalID, neuronNumber, fileFormat)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-filesforneuron)
2. [`getTrials(neuronFiles, channels)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-gettrials)
3. [`getPoints(spikes, property, num_sweeps, rep_Interval, isRelative)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getpoints)
4. [`plotStimBlock(delay, duration, interval, num_sweeps, isRelative)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-plotstimblock)
5. [`getTrialsWithLevel(trialList, level)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-gettrialswithlevel)
6. [`groupTrialsByLevel(trialList, levels)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-grouptrialsbylevel)
7. [`getAllSpikes(trialList)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getallspikes)
8. [`timeSpikeRaster(x, y, y_ticks, property, Title, subTitle, showFreq, channels, sweeps )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-timespikeraster)
9. [`plotTimeDotRasters(trials, neuronNumber, passes, levels, showFreq, isRelative, figurePosition)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-plottimedotrasters)
10. [`sweepToFreq(y, sweeps, channels)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-sweeptofreq)
11. [`getSpikesFromAt(spikes, from, at)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getspikesfromat)
12. [`dotRaster(x, y)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-dotraster)
13. [`PSTH(x, edges)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-psth)
14. [`get3DPoints(groupedTrials)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-get3dpoints)
15. [`getValueFromDensityMap(x, x_values, y, y_values, z,  z_values,  densityMap)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getvaluefromdensitymap)
16. [`getDensityMap(x, x_values, y, y_values, z, z_values, isDiscrete, plotImage)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getdensitymap)
17. [`getProbabilities( x, x_values, y, y_values, z, z_values, delay, duration, interval, isDiscrete )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getprobabilities)
18. [`getSpontaneousActivity( x, y, z, p, baseCaseProbabilities )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getspontaneousactivity)
19. [`spikeRaster3D(x, y, z, p, threshold, interval, max_p, Title, subTitle, x_ticks, y_ticks, z_ticks, x_tick_labels, y_tick_labels, z_tick_labels, point_size, point_alpha, labels, lim, colorbarLabel)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-spikeraster3d)
20. [`saveGIF(filename,images)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-savegif)
21. [`plotTimeDotRasters3D(trials, levels, showFreq, cleanSA, showSeparation, figurePosition )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-plottimedotrasters3d)
22. [`getFRA( x, y, z, y_values, z_values, cleanSA )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getfra)
23. [`getBiggestArea( fra_values, threshold, y_values, z_values )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getbiggestarea)

Classes:
1. [`Trial`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-trial)

Code Examples:
- [Reading trials from files](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/readingTrials.m).
- [Time dot raster plot examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/plotTimeDotRasterExamples.m).
- [3D time dot raster plot examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/plotTimeDotRasters3DExamples.m).
- [Time spike raster examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/timeSpikeRasterExamples.m).
- [PSTH and spike density function examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/PSTHSpikeDensityFunctionExample.m).
- [Usage examples of `spikeRaster3D()`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/spikeRaster3DExamples.m).
