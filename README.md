# Automated Analysis of Auditory Neuron Receptive Fields
> Master's thesis. M.S. in Neuroscience 2021-2022. USAL

Functions:
1. [`filesForNeuron(folderPath, yearExperiment, animalNumber, neuronNumber, fileFormat)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-filesforneuron)
2. [`getTrials(neuronFiles, channels)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-gettrials)
3. [`getPoints(spikes, property, num_sweeps, rep_Interval, isRelative)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-getpoints)
4. [`plotStimBlock(delay, duration, interval, num_sweeps, isRelative)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-plotstimblock)
5. [`getTrialsWithLevel(trialList, level)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-gettrialswithlevel)
6. [`groupTrialsByLevel(trialList, levels)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-grouptrialsbylevel)
7. [`plotDotRaster(trials, neuronNumber, passes, levels, showFreq, isRelative, figurePosition)`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-plotdotraster)

Classes:
1. [`Trial`](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/wiki/Documentation#-trial)

Code Examples:
- [Reading trials from files](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/readingTrials.m).
- [Dot raster plot examples](https://github.com/DRTorresRuiz/AutomatedAnalysisOfAuditoryNeuronReceptiveFields/blob/main/utils/tests/dotRasterExamples.m).