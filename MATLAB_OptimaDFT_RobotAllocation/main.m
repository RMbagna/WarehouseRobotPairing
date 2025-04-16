%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation Setup:
%
% This script reads  data from robot allocation experiment as CSV file.
% This then references python bridge to apollo to estimate static
% parameters for dataset. Using the parameters, we formulate DFT Preference
% dynamic and determine, E(P), V(P), with respect to robot states (x_i). We
% then reference 'solve_equilibrium' function to predict human choice for
% component produced.
%
% - The autonomous agents are responsible for producing component types 1 and 2;
% - The human agents are responsible for producing component types 3 and 4.
%
% At each macro-level time step τ, the human preference state P_tau evolves 
% slowly over time and is modeled internally using Decision Field Theory (DFT).
% At a given τ, we assume the following human response statistics are available:
%
%   - E[y_k] = r_k(P_{kc,τ}), representing the expected behavioral response
%     of the human agent based on their internal preference state;
%   - Var[y_k] = σ_k², representing the uncertainty in the human response.
%
% During the continuous-time interval from τ to τ+1, we assume P_tau remains 
% fixed—that is, human preferences do not change during this interval.
%
% Under this setting, we simulate the optimization process of the autonomous 
% agents over [τ, τ+1], during which they continuously update their production 
% states x_i to respond to uncertain human feedback and achieve optimal 
% resource allocation across the system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Step 1: Import CSV Data
% (reference apolloMain_5 amd apolloMain_6 as example for data manipulation)
biasData = readtable('user_choices.csv'); % Replace with the path to your data file
disp('User bias data imported successfully.');
taskChoice_Data = readtable('user_choices.csv'); % Replace with the path to your data file
disp('User task choice data imported successfully.');
robotChoice_Data = readtable('user_choices.csv'); % Replace with the path to your data file
disp('User robot choice data imported successfully.');

% Extract relevant data (modify based on your CSV structure)
robot_states = data{:, {'energy', 'pace', 'safety', 'reliability', 'computational_load'}};
task_attributes = data{:, {'efficiency', 'speed', 'safety', 'durability', 'skill'}};

%% Step 2: Python Bridge to Apollo for Parameter Estimation
% (reference apolloMain_4 as backup for parameter estimation; reference apolloMain_3 as backup for ploting preference dynamics and choice probability)
disp('Initializing Python bridge to Apollo...');
py.importlib.import_module('apollo_bridge'); % Import the Apollo Python script

% Prepare data for Python
csv_file_path = robotChoice_Data; % Path to the same CSV file
params = py.apollo_bridge.estimate_parameters(csv_file_path); % Call Apollo estimation function
disp('Static parameters estimated:');
disp(params);

% Extract returned parameters (ensure consistent format)
phi1 = double(params{1});
phi2 = double(params{2});
tau = double(params{3});
error = double(params{4});

%% Step 3: MDFT Formulation to Calculate Preference Dynamics
% (MDFT calculations based on estimated parameters)
% Example parameters
phi1 = 0.5;       % Sensitivity parameter
phi2 = 0.8;       % Memory decay
tau = 10;         %# Time steps
epsilon = 0.1;    % Noise

% Define 4 alternatives × 2 attributes (e.g., efficiency, safety)
M = [5.0, 1.0;    % Alt 1: High efficiency, low safety
     3.0, 4.0;    % Alt 2: Balanced
     1.0, 5.0;    % Alt 3: Low efficiency, high safety
     2.0, 2.0];   % Alt 4: Neutral

beta = [1.2; 0.8]; % Attribute weights (2×1)

% Calculate DFT dynamics (outputs E_P 4×1, V_P 4×4)
[E_P, V_P, probs] = calculateDFTdynamics(phi1, phi2, tau, epsilon, beta, M);

disp('E_P (4×1):'); disp(E_P');
disp('V_P (4×4):'); disp(V_P);
disp('Choice probs:'); disp(probs');

%% Step 4: Solve Equilibrium Function
% Example robot states (10-dimensional vector, nx=10)
% Format: [x1, x2, ..., x10] where each xi ∈ [0,1]
robot_states = [0.2;  % x1: Robot 1's energy allocation
                0.1;  % x2: Robot 2's pace adjustment
                0.5;  % x3: Robot 3's safety level
                0.1;  % x4: Robot 4's reliability
                0.6;  % x5: Robot 5's computational load
                0.4;  % x6: Robot 6's efficiency
                0.7;  % x7: Robot 7's speed
                0.1;  % x8: Robot 8's durability
                0.9;  % x9: Shared battery usage
                0.2]; % x10: Shared network bandwidth

% Use DFT outputs for equilibrium calculation
Ep_mins = E_P;       % 4×1 expected preferences from DFT
Varp_mins = V_P;     % 4×4 preference covariance from DFT
x_mins = robot_states; % 10×1 robot state vector

% Call equilibrium solver
[P_final, E_P_eq, V_P_eq] = solve_equilibrium(Ep_mins, Varp_mins, x_mins);

% Display results
disp('=== Equilibrium Results ===');
disp(['Final Preferences (P_final): ', num2str(P_final')]);
disp(['Expected Preferences (E_P_eq): ', num2str(E_P_eq')]);
disp(['Preference Variance (V_P_eq diagonal): ', num2str(diag(V_P_eq)')]);

%% Step 5: Output Results
disp('Saving results to CSV...');
output_table = table(E_P, V_P, P_final, ...
                     'VariableNames', {'ExpectedPreference', 'VariancePreference', 'FinalPreferences'});
writetable(output_table, 'results.csv');
disp('Results saved successfully!');