function x_mins = robot_production_capacity(M)
    % Maps 5 robots' attributes to Type A/B production capacities
    % Input:  M (5x5 matrix) - [Robot 1; Robot 2; ... Robot 5] attributes
    % Output: x_mins (10x1)  - [Robot1_A; Robot1_B; ... Robot5_B] (integers 1-10)
    
    % Validate input
    if ~isequal(size(M), [5, 5])
        error('Input must be a 5x5 matrix (5 robots × 5 attributes).');
    end
    
    % Weights for product types
    weights_A = [0.4, 0.3, 0.1, 0.1, 0.1];  % Weight energy higher for Type A
    weights_B = [0.2, 0.2, 0.2, 0.2, 0.2];   % Balanced weights for Type B
    
    % Preallocate output
    x_mins = zeros(10, 1);
    
    % Calculate and scale production capacities
    for robot = 1:5
        idx = (robot-1)*2 + 1;
        
        % Calculate raw scores (0-1 range)
        raw_A = sum(M(robot, :) .* weights_A);
        raw_B = sum(M(robot, :) .* weights_B);
        
        % Scale to 1-10 range and round to nearest integer
        x_mins(idx)   = min(max(round(raw_A * 9) + 1, 1), 10);  % Type A
        x_mins(idx+1) = min(max(round(raw_B * 9) + 1, 1), 10);  % Type B
    end
end