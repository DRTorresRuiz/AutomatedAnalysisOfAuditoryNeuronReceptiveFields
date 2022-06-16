% $Author: DRTorresRuiz$
clear

%% SET UP VARIABLES
folder = [  ".\IC Ionto\13_128_Ionto\FRA\";...
            ".\IC Ionto\13_121_Ionto\FRA\";...
            ".\IC Ionto\13_127_Ionto\FRA\";...
            ".\IC Ionto\13_114_Ionto\FRA\";...
            ".\IC Ionto\14_047_ionto\fra\";...
            ".\IC Ionto\13_116_Ionto\FRA\";...
            ".\IC Ionto\13_125_Ionto\FRA\";...
            ".\IC Ionto\14_005_Ionto\FRA\";...
            ".\IC Ionto\14_007_Ionto\FRA\";...
            ".\IC Ionto\14_008_Ionto\FRA\";...
            ".\IC Ionto\14_009_Ionto\FRA\";...
            ".\IC Ionto\14_012_Ionto\FRA\";
];
% folder = ".\IC Ionto\14_009_Ionto\FRA\";

year = [13; 13; 13; 13; 14; 13; 13; 14; 14; 14; 14; 14];
% year = 14;


animalID = [ "128"; "121"; "127"; "114"; "047"'; "116"; "125"; "005"; "007"; "008"; "009"; "012"];
% animalID = "009";

neuronNumber = { [1 2 3 5 6 7];... 
    1:6;...
    [ 1 3 4 ];...
    [ 1 3 5 7 8 9 10 13 16 ];... 
    [1 2 3];...
    [1 2 3 5 7 14 15 16];...
    [ 6 7 ];...
    [ 1 2 ];... 
    [ 1 2 ];...
    [ 1 2 3 4 5 ];... 
    [ 1 2 3 ];...
    [ 2 ];...
    }; % Note the curly brackets (25)
% neuronNumber = [ 1 2 3 ];

channels = 2;
levels = 0:10:80;
output_folder = ".\test-folder";

cleanSA = true;
saveExcel = true;
showFigures = true;
showWarnings = false;
resetFigures = true;
resetConsole = true;

FRAConfiguration = struct(...
        "save", true,...
        "show", true,...
        "displayInfo", true,...
        "saveTXT", true,...
        "saveExcel", true,...
        "showPeriphery", true,...
        "showTitle", true,...
        "showColorbar", true,...
        "showCore", true,...
        "showBF", true,...
        "showCF", true,...
        "showMT", true,...
        "showSlopes", true,...
        "showFreq", true,...
        "cleanSA", cleanSA,...
        "figurePosition", [ 100 100 1000 800 ]);

PSTHConfiguration = struct(...
        "show", false,...
        "save", true,...
        "showDensityFunction", true,...
        "bins", [],...
        "figurePosition", [ 200 200 1000 800 ]);
    
SpikeRaster3DConfiguration = struct(...
        "show", false,...
        "showTitle", false,...
        "save", true,... 
        "saveGIF", true,...
        "cleanSA", cleanSA,...
        "figurePosition", [ 200 200 1000 800 ] );
    
FrequencyResponseProfileConfiguration = struct(...
        "show", false, ...
        "showTitle", false,...
        "save", true,...
        "figurePosition", [ 200 200 500 800 ]);


%% CALL MAIN FUNCTION
[FRAs, stats, rf] = analyzeAuditoryNeuron( folder, year, animalID, neuronNumber, channels, levels,...
    FRAConfiguration, PSTHConfiguration, SpikeRaster3DConfiguration, FrequencyResponseProfileConfiguration, ...
    output_folder, showFigures, saveExcel, showWarnings, resetFigures, resetConsole );