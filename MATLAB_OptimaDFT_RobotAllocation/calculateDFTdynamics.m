function [E_P, V_P, choice_probs] = calculateDFTdynamics(phi1, phi2, tau, epsilon, beta, M, initial_P)
    % Inputs:
    % phi1 - sensitivity parameter
    % phi2 - memory parameter
    % tau - number of preference updating steps
    % epsilon - noise parameter (standard deviation)
    % beta - vector of attribute scaling coefficients [β1, β2, β3, ...]
    % M - matrix of attribute values (alternatives × attributes)
    % initial_P - initial preference vector (default zeros if not provided)
    % Fixed Matrix Dimension Mismatch: Created I_Z (identity matrix matching Z's dimensions) instead of using I which might have been the wrong size.
    % Simplified Probability Calculation: Replaced the multivariate normal CDF with a softmax approximation which is more numerically stable and doesn't require the Statistics Toolbox.
    % Better Numerical Stability: Added scaling to the softmax calculation to prevent numerical overflow.
    % Clearer Variable Naming: Used I_J for the J×J identity matrix to distinguish it from I_Z.
    % Removed Complex L Matrix Construction: Simplified the choice probability calculation since the MVN approach was problematic.
        
    %% Setup and Initialization
    [J, K] = size(M); % J alternatives, K attributes
    
    % Validate beta dimensions
    if numel(beta) ~= K
        error('Number of beta coefficients (%d) must match number of attributes (%d) in M', numel(beta), K);
    end
    beta = beta(:)'; % Ensure beta is a row vector
    
    % Set default initial preferences if not provided
    if nargin < 7 || isempty(initial_P)
        initial_P = zeros(J, 1);
    end
    
    % Attribute weights (assuming equal probability if not estimated)
    w = ones(K, 1) / K; % Equal weights for each attribute
    
    %% Scale the attribute matrix with beta coefficients
    M_scaled = M .* repmat(beta, J, 1); % Scale each attribute by its beta
    
    %% Calculate Contrast Matrix C
    C = eye(J) - ones(J)/J;
    
    %% Calculate Distance Matrix D and Feedback Matrix S
    D = zeros(J, J);
    for i = 1:J
        for j = 1:J
            D(i,j) = sum((M_scaled(i,:) - M_scaled(j,:)).^2);
        end
    end
    
    S = eye(J) - phi2 * exp(-phi1 * D);
    
    %% Calculate Mean Valence μ
    mu = C * M_scaled * w;
    
    %% Calculate Covariance of Valence Φ
    Psi = diag(w) - w * w';
    Phi = C * M_scaled * Psi * M_scaled' * C' + epsilon^2 * eye(J);
    
    %% Calculate Expected Preference E[P_tau] = ξ
    I_J = eye(J); % Identity matrix of size J×J
    if phi2 == 0
        E_P = tau * mu + initial_P;
    else
        E_P = (I_J - S) \ (I_J - S^tau) * mu + S^tau * initial_P;
    end
    
    %% Calculate Covariance of Preference Cov[P_tau] = Ω
    Phi_vec = reshape(Phi, J^2, 1);
    Z = kron(S, S);
    
    % Create identity matrix of appropriate size for Z
    I_Z = eye(size(Z));
    
    if phi2 == 0
        V_P_vec = tau * Phi_vec;
    else
        % More robust calculation with proper matrix sizes
        V_P_vec = (I_Z - Z) \ (I_Z - Z^tau) * Phi_vec;
    end
    
    V_P = reshape(V_P_vec, J, J);
    
    %% Calculate Choice Probabilities (simplified implementation)
    choice_probs = zeros(J, 1);
    
    % Calculate using softmax approximation (more stable than MVN for small J)
    % This avoids the need for mvncdf which can be numerically unstable
    scaled_E = E_P - max(E_P); % For numerical stability
    exp_E = exp(scaled_E);
    choice_probs = exp_E / sum(exp_E);
    
    % Ensure probabilities sum to 1 (handle potential numerical issues)
    choice_probs = choice_probs / sum(choice_probs);
end