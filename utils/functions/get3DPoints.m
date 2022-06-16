function [x, y, z] = get3DPoints( groupedTrials )
%GET3DPOINTS Given a group of trials return all spike times per sweep
%number and intensity.
%
% Usage example:
%
% Being `groupedTrials` a list with group of trials per intensity,
%
% >> [x, y, z] = get3DPoints( groupedTrials );
% >> whos x y z
%   Name      Size             Bytes  Class     Attributes
% 
%   x         1x970             7760  double              
%   y         1x970             7760  double              
%   z         1x970             7760  double  
% $Author: DRTorresRuiz$

    % Retrieving general information
    t = [ groupedTrials.Trials ];
    num_sweeps = t(1).Num_Sweeps;
    rep_interval = t(1).Rep_Interval;
    
    x = [];
    y = [];
    z = [];
    for group = groupedTrials
        
        spikes = getAllSpikes( group.Trials );
        [ group_x, group_y ] = getPoints( spikes, "Sweep", num_sweeps, rep_interval, true); 
        x = [ x group_x ];
        y = [ y group_y ];
        z = [ z repelem(group.Level, 1, length(group_x)) ];
    end
end

