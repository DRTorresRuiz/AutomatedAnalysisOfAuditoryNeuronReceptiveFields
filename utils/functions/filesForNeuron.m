function neuronRecords = filesForNeuron(folderPath, yearExperiment, animalNumber,...
    neuronNumber, fileFormat)
% This function lists all files for a specific neuron according to the
% following format:
%   "[year]_[animalNumber]_[neuronNumber]_[testNumber].txt"
% NOTE: `fileFormat` can be modified, but this function does not support
% more blocks than the above ones (`[year]`, `[animalNumber]`, `[neuronNumber]`,
% and [testNumber]). In addition, `[testNumber]` is always replaced by "*"
% to use regular expressions to find all files for each neuron, since, according 
% to my requirements, each file corresponds to a different trial with a neuron.
% 
% Usage example:
% 
% >> f = filesForNeuron(".\IC Ionto\13_128_Ionto\FRA\", 13, 128, [1, 2])
% >> f = 
% 
%   1×2 struct array with fields:
% 
%     year
%     animalNumber
%     neuronNumber
%     folderPath
%     filenames
% 
% >> f(2)
% 
% ans = 
% 
%   struct with fields:
% 
%             year: 13
%     animalNumber: 128
%     neuronNumber: 2
%       folderPath: 'C:\Users\Daniel Torres Ruiz\Desktop\TFM\IC Ionto\13_128_Ionto\FRA'
%        filenames: {1×63 cell}
%
% $Author: DRTorresRuiz$
    arguments
        folderPath (1,:) char {mustBeFolder} = "."
        yearExperiment (1,1) uint16 = year(datetime())
        animalNumber (1,1) uint32 = 1
        neuronNumber (1,:) uint32 = 1            
        fileFormat (1,1) string = "[yearExperiment]_[animalNumber]_[neuronNumber]_[testNumber].txt"
    end
    
%   Control phase: checking variable requirements.
    assert(~isempty(neuronNumber), 'The value of neuronNumber can not be empty')
    assert(isfolder(folderPath), [folderPath, ' is not a folder or does not exist.'])

%   Declaring variables and constants
    yearBlock = "[yearExperiment]";
    animalNumberBlock = "[animalNumber]";
    neuronNumberBlock = "[neuronNumber]";
    testNumberBlock = "[testNumber]";
    
    % Replace all above blocks with their corresponding values except for
    % neuronNumberBlock. This block is replaced later in this function.
    format = replace(fileFormat, yearBlock, string(yearExperiment));
    format = replace(format, testNumberBlock, '*');
    format = replace(format, animalNumberBlock, string(animalNumber));

%   Function phase: Returns the list of files according to the arguments in
%   the specified path.  
    for i = 1 : length(neuronNumber)
    % This for loop iterates to select all files (each trial) for each neuron
    % passed as argument. The `files` variable also contains the respective
    % year, animalNumber, and neuronNumber that are involve in
    % the measurements.
        % Replace the neuronNumberBlock and get the folder path and the
        % regular expression to select all files for a specific neuron.
        fileExpression = replace(format, neuronNumberBlock, string(neuronNumber(i)));
        pathExpression = strcat(folderPath, '\', fileExpression);
        fileList = dir(pathExpression);
        if isempty(fileList)
            fprintf("No files for %s expression.\n", pathExpression);
            continue;
        end
        
        % Save all filenames and additional information that 
        % correspond to a neuron, if exist any file (trial).
        neuronRecords(i).year = yearExperiment;
        neuronRecords(i).animalNumber = animalNumber;
        neuronRecords(i).neuronNumber = neuronNumber(i);
        neuronRecords(i).folderPath = fileList.folder;
        neuronRecords(i).filenames = {fileList.name};
    end
end