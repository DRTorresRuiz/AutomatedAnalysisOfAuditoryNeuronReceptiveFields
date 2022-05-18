classdef Trial
    % TRIAL Contains all information about one trial specified in a file
    %   This class contains all the information in the specified file about
    %   a test trial. It means that contains all the information from all 
    %   sweeps, and all the detected `spikes` that are included in the file
    %   passed as an argument.
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
        HeaderFormat = "Filename\t+(?<filename>.*) Num_Sweeps\t+(?<numSweeps>.*) Num_Passes\t+(?<numPasses>.*) Rep_Interval\t+(?<repInterval>.*)$"
        SweepFormat = "(?<sweepNumber>[^\t]+)\t+(?<timeOffset>[^\t]+)\t+(?<channel>[^\t]*)\t+(?<stimType>(SINUS|OFF))\t*(?<rest>.*)$"
        RestFormat = "(?<delay>[^\t]*)\t+(?<duration>[^\t]*)\t+(?<stimPerSweep>[^\t]*)\t+(?<interStimInt>[^\t]*)\t+(?<level>[^\t]*)\t+(?<carFreq>[^\t]*)\t+(?<modFreq>[^\t]*)\t+(?<freqDev>[^\t]*)\t+(?<AM_Depth>[^\t]*)\t+(?<phase>[^\t]*)\t+(?<wavFileName>[^\t]*)$"
        SpikeFormat = "(?<n>[^\t]+)\t+(?<sweep>[^\t]+)\t+(?<x_value>[^\t]+)\t+(?<pass>[^\t]*)\t+(?<spikeTimes>.*)$"
    end
    
    methods
        function obj = Trial(folderPath, fileName, channels )
            arguments
                folderPath (1,1) {mustBeFolder}
                fileName (1,1) string
                channels (1,1) {mustBeNumeric, mustBeInteger}
            end
            %TRIAL Construct an instance of this class
            %   As channels is not specified in the headers, we need to
            %   include it the constructor of the class. Channels should be
            %   common for all trials of a neuron, i.e. files that correspond
            %   to the same neuron.
            
            filePath = folderPath + fileName;
            assert(isfile(filePath), "The following file does not exit: " + filePath)
            obj.FilePath = filePath;
            obj.Channels = channels;
            
            % READ FILE AND GET INFORMATION ABOUT THE TRIAL.
            obj.FileContent = readlines( obj.FilePath );
            info = regexp( obj.FileContent(1) + " " + obj.FileContent(2) + " " + obj.FileContent(3) + " " + obj.FileContent(4), ...
                obj.HeaderFormat,...
                'names');
            obj.FileName = info.filename;
            obj.Num_Sweeps = str2double(info.numSweeps);
            obj.Num_Passes = str2double(info.numPasses);
            obj.Rep_Interval = str2double(info.repInterval);
            
            % Separate the content considering Num_Sweeps, Channels, and Num_Passes
            endSweepContent = (obj.Num_Sweeps * obj.Channels + 5);
            sweepContent = obj.FileContent( 6:endSweepContent );
            spikesContent = obj.FileContent( (endSweepContent + 2):(endSweepContent + 1 + obj.Num_Sweeps * obj.Num_Passes) );
            
            obj.Sweeps = obj.readSweeps( sweepContent );
            obj.Spikes = obj.readSpikes( spikesContent );
        end
        
%         GET Functions
        function fileName = getFileName(obj) 
            fileName = obj.FileName;
        end 

        function sweeps = getSweeps(obj)
            % GETSWEEPS. Return all sweeps in this trial.
            % Each sweep is a struct and has the following format:
            % -     Sweep_Number {numeric}
            % -     Time_Offset  {numeric}
            % -     Chan         {numeric}
            % -     StimType     {SINUS|OFF}
            % -     Delay        {numeric}
            % -     Dur          {numeric}
            % -     StimPerSweep {numeric}
            % -     InterStimInt {numeric}
            % -     Level        {numeric}
            % -     CarFreq      {numeric}
            % -     ModFreq      {numeric}
            % -     FreqDev      {numeric}
            % -     AM_Depth     {numeric}
            % -     Phase        {numeric}
            % -     wavFileName  {string}
            % In descending order, if StimType is "OFF" the rest of values
            % are NaN or empty chain of characters if string value.
            sweeps = obj.Sweeps;
        end
        
        function spikes = getSpikes(obj)
            % GETSPIKES. Return all spikes in this trial.
            % Each spike is a struct and has the following format:
            % -     n           {numeric}
            % -     Sweep       {numeric}
            % -     X_value     {numeric}
            % -     Pass        {numeric}
            % -     SpikeTimes  [{numeric}]
            % SpikeTimes can be empty.
            spikes = obj.Spikes;
        end
        
        function fileContent = getFileContent(obj)
            % GETFILECONTENT. Returns all the lines of the trial file.
            fileContent = obj.FileContent;
        end  
    end
    
    methods (Access = private)
        
        function sweeps = readSweeps(obj, sweepInformation)
            % READSWEEPS. Read and group all sweeps in the trial file according
            % to the SweepFormat and RestFormat regular expressions.
            sweeps = [];
            
            for i = 1:length(sweepInformation)
                infoSweep = regexp(sweepInformation(i), obj.SweepFormat, 'names');
                
                sweepNumber = str2double( infoSweep.sweepNumber );
                timeOffset = str2double( infoSweep.timeOffset );
                channel = str2double( infoSweep.channel );
                stimType = infoSweep.stimType;
                rest = infoSweep.rest;
                
                sweep = {};
                sweep.Sweep_Number = sweepNumber;
                sweep.Time_Offset = timeOffset;
                sweep.Chan = channel;
                sweep.StimType = stimType;
                
                if ~isequal(stimType, "OFF")
                    infoRest = regexp(rest, obj.RestFormat, 'names');
                    
                    sweep.Delay = str2double(infoRest.delay);
                    sweep.Dur = str2double(infoRest.duration);
                    sweep.StimPerSweep = str2double(infoRest.stimPerSweep);
                    sweep.InterStimInt = str2double(infoRest.interStimInt);
                    sweep.Level = str2double(infoRest.level);
                    sweep.CarFreq = str2double(infoRest.carFreq);
                    sweep.ModFreq = str2double(infoRest.modFreq);
                    sweep.FreqDev = str2double(infoRest.freqDev);
                    sweep.AM_Depth = str2double(infoRest.AM_Depth);
                    sweep.Phase = str2double(infoRest.phase);
                    sweep.wavFileName = infoRest.wavFileName;
                else
                    sweep.Delay = NaN;
                    sweep.Dur = NaN;
                    sweep.StimPerSweep = NaN;
                    sweep.InterStimInt = NaN;
                    sweep.Level = NaN;
                    sweep.CarFreq = NaN;
                    sweep.ModFreq = NaN;
                    sweep.FreqDev = NaN;
                    sweep.AM_Depth = NaN;
                    sweep.Phase = NaN;
                    sweep.wavFileName = infoRest.wavFileName;
                end
                
                sweeps = [sweeps sweep];
            end
        end
        
        function spikes = readSpikes(obj, spikeInformation)
            % READSPIKES. Read and group all spikes in the trial file
            % according to the SpikeFormat regular expression.
            spikes = [];
            
            for i = 1:length(spikeInformation)
                spikeInfo = regexp(spikeInformation(i), obj.SpikeFormat, 'names');
                
                spike = {};
                spike.n = str2double( spikeInfo.n );
                spike.Sweep = str2double(spikeInfo.sweep);
                spike.X_value = str2double(spikeInfo.x_value);
                spike.Pass = str2double(spikeInfo.pass);
                
                spikeTimes = textscan(spikeInfo.spikeTimes, '%f', 'Delimiter', ',');
                if isempty(spikeTimes)
                    spike.SpikeTimes = [];
                else
                    spike.SpikeTimes = spikeTimes{1};
                end
                spikes = [spikes spike];
            end
        end
    end
end

