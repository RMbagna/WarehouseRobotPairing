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
    nx = 10; ny = 4;

    % === Structural matrices ===
    barA = diag([1, 2, 1, 2, 1, 1, 2, 1, 2, -1]);
    barB = diag([1, 2, 2, 1]);
    L = [3 -1 -1 -1 0 0 0;
         -1 4 -1 0 -1 -1 0;
         -1 -1 5 -1 -1 0 -1;
         -1 0 -1 3 0 0 -1;
          0 -1 -1 0 4 -1 -1;
          0 -1 0 0 -1 2 0;
          0 0 -1 -1 -1 0 3];
    I2 = eye(2);
    barL = kron(L, I2);

    % === Symbolic variables ===
    syms x [nx 1] real
    syms x_plus [nx 1] real
    syms alpha_vec [nx+ny 1] real
    syms beta_vec [nx+ny 1] real
    syms lambda [nx+ny 1] real
    syms mu_vec [nx+ny 1] real

   % === Define h(x, p) ===
    % Define how robot states affect preferences
    P1 = @(x) Ep_mins(1:2) + x(3:4) + x(9:10);  % P1 depends on robot states 3-4 and 9-10
    P2 = @(x) Ep_mins(3:4) + x(5:6) + x(7:8) - 2*x(9:10);  % P2 depends on robot states 5-8 and 9-10
    
    % Define the updated preferences after robot state changes
    P1_plus = @(x) Ep_mins(1:2) + x(3:4) + x(9:10);
    P2_plus = @(x) Ep_mins(3:4) + x(5:6) + x(7:8) - 2*x(9:10);
    
    % Define the human response function h(x,p)
    h = @(x) [P1_plus(x); P2_plus(x)];
    
    % Human output y is directly based on h(x,p)
    y = h;
    
    % Compute Jacobians for sensitivity analysis
    dh_dx = jacobian(h(x), x);
    dy_dx = dh_dx;

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
    gradG_r = G_r(y);

    % === Human preference uncertainty ===
    Sigma_y = Varp_mins;
    B = [1 1 2 1];
    quantile = norminv(0.95);
    D_const = ([1 1 1 1] * sqrtm(B * Sigma_y * B') * [1 1 1 1]') * quantile - 200;
    D_tau = [D_const; zeros(nx+ny-1,1)];
    D_tau1 = D_tau;

    y_prev = [P1; P2];

    % === ∇L multiplier block ===
    block_top = [barA; zeros(nx, ny)']';
    block_bot = [zeros(nx, nx); (barB * dy_dx)]';
    gradL = block_top * lambda + block_bot * mu_vec;

    % === KKT equations ===
    eq1 = -(gradF_x + (gradG_r' * dy_dx)' + gradL);
    eq2 = -(gradF_x_plus + ...
          [barA; zeros(nx, ny)']' * mu_vec);
    eq3 = -(barL' * lambda);
    eq4 = -(barL' * mu_vec);
    eq5 = [barA * x; barB * y_prev] + barL * alpha_vec + D_tau;
    eq6 = [barA * x_plus; barB * y] + barL * beta_vec + D_tau1;

    % === Solve ===
    solutions = solve([eq1 == 0;
                       eq2 == 0;
                       eq3 == 0;
                       eq4 == 0;
                       eq5 == 0;
                       eq6 == 0], ...
                       [x; x_plus; alpha_vec; beta_vec; lambda; mu_vec], ...
                       'Real', true);
end
