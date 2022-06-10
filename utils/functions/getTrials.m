function trials = getTrials(neuronFiles, channels)
%TRIALS Load files into Trial objects.
%   To work with all the information within the files, this function
%   returns a struct with the common information and the different trials
%   for each neuron set of files.
%
% $Author: DRTorresRuiz$

    if ~isempty(neuronFiles)
        trials.year = neuronFiles(1).year;
        trials.animalID = neuronFiles(1).animalID;
        trials.folderPath = neuronFiles(1).folderPath;
    end
    
    for neuronFile = neuronFiles
        if ~isempty(neuronFile.neuronNumber)
            totalFiles = length(neuronFile.filenames);
            trialFiles = Trial.empty(totalFiles,0);
            for i = 1:totalFiles
                trialFiles(i) = Trial(neuronFile.folderPath, neuronFile.filenames{i}, channels);
            end
            trials.("Neuron" + neuronFile.neuronNumber) = trialFiles;
        end
    end
end

