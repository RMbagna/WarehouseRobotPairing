from flask import Flask, request, jsonify
import rpy2.robjects as robjects
from rpy2.robjects.packages import importr
import pandas as pd
import json

app = Flask(__name__)

# Load required R packages
try:
    apollo = importr('apollo')
    base = importr('base')
    stats = importr('stats')
except Exception as e:
    print(f"Error loading R packages: {e}")

@app.route('/estimate_dft', methods=['POST'])
def estimate_dft():
    try:
        # Get JSON data from request
        pairing_data = request.json
        
        # Convert to R dataframe
        with robjects.local_context() as lc:
            # Create R data frame
            r_data = robjects.DataFrame(pairing_data)
            
            # Define Apollo model in R
            robjects.r('''
            estimate_dft <- function(df) {
                ### Initialise code
                apollo_initialise()
                
                ### Set core controls
                apollo_control = list(
                    modelName = "DFT_Resource_Allocation",
                    modelDescr = "DFT model on robot selection with 5 attributes",
                    indivID = "participantid",
                    panelData = FALSE,
                    nCores = 4
                )
                
                ### Define model parameters
                apollo_beta = c(
                    asc_1 = 0, asc_2 = 0, asc_3 = 0,
                    b_energy = 1,
                    b_pace = 0,
                    b_safety = 1,
                    b_reliability = 0,
                    b_intelligence = 1,
                    phi1 = 1,
                    phi2 = 0,
                    error_sd = 1,
                    timesteps = 1
                )
                
                apollo_fixed = c("asc_3", "b_reliability")
                
                ### Define model
                apollo_probabilities = function(apollo_beta, apollo_inputs, functionality="estimate") {
                    apollo_attach(apollo_beta, apollo_inputs)
                    on.exit(apollo_detach(apollo_beta, apollo_inputs))
                    
                    P = list()
                    
                    dft_settings = list(
                        alternatives = c(alt1=1, alt2=2, alt3=3),
                        avail = list(alt1=1, alt2=1, alt3=1),
                        choiceVar = choice,
                        attrValues = list(
                            alt1 = list(
                                energy = pmax(0.01, pmin(1, robot1energy)),
                                pace = pmax(0.01, pmin(1, robot1pace)),
                                safety = pmax(0.01, pmin(1, robot1safety)),
                                reliability = pmax(0.01, pmin(1, robot1reliability)),
                                intelligence = pmax(0.01, pmin(1, robot1intelligence))
                            ),
                            alt2 = list(
                                energy = pmax(0.01, pmin(1, robot2energy)),
                                pace = pmax(0.01, pmin(1, robot2pace)),
                                safety = pmax(0.01, pmin(1, robot2safety)),
                                reliability = pmax(0.01, pmin(1, robot2reliability)),
                                intelligence = pmax(0.01, pmin(1, robot2intelligence))
                            ),
                            alt3 = list(
                                energy = pmax(0.01, pmin(1, robot3energy)),
                                pace = pmax(0.01, pmin(1, robot3pace)),
                                safety = pmax(0.01, pmin(1, robot3safety)),
                                reliability = pmax(0.01, pmin(1, robot3reliability)),
                                intelligence = pmax(0.01, pmin(1, robot3intelligence))
                            )
                        ),
                        altStart = list(alt1=asc_1, alt2=asc_2, alt3=asc_3),
                        attrWeights = list(
                            energy = exp(b_energy)),
                            pace = exp(b_pace)),
                            safety = exp(b_safety)),
                            reliability = exp(b_reliability)),
                            intelligence = exp(b_intelligence))
                        ),
                        attrScalings = 1,
                        procPars = list(
                            error_sd = pmax(0.1, error_sd)),
                            timesteps = 1 + exp(pmin(5, timesteps)),
                            phi1 = phi1,
                            phi2 = phi2
                        ),
                        panelData = TRUE,
                        componentName = "ResourceAllocationDFT"
                    )
                    
                    P[["model"]] = apollo_dft(dft_settings, functionality)
                    P = apollo_prepareProb(P, apollo_inputs, functionality)
                    return(P)
                }
                
                ### Estimate model
                model = apollo_estimate(apollo_beta, apollo_fixed, apollo_probabilities, apollo_inputs)
                
                ### Return results
                return(list(
                    asc_1 = model$estimate["asc_1"],
                    asc_2 = model$estimate["asc_2"],
                    asc_3 = model$estimate["asc_3"],
                    b_energy = model$estimate["b_energy"],
                    b_pace = model$estimate["b_pace"],
                    b_safety = model$estimate["b_safety"],
                    b_reliability = model$estimate["b_reliability"],
                    b_intelligence = model$estimate["b_intelligence"],
                    phi1 = model$estimate["phi1"],
                    phi2 = model$estimate["phi2"],
                    error_sd = model$estimate["error_sd"],
                    timesteps = model$estimate["timesteps"]
                ))
            }
            ''')
            
            # Call the R function
            estimate_dft = robjects.globalenv['estimate_dft']
            results = estimate_dft(r_data)
            
            # Convert results to Python dict
            params = {
                'asc_1': results.rx2('asc_1')[0],
                'asc_2': results.rx2('asc_2')[0],
                'asc_3': results.rx2('asc_3')[0],
                'b_energy': results.rx2('b_energy')[0],
                'b_pace': results.rx2('b_pace')[0],
                'b_safety': results.rx2('b_safety')[0],
                'b_reliability': results.rx2('b_reliability')[0],
                'b_intelligence': results.rx2('b_intelligence')[0],
                'phi1': results.rx2('phi1')[0],
                'phi2': results.rx2('phi2')[0],
                'error_sd': results.rx2('error_sd')[0],
                'timesteps': results.rx2('timesteps')[0]
            }
            
            return jsonify(params)
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000)