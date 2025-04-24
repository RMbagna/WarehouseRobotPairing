class DFTModel {
    constructor() {
        // Default parameters
        this.phi1 = 0.5;
        this.phi2 = 0.8;
        this.tau = 10;
        this.error_sd = 0.1;
        this.beta_weights = [0.3, 0.2, 0.4, 0, 0.5];
        this.initial_P = [0, 0, 0, 0];
    }

    async estimateParameters(pairingData) {
        try {
            // Convert pairing data to format expected by R
            const formattedData = this._formatDataForR(pairingData);
            
            // Call Python service
            const response = await fetch('http://localhost:5000/estimate_dft', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formattedData)
            });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const params = await response.json();
            
            // Update model parameters
            this.phi1 = params.phi1;
            this.phi2 = params.phi2;
            this.tau = 1 + Math.exp(Math.min(5, params.timesteps));
            this.error_sd = params.error_sd;
            this.beta_weights = [
                params.b_energy,
                params.b_pace,
                params.b_safety,
                params.b_reliability,
                params.b_intelligence
            ];
            this.initial_P = [
                params.asc_1,
                params.asc_2,
                params.asc_3,
                0  // Neutral alternative
            ];
            
            return true;
            
        } catch (error) {
            console.error("Error estimating parameters:", error);
            return false;
        }
    }

    _formatDataForR(pairingData) {
        // Convert to format expected by R script
        return pairingData.map(trial => ({
            participantid: trial.participantId || 'anonymous',
            trial: trial.trialNumber || 1,
            staketype: trial.stakeType || 'low',
            choice: trial.choice,
            timeSpent: trial.timeSpent || 0,
            
            // Robot 1 attributes
            robot1energy: trial.robot1Attributes[0],
            robot1pace: trial.robot1Attributes[1],
            robot1safety: trial.robot1Attributes[2],
            robot1reliability: trial.robot1Attributes[3],
            robot1intelligence: trial.robot1Attributes[4],
            
            // Robot 2 attributes
            robot2energy: trial.robot2Attributes[0],
            robot2pace: trial.robot2Attributes[1],
            robot2safety: trial.robot2Attributes[2],
            robot2reliability: trial.robot2Attributes[3],
            robot2intelligence: trial.robot2Attributes[4],
            
            // Robot 3 attributes
            robot3energy: trial.robot3Attributes[0],
            robot3pace: trial.robot3Attributes[1],
            robot3safety: trial.robot3Attributes[2],
            robot3reliability: trial.robot3Attributes[3],
            robot3intelligence: trial.robot3Attributes[4]
        }));
    }

    // ... rest of your DFTModel class remains the same ...
}