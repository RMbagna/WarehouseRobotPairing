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

function solutions = solve_equilibrium(Ep, Varp)
    % === Parameter settings ===
    nx = 10;      % Dimension of x (global state vector)
    ny = 4;       % Dimension of y or r(h)
    nl = 7;       % Dimension of Lagrange multipliers (based on barL)

    % === Structural matrices ===
    barA = diag([5, 5, 1, 3, 9, 3, 10, 4, 8, 8]);  % 10x10
    barB = diag([1, 5, 2, 5]);                    % 4x4
    B = barB;                                     % Same
    barL = [3 -1 -1 -1 0 0 0;
           -1 4 -1 0 -1 -1 0;
           -1 -1 5 -1 -1 0 -1;
           -1 0 -1 3 0 0 -1;
            0 -1 -1 0 4 -1 -1;
            0 -1 0 0 -1 2 0;
            0 0 -1 -1 -1 0 3];                    % 7x7 Laplacian

    % === Covariance-based uncertainty propagation for constraint offset ===
    Sigma_y = Varp;                               % 4x4 covariance of r(h)
    quantile = norminv(0.95);                     % One-sided 95% quantile ≈ 1.6449
    D_const = ([1 1 1 1] * sqrtm(B * Sigma_y * B') * [1 1 1 1]') * quantile - 200;
    D_tau = [D_const; zeros(6,1)];
    D_tau1 = D_tau;

    % === Cost gradients ===
    F_x = @(x) [2 * x(1:2);
                8 * x(3:4);
                6 * x(5:6);
                4 * x(7:8);
                10 * x(9:10)];

    G_r = @(Ey) [6 * Ey(1:2);
                 4 * Ey(3:4)];

    % === Declare symbolic variables ===
    syms x [nx 1] real
    syms x1 [nx 1] real
    syms alpha [nl 1] real
    syms beta [nl 1] real
    syms lambda [nl 1] real
    syms mu [nl 1] real

    % Placeholder for h and r models (left undefined for now)
    syms dh_dx [ny nx] real  % Jacobian of h w.r.t. x
    syms dr_dh [ny ny] real  % Jacobian of r w.r.t. h
    syms r_prev [ny 1] real  % r(h(x(τ-1)))
    syms r_now  [ny 1] real  % r(h(x(τ)))

    % === Build Lagrangian gradient expressions ===
    gradF_x = F_x(x);
    gradF_x1 = F_x(x1);
    Ey = r_now;               % Expected r(h), used in ∇G

    gradG_r_val = G_r(Ey);    % ∇G(E[y])

    % === First-order condition equations ===
    eq1 = gradF_x + gradG_r_val' * dr_dh * dh_dx + ...
          [barA; zeros(2,nx); zeros(2,nx); barB * dr_dh * dh_dx]' * [lambda; mu];

    eq2 = gradF_x1 + ...
          [zeros(2,nx); zeros(2,nx); barA; zeros(2,nx)]' * [lambda; mu];

    eq3 = barL' * lambda;     % ∂L/∂α = 0
    eq4 = barL' * mu;         % ∂L/∂β = 0

    eq5 = [barA * x; barB * r_prev] + barL * alpha + D_tau;
    eq6 = [barA * x1; barB * r_now ] + barL * beta  + D_tau1;

    % === Solve for equilibrium (where all time-derivatives = 0) ===
    solutions = solve([eq1 == 0;
                       eq2 == 0;
                       eq3 == 0;
                       eq4 == 0;
                       eq5 == 0;
                       eq6 == 0], ...
                       [x; x1; alpha; beta; lambda; mu], ...
                       'Real', true);

end


    % 设置变量维度
    nx = 10; nr = 2; nl = 4;

    % 定义变量符号
    syms x [nx 1] real
    syms x1 [nx 1] real
    syms alpha [nl 1] real
    syms beta [nl 1] real
    syms lambda [nl 1] real
    syms mu [nl 1] real

    % 定义参数（可以替换为具体数值或符号）
    Abar = rand(nr, nx);
    Bbar = rand(nr, nr);
    Lbar = rand(nl, nl);
    D = zeros(nl, 1);  % 若 D(τ) 和 D(τ+1) 都是 0

    % 简化的梯度和函数表达（你应替换为你模型中的具体表达）
    gradF_x = x;       % 假设 ∇F = x
    gradF_x1 = x1;     % 假设 ∇F = x1
    dr_dh = eye(nr);   % ∂r/∂h
    dh_dx = rand(nr, nx);  % ∂h/∂x
    gradG_r = ones(nr, 1);  % 假设常数梯度

    r_prev = rand(nr,1);    % r(h(x(τ-1)))
    r_now = rand(nr,1);     % r(h(x(τ)))

    % 构造导数为零的方程组
    eq1 = gradF_x + gradG_r' * dr_dh * dh_dx + ...
          [Abar; zeros(nr,nx); zeros(nr,nx); Bbar * dr_dh * dh_dx]' * [lambda; mu];
    eq2 = gradF_x1 + [zeros(nr,nx); zeros(nr,nx); Abar; zeros(nr,nx)]' * [lambda; mu];
    eq3 = Lbar' * lambda;
    eq4 = Lbar' * mu;
    eq5 = [Abar*x; Bbar*r_prev] + Lbar * alpha + D;
    eq6 = [Abar*x1; Bbar*r_now] + Lbar * beta + D;

    % 联立求解平衡点
    sol = solve([eq1 == 0; eq2 == 0; eq3 == 0; eq4 == 0; eq5 == 0; eq6 == 0], ...
                [x; x1; alpha; beta; lambda; mu]);

    % 显示结果
    disp('Equilibrium Solution:')
    disp(sol)
end
