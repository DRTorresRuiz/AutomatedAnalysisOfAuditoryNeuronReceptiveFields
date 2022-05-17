classdef Trial
    %TRIAL Contains all information about one trial specified in a file
    %   TODO: Detailed explanation goes here
    properties
        FilePath
        Num_Sweeps
        Channels
        Num_Passes
        Rep_Interval
    end
    
    properties (Access = private)
        FileName
        Spikes
        Sweeps
        FileContent
    end
    
    methods
        function obj = Trial(folderPath, fileName, channels )
            arguments
                folderPath (1,1) {mustBeFolder}
                fileName (1,1) string
                channels (1,1) {mustBeNumeric, mustBeInteger}
            end
            %TRIAL Construct an instance of this class
            %   TODO: Detailed explanation goes here
            
            filePath = folderPath + fileName;
            assert(isfile(filePath), "The following file does not exit: " + filePath)
            obj.FilePath = filePath;
            obj.Channels = channels;
            
            % READ FILE AND GET INFORMATION ABOUT THE TRIAL.
            obj.FileContent = readlines( obj.FilePath );
            info = regexp( obj.FileContent(1) + " " + obj.FileContent(2) + " " + obj.FileContent(3) + " " + obj.FileContent(4), ...
                "Filename\t*(?<filename>.*) Num_Sweeps\t*(?<numSweeps>.*) Num_Passes\t*(?<numPasses>.*) Rep_Interval\t*(?<repInterval>.*)$",...
                'names');
            obj.FileName = info.filename;
            obj.Num_Sweeps = str2double(info.numSweeps);
            obj.Num_Passes = str2double(info.numPasses);
            obj.Rep_Interval = str2double(info.repInterval);
            
            % Separate the content considering Num_Sweeps, Channels, and
            % Num_Passes
            endSweepContent = (obj.Num_Sweeps * obj.Channels + 5);
            sweepContent = obj.FileContent( 5:endSweepContent );
            spikesContent = obj.FileContent( (endSweepContent + 2):(endSweepContent + 1 + obj.Num_Sweeps * obj.Num_Passes) );
            
            obj.Sweeps = obj.readSweeps( sweepContent );
            obj.Spikes = obj.readSpikes( spikesContent );
        end
        
%         GET Functions
        function fileName = getFileName(obj) 
            fileName = obj.FileName;
        end 

        function sweeps = getSweeps(obj)
            % TODO: 
            sweeps = obj.Sweeps;
        end
        
        function spikes = getSpikes(obj)
            % TODO: 
            spikes = obj.Spikes;
        end
        
        function fileContent = getFileContent(obj)
            % TODO: 
            fileContent = obj.FileContent;
        end  
    end
    
    methods (Access = private)
        
        function sweeps = readSweeps(~, sweepInformation)
            % TODO:  A SWEEP would be a struct with:
                % sweep = struct("Time_Offset", 0, "Chan", 1, "StimType", "SINUS", "Delay",
                % 10, "Dur", 75, "StimPerSweep", 1, "InterStimInt", 10, "Level", 0,
                % "CarFreq", 500, "ModFreq", [], "FreqDev", [], "AM_Depth", [], "Phase", 0,
                % "wavFileName", [])
            sweeps = sweepInformation;
        end
        
        function spikes = readSpikes(~, spikeInformation)
            % TOOD: % A SPIKE would be a struct with:
    % spike = struct("sweep", 7, "X_value", 1.495, "Pass", 1, "SpikeTimes", 186.266)
            spikes = spikeInformation;
        end
    end
end

