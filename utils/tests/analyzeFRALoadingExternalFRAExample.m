% Load a struct
name = 'u13_110_13_019_027';
%name = 'u13_114_7_010_018';
%name = 'u13_105_2_010_018';
%name = 'u13_121_3_019_027';
%name = 'u13_121_2_029_037';
% path = '.';
path = 'FRA_ACh_Yann\ACH_FRA files\ACh_MMN\ACh';
loaded_fra = loading_fra_information( path, name );

FRA = analyzeFRA( loaded_fra, [], 1, 0 );

Title = "u13\_110\_13\_019\_027";
subTitle = "";
drawFRA(FRA, Title, subTitle, "Freq (kHz)");
printInformation( FRA )

function fra = loading_fra_information( path, name )
    % TODO: 
    % What does this function do?
    % What is a FRA and what are the values loaded here?
    % What is the purpose of this function?
    s = load( fullfile( path, name ), '-mat' );
    fra.y_values = s.(name).freqs(1,:);
    fra.x_values = s.(name).dB(:,1)';
    fra.raw_data = sum( s.(name).rawSpk, 3 );
    fra.sweeps = [];
    for i = 1:length(fra.y_values)
        fra.sweeps = [fra.sweeps; struct('CarFreq', fra.y_values(i))];
    end
    fra.channels = 1;
end