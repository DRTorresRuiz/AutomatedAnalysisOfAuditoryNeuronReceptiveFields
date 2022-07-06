% Load a struct
% nameACh = 'u13_110_13_019_027'; nameCTRL = 'u13_110_13_001_009';
% nameACh = 'u13_114_7_010_018'; nameCTRL = 'u13_114_7_001_009';
% nameACh = 'u13_105_2_010_018'; nameCTRL = 'u13_105_2_001_009';
% nameACh = 'u13_121_3_019_027'; nameCTRL = 'u13_121_3_001_009';
nameACh = 'u13_121_2_029_037'; nameCTRL = 'u13_121_2_001_009';
% path = '.';
pathACh = 'FRA_ACh_Yann\ACH_FRA files\ACh_MMN\ACh';
pathCTRL = 'FRA_ACh_Yann\ACH_FRA files\ACh_MMN\CTRL';
loaded_fra_ACh = loading_fra_information( pathACh, nameACh );
loaded_fra_CTRL = loading_fra_information( pathCTRL, nameCTRL );

% FRA, sweeps, channels, additional_interval, kernel
FRA_CTRL = analyzeFRA( loaded_fra_CTRL, [], 1, 10 );
FRA_ACh = analyzeFRA( loaded_fra_ACh, [], 1, 10 );

mCTRL = max(FRA_CTRL.transform.conv, [], 'all');
mACh = max(FRA_ACh.transform.conv, [], 'all');
if mCTRL > mACh
    m = mCTRL;
else
    m = mACh;
end

f = figure;
f.Position = [ 100 100 1000 800 ];
Title = "";
subTitle = "";

showPeriphery = true;
showCore = true;
showBF = true;
showCF = true;
showMT = true;
showSlopes = false;
showColorbar = false;

drawFRA(FRA_CTRL, Title, subTitle, "Freq (Hz)", {'Sound Level', '(dB SPL)'},...
     FRA_CTRL.y_values, FRA_CTRL.x_values, FRA_CTRL.y_values, FRA_CTRL.x_values, [], 1, showPeriphery, showCore, showBF, showCF, showMT, showSlopes, showColorbar);

caxis([0, m]);
c = colorbar;
c.Label.Position(1) = 0;
c.Label.String = "Spike rate";

set(gca,'Xscale','log')
printInformation( FRA_CTRL )

exportgraphics(f,nameCTRL+"_FRA_CTRL.pdf",...
    'BackgroundColor','none','ContentType','vector');
% exportgraphics(f, name + "_FRA_CTRL.png");


f = figure;
f.Position = [ 100 100 1000 800 ];

drawFRA(FRA_ACh, Title, subTitle, "Freq (Hz)", {'Sound Level', '(dB SPL)'},...
     FRA_ACh.y_values, FRA_ACh.x_values, FRA_ACh.y_values, FRA_ACh.x_values, [], 1, showPeriphery, showCore, showBF, showCF, showMT, showSlopes, showColorbar);

caxis([0, m]);
c = colorbar;
c.Label.Position(1) = 0;
c.Label.String = "Spike rate";

set(gca,'Xscale','log')
printInformation( FRA_ACh )

exportgraphics(f,nameACh+"_FRA_ACh.pdf",...
    'BackgroundColor','none','ContentType','vector');


function fra = loading_fra_information( path, name )
    % TODO: 
    % What does this function do?
    % What is a FRA and what are the values loaded here?
    % What is the purpose of this function?
    s = load( fullfile( path, name ), '-mat' );
    fra.y_values = s.(name).freqs(1,:) * 1000;
    fra.x_values = s.(name).dB(:,1)';
%     fra.raw_data = sum( s.(name).rawSpk, 3 );
    fra.raw_data = sum( s.(name).meanSpk, 3 );
    fra.sweeps = [];
    for i = 1:length(fra.y_values)
        fra.sweeps = [fra.sweeps; struct('CarFreq', fra.y_values(i))];
    end
    fra.channels = 1;
end