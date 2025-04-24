%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation Setup:
%
% This experiment simulates a system consisting of 5 autonomous agents and
% 2 human agents.
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
function solutions = solve_equilibrium(Ep_mins, Varp_mins, x_mins)
    % === Parameter settings ===
    nx = 10; ny = 5;  % ny changed from 4 to 5
    
    % === Input validation ===
    assert(length(Ep_mins) == ny, 'Ep_mins must be 5x1');
    assert(isequal(size(Varp_mins), [ny ny]), 'Varp_mins must be 5x5');

    % === Structural matrices ===
    barA = diag([1, 2, 1, 2, 1, 1, 2, 1, 2, -1]);
    barB = diag(ones(ny,1));  % ny x ny diagonal matrix
    
    % === Symbolic variables ===
    syms x [nx 1] real
    syms x_plus [nx 1] real
    syms alpha_vec [nx+ny 1] real
    syms beta_vec [nx+ny 1] real
    syms lambda [ny 1] real
    syms mu_vec [ny 1] real

    % === Define h(x, p) ===
    % Define how robot states affect preferences
    P1 = @(x) Ep_mins(1:2) + x(1:2);  % 2 elements + 2 elements
    
    % Corrected P2 function - now properly handles 3 elements
    P2 = @(x) Ep_mins(3:5) + x(3:5) - [x(6:7); 0];  % Pad with zero to make 3 elements
    
    % Define the human response function h(x,p)
    h = @(x) [P1(x); P2(x)]; % Output will be 5x1 (2+3)
    
    % Human output y is directly based on h(x,p)
    y = h;
    
    % Compute Jacobians for sensitivity analysis
    dh_dx = jacobian(h(x), x);
    dy_dx = dh_dx;
    % After computing dy_dx:
    assert(size(dy_dx,1) == ny && size(dy_dx,2) == nx, ...
       'dy_dx should be %dx%d, is %dx%d', ny, nx, size(dy_dx));

    % === Cost functions ===
    F_x = @(x) [2 * x(1:2);
                -3  * x(3);
                -3  * x(4);
                5 * x(5:6);
                4 * x(7:8);
                1 * x(9:10)];
    G_r = @(y) [3 * y(1:2); 4 * y(3:4)];

    gradF_x = F_x(x);
    gradF_x_plus = F_x(x_plus);
    
    % Evaluate y at current x to get numeric values for gradG_r calculation
    y_value = y(x);
    gradG_r = G_r(y_value);

    % === Human preference uncertainty ===
    B = [1 1 2 1 1];  % Now 1x5
    quantile = norminv(0.95);
    Sigma_y_aggregated = B * Varp_mins * B';
    D_const = sqrt(Sigma_y_aggregated) * quantile - 200;
    D_tau = [D_const; zeros(nx+ny-1,1)];
    D_tau1 = D_tau;

    y_prev = @(x) [P1(x); P2(x)];  % Single function handle that evaluates both

    % Evaluate y_prev at current x
    y_prev_evaluated = y_prev(x);

    % Evaluate y at current x (y is h(x))
    y_evaluated = y(x);

    % === ∇L multiplier block ===
    % Corrected matrix construction
    block_top = [barA; zeros(ny, nx)]';  % (nx+ny)×nx transposed -> nx×(nx+ny)
    block_bot = [zeros(ny, nx); barB * dy_dx]'; % (nx+ny)×nx transposed -> nx×(nx+ny)
    
    % Verify dimensions
    assert(size(block_top,1) == nx && size(block_top,2) == nx+ny, ...
           'block_top should be %dx%d, is %dx%d', nx, nx+ny, size(block_top));
    assert(size(block_bot,1) == nx && size(block_bot,2) == nx+ny, ...
           'block_bot should be %dx%d, is %dx%d', nx, nx+ny, size(block_bot));
    assert(length(lambda) == nx+ny, 'lambda should be %dx1', nx+ny);
    assert(length(mu_vec) == nx+ny, 'mu_vec should be %dx1', nx+ny);
    
    gradL = block_top * lambda + block_bot * mu_vec;

    % === KKT equations ===
    eq1 = -(gradF_x + (gradG_r' * dy_dx)' + gradL);
    eq2 = -(gradF_x_plus + ...
          [barA; zeros(nx, ny)']' * mu_vec);
    eq3 = -(barL' * lambda);
    eq4 = -(barL' * mu_vec);
    eq5 = [barA * x; barB * y_prev_evaluated] + barL * alpha_vec + D_tau;
    eq6 = [barA * x_plus; barB * y_evaluated] + barL * beta_vec + D_tau1;

    % === Solve ===
    sol = vpasolve([eq1 == 0; eq2 == 0; eq3 == 0; eq4 == 0; eq5 == 0; eq6 == 0], ...
                  [x; x_plus; alpha_vec; beta_vec; lambda; mu_vec]);

    % Convert symbolic solutions to numeric
    solutions = struct();
    solutions.P_final = double([sol.x1; sol.x2; sol.x3; sol.x4; sol.x5; 
                                  sol.x6; sol.x7; sol.x8; sol.x9; sol.x10]);
    solutions.E_P_eq = double([sol.lambda1; sol.lambda2; sol.lambda3; 
                                 sol.lambda4; sol.lambda5]);
    solutions.V_P_eq = diag(double([sol.mu_vec1; sol.mu_vec2; sol.mu_vec3;
                                      sol.mu_vec4; sol.mu_vec5]));
end