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
8. [`timeSpikeRaster( x, y, y_ticks, property, Title, subTitle, showFreq, channels, sweeps )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-timespikeraster)
9. [`plotTimeDotRasters(trials, neuronNumber, passes, levels, showFreq, isRelative, figurePosition)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-plottimedotrasters)
10. [`sweepToFreq(y, sweeps, channels)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-sweeptofreq)
11. [`getSpikesFromAt( spikes, from, at)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getspikesfromat)
12. [`dotRaster(x, y)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-dotraster)
13. [`PSTH( x, edges )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-psth)
14. [`get3DPoints( groupedTrials )`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-get3dpoints)
15. [`getValueFromDensityMap(x, x_values, y, y_values, z,  z_values,  densityMap)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getvaluefromdensitymap)

Classes:
1. [`Trial`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-trial)

Code Examples:
- [Reading trials from files](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/readingTrials.m).
- [Time dot raster plot examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/plotTimeDotRasterExamples.m).
- [Time spike raster examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/timeSpikeRasterExamples.m).
- [PSTH and spike density function examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/PSTHSpikeDensityFunctionExample.m).
