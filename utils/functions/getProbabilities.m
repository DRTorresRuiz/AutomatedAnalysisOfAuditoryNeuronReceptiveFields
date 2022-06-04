function probs = getProbabilities( x, x_values, y, y_values, z, z_values,...
    delay, duration, interval, useDensityMap, isDiscrete )
%GETPROBABILITIES Return a probability distribution
% function. The sum of all probabilities sum 1.
% By default, this function obtain the probability by the closeness between
% points in a trial (Euclidean Distance), the point population in each value of `z` 
% rated considering all the points, and the density function obtained for
% xyz values using `getDensityMap()` function.
%
% You can also consider when the stimulus is produced by including the
% delay, duration of the stimulus and the interval of one trial. This will
% add the probability of find a spike close and in the stimulus window.
%
% Usage example:
%
% >> probs = getProbabilities( x, x_values, y, y_values, z, z_values,...
%    delay, duration, interval );
%
% $Author: DRTorresRuiz$
arguments
    x
    x_values
    y
    y_values
    z
    z_values
    delay (1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(delay,0)}    = 0
    duration (1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(duration,0)} = 0 
    interval (1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(interval,0)} = 0
    useDensityMap = true
    isDiscrete (1,3) = [0 1 1]
end

%% Get density map
if useDensityMap
    [ ~, ~, ~, ~, ~, ~, xyz_density, ~ ] =...
        getDensityMap( x, x_values, y, y_values, z, z_values, isDiscrete );
end

%% Calculate Euclidean Distance
% to obtain a closeness approach for density around a specific point.
all_points = [x', y', z'];
dist = squareform(pdist(all_points, 'euclidean'));
sum_dist = sum(sum(dist));
all_points_size = size(all_points, 1);

%% Calculate probabilities 
probs = [];
end_stimulus = delay + duration;
for i = 1:size(dist, 1)
    % Obtain the evaluated point values.
    x_i = all_points( i, 1 );
    y_i = all_points( i, 2 );
    z_i = all_points( i, 3 );
    
    % Get all points in the same trial, this mean with the same frequency
    % and intensity ( Y and Z axis )
    all_x_trial = all_points(all_points(:,2) == y_i & all_points(:,3) == z_i ,1);
    
    % Closeness to the rest of points 3D
    prob_response = ( sum_dist - sum(dist(:,i)) )/ sum_dist;
    % Multiply by the spike population rate of this trial
    prob_response = prob_response * size(all_x_trial, 1) / all_points_size;
    
    % Calculate the probability of being close to the stimulus window
    if x_i < delay
        prob_response = 0;
    elseif x_i > end_stimulus
        h = 0.1119 * ((end_stimulus + interval)/2) / (interval/2);
        g = 2^(-h*(x_i - (end_stimulus + interval)/2));
        prob_response = prob_response * g / (g + 1) ;
    end

    if useDensityMap
    %     Multiply previous probability by the probability in the
    %     density map
        prob_response = prob_response *...
            getValueFromDensityMap( x_i, x_values, ...
            y_i, y_values, ...
            z_i, z_values, ...
            xyz_density);
    end   

    % Add to the result
    probs = [probs, prob_response ];
end

%% Normalize by sum
probs = probs / sum(probs);

end

