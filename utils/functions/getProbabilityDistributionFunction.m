function probs = getProbabilityDistributionFunction( x, x_values, y, y_values, z, z_values, delay, duration, interval, isDiscrete )
%GETPROBABILITYDISTRIBUTIONFUNCTION Return a probability distribution
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
% >> probs = getProbabilityDistributionFunction( x, x_values, y, y_values, z, z_values,...
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
    isDiscrete (1,3) = [0 1 1]
end

%% Get density map
[ ~, ~, ~, ~, ~, ~, xyz_density, ~ ] =...
    getDensityMap( x, x_values, y, y_values, z, z_values, isDiscrete );

%% Calculate Euclidean Distance
% to obtain a closeness approach for density around a specific point.
all_points = [x', y', z'];
dist = squareform(pdist(all_points(:,1), 'euclidean'));

%% Calculate probabilities 
probs = [];
for i = 1:size(dist, 1)
    % Obtain the evaluated point values.
    x_i = all_points( i, 1 );
    y_i = all_points( i, 2 );
    z_i = all_points( i, 3 );
    
    % Get all points in the same trial, this mean with the same frequency
    % and intensity ( Y and Z axis )
    all_x_trial = all_points(all_points(:,2) == y_i & all_points(:,3) == z_i ,1);
    all_idx = find( all_x_trial == x_i ); % index for the current value in all_x_trials.

    % Get distances for the current point
    x_dist = squareform(pdist(all_x_trial));
    x_dist_sum = sum(x_dist); % Sum all distances for each point in the trial
    x_sum = x_dist_sum(all_idx); % Get the accumulative sum for the current point
    
    if size(x_dist, 1) > 1 % If there is more than one point in the trial (for a specific frequency and intensity)
        % Check the closeness to other points using the Euclidean distance
        prob_spike = ( sum(x_dist_sum) - x_sum(1)) / sum(x_dist_sum);
        % Multiply by the spike population rate of this trial
        prob_spike = prob_spike * size(x_dist, 1) / size(all_points, 1);
        
        % Calculate the probability of being close to the stimulus window
        if interval * delay * duration > 0 
            prob_close_to_end_stimulus = 1 - abs((delay+duration) - x_i)/(interval - (delay+duration) );
            prob_after_stimulus_starts = 1 - abs(( x_i - delay ) / ( interval - delay )); 
            prob_in_window = prob_close_to_end_stimulus * prob_after_stimulus_starts;
            
            % Multiply by the probability of being close to the stimulus
            prob_spike = prob_spike * prob_in_window;
        end
        
        % Multiply previous probability by the probability in the
        % density map
        prob_spike = prob_spike *...
            getValueFromDensityMap( x_i, x_values, ...
            y_i, y_values, ...
            z_i, z_values, ...
            xyz_density);
            
    else
        % If there is only one point, prob is likely zero.
        prob_spike = 0;
    end
    
    % Add to the result
    probs = [probs, prob_spike ];
end

%% Normalize by sum
probs = probs / sum(probs);

end

