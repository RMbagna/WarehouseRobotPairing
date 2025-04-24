%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Simulation Script with Full Error Handling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
close all;

%% ==================== STEP 1: DATA IMPORT ====================
disp('=== DATA IMPORT ===');
robotChoice_Data = readtable('G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\data\WarehouseRobot_Pairing_Data\test_pairing_data.csv');
disp(['Successfully imported ', num2str(height(robotChoice_Data)), ' trials']);

% Extract attributes and initialize results
attributes = {'energy','pace','safety','reliability','intelligence'};
num_trials = height(robotChoice_Data);
results(num_trials) = struct(); % Preallocate

%% ==================== STEP 2: MODEL SETUP ====================
disp('=== MODEL INITIALIZATION ===');
[phi1, phi2, tau, error_sd, beta_weights, initial_P] = initialize_model_parameters();

%% ==================== STEP 3: TRIAL PROCESSING ====================
disp('=== PROCESSING TRIALS ===');
for current_trial = 1:num_trials
    fprintf('\n===== Trial %d/%d =====\n', current_trial, num_trials);
    
    try
        % Build attribute matrix
        M = [
            robotChoice_Data.robot1energy(current_trial), robotChoice_Data.robot1pace(current_trial), ...
            robotChoice_Data.robot1safety(current_trial), robotChoice_Data.robot1reliability(current_trial), ...
            robotChoice_Data.robot1intelligence(current_trial);
            
            robotChoice_Data.robot2energy(current_trial), robotChoice_Data.robot2pace(current_trial), ...
            robotChoice_Data.robot2safety(current_trial), robotChoice_Data.robot2reliability(current_trial), ...
            robotChoice_Data.robot2intelligence(current_trial);
            
            robotChoice_Data.robot3energy(current_trial), robotChoice_Data.robot3pace(current_trial), ...
            robotChoice_Data.robot3safety(current_trial), robotChoice_Data.robot3reliability(current_trial), ...
            robotChoice_Data.robot3intelligence(current_trial);
            
            0.1*ones(1,5); % Control1
            0.9*ones(1,5)  % Control2
        ];
        
        % DFT Calculation
        beta = beta_weights ./ sum(abs(beta_weights));
        [E_P, V_P, probs, P_tau] = calculateDFTdynamics(...
            phi1, phi2, tau, error_sd, beta, M, initial_P);
        
        % Store results
        [~, predicted_choice] = max(probs);
        results(current_trial).Trial = current_trial;
        results(current_trial).ActualChoice = robotChoice_Data.choice(current_trial);
        results(current_trial).PredictedChoice = predicted_choice;
        results(current_trial).Probabilities = probs';
        results(current_trial).EP = E_P';
        results(current_trial).Success = true;
        
        % Display predictions
        fprintf('Predicted: Robot %d | Actual: Robot %d\n', ...
            predicted_choice, robotChoice_Data.choice(current_trial));
        
        % Equilibrium solution (with nested try-catch)
        try
            x_mins = robot_production_capacity(M);
            solutions = solve_equilibrium(E_P, V_P, x_mins);
            results(current_trial).P_final = get_solution_vector(solutions)';
        catch ME_inner
            warning('Equilibrium failed for Trial %d: %s', current_trial, ME_inner.message);
            results(current_trial).EquilibriumError = ME_inner.message;
        end
        
    catch ME_main
        fprintf(2, '!! Processing failed for Trial %d: %s\n', current_trial, ME_main.message);
        results(current_trial).Success = false;
        results(current_trial).Error = ME_main.message;
        continue; % Proceed to next trial
    end
end

%% ==================== STEP 4: RESULTS SUMMARY ====================
disp('=== FINAL RESULTS ===');
display_summary(results);

% Save results
save('all_trial_results.mat', 'results');
writetable(struct2table(results), 'all_trial_results.csv');
disp('Results saved to all_trial_results.mat and .csv');

%% ==================== HELPER FUNCTIONS ====================
function [phi1, phi2, tau, error_sd, beta_weights, initial_P] = initialize_model_parameters()
    % Try R integration first
    try
        rscript_path = 'C:\Program Files\R\R-4.4.2\bin\x64\Rscript.exe';
        r_script = 'G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\example\DFT_Resource_Allocation.R';
        outputDir = 'G:\My Drive\myResearch\Research Experimentation\Apollo\apollo\ResourceAllocation_Output';
        
        cmd = sprintf('"%s" "%s" -i "%s" -o "%s"', ...
                   rscript_path, r_script, 'input.csv', outputDir);
        [status,~] = system(cmd);
        
        if status == 0
            jsonFile = fullfile(outputDir, 'DFT_output.json');
            params = jsondecode(fileread(jsonFile));
            
            phi1 = params.phi1;
            phi2 = params.phi2;
            tau = 1 + exp(params.timesteps);
            error_sd = params.error_sd;
            
            beta_weights = [
                params.b_energy;
                params.b_pace;
                params.b_safety;
                params.b_reliability;
                params.b_intelligence
            ];
            
            initial_P = [
                params.asc_1;
                params.asc_2;
                params.asc_3;
                0;  % Control1
                0   % Control2
            ];
        else
            error('R execution failed');
        end
    catch
        warning('Using fallback parameters');
        phi1 = 0.5;
        phi2 = 0.8;
        tau = 10;
        error_sd = 0.1;
        beta_weights = [0.3; 0.2; 0.4; 0.1; 0.5];
        initial_P = zeros(5,1);
    end
end

function display_summary(results)
    successful_trials = [results.Success];
    n_success = sum(successful_trials);
    fprintf('Successfully processed %d/%d trials (%.1f%%)\n', ...
            n_success, length(results), n_success/length(results)*100);
    
    if n_success > 0
        correct_predictions = sum([results(successful_trials).PredictedChoice] == ...
                                 [results(successful_trials).ActualChoice]);
        fprintf('Prediction accuracy: %.1f%%\n', correct_predictions/n_success*100);
        
        % Show prediction distribution
        fprintf('\nPrediction Distribution:\n');
        for robot = 1:3
            n_pred = sum([results(successful_trials).PredictedChoice] == robot);
            n_actual = sum([results(successful_trials).ActualChoice] == robot);
            fprintf('Robot %d: Predicted=%d, Actual=%d\n', robot, n_pred, n_actual);
        end
    end
    
    % Show failed trials
    failed_idx = find(~[results.Success]);
    if ~isempty(failed_idx)
        fprintf('\nFailed Trials: ');
        fprintf('%d ', failed_idx);
        fprintf('\n');
    end
end

function vec = get_solution_vector(solutions)
    if isfield(solutions, 'x')
        vec = [solutions.x; solutions.lambda; solutions.mu_vec];
    else
        vec = [solutions.P_final; solutions.E_P_eq; solutions.V_P_eq];
    end
end