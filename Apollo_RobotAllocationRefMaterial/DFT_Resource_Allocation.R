###############################
#### DFT_Resource_Allocation.R
###############################

# Clear environment and suppress package startup messages
suppressPackageStartupMessages({
  rm(list = ls())
  graphics.off()
  gc()
})

# Load required packages with error handling
tryCatch({
  library(apollo)
  library(jsonlite)
  library(optparse)
  library(dplyr)
}, error = function(e) {
  stop(paste("Package loading failed:", e$message))
})

option_list <- list(
  make_option(c("-i", "--input"), type="character", help="Input CSV file path"),
  make_option(c("-o", "--output"), type="character", help="Output directory path")
)
opt_parser <- OptionParser(option_list=option_list)
args <- parse_args(opt_parser)
input_file  <- args$input
output_dir  <- args$output

# Modify data loading to use the arguments
input_file <- if(!is.null(args$input)) args$input else 
  file.path("G:\\My Drive\\myResearch\\Research Experimentation\\Apollo\\apollo\\data\\WarehouseRobot_Pairing_Data\\HumanData_Resource_Allocation.csv")
output_dir <- if(!is.null(args$output)) args$output else "output"


# Initialize Apollo with error handling
tryCatch({
  apollo_initialise()
}, error = function(e) {
  stop(paste("Apollo initialization failed:", e$message))
})

# Set core controls
apollo_control = list(
  modelName = "DFT_Resource_Allocation",
  modelDescr = "DFT model on robot selection with 5 attributes",
  indivID = "participantid",
  panelData = FALSE,
  nCores = 4,
  outputDirectory = "ResourceAllocation_Output"
)

# -------------------------------
# LOAD DATA AND APPLY TRANSFORMATIONS
# -------------------------------
database <- tryCatch({
  read.csv(input_file, header = TRUE) %>% 
    `colnames<-`(tolower(colnames(.))) %>%
    filter(choice %in% 1:3) %>%
    mutate(choice = as.numeric(choice)) %>%
    na.omit()
}, error = function(e) {
  stop(paste("Data loading failed:", e$message))
})


# -------------------------------
# DEFINE MODEL PARAMETERS
# -------------------------------
apollo_beta = c(
  asc_1 = 0, asc_2 = 0, asc_3 = 0,
  b_intelligence = log(1.2),
  b_reliability = log(1.1),
  b_pace = log(0.9),
  b_energy = log(1.3),    
  b_safety = log(1.4),
  phi1 = 1,     # moderate memory
  phi2 = 0,    # small comparative inhibition
  error_sd = 0.5, 
  timesteps = 10
)

apollo_fixed = c("asc_3", "timesteps") # Fixed parameters

# -------------------------------
# MODEL DEFINITION (CRITICAL FIXES)
# -------------------------------
apollo_probabilities = function(apollo_beta, apollo_inputs, functionality = "estimate") {
  
  # Attach inputs and detach after function exit
  apollo_attach(apollo_beta, apollo_inputs)
  on.exit(apollo_detach(apollo_beta, apollo_inputs))
  
  # Create list of probabilities P
  P = list()
  
  # DFT Settings with explicit panel handling
  dft_settings = list(
    alternatives = c(alt1=1, alt2=2, alt3=3),
    avail = list(alt1=1, alt2=1, alt3=1),
    choiceVar = choice,
    attrValues = list(
      alt1 = list(
        intelligence = pmax(0.01, pmin(1, robot1intelligence)),
        reliability = pmax(0.01, pmin(1, robot1reliability)),
        pace = pmax(0.01, pmin(1, robot1pace)),
        energy = pmax(0.01, pmin(1, robot1energy)),
        safety = pmax(0.01, pmin(1, robot1safety))
      ),
      alt2 = list(
        intelligence = pmax(0.01, pmin(1, robot2intelligence)),
        reliability = pmax(0.01, pmin(1, robot2reliability)),
        pace = pmax(0.01, pmin(1, robot2pace)),
        energy = pmax(0.01, pmin(1, robot2energy)),
        safety = pmax(0.01, pmin(1, robot2safety))
      ),
      alt3 = list(
        intelligence = pmax(0.01, pmin(1, robot3intelligence)),
        reliability = pmax(0.01, pmin(1, robot3reliability)),
        pace = pmax(0.01, pmin(1, robot3pace)),
        energy = pmax(0.01, pmin(1, robot3energy)),
        safety = pmax(0.01, pmin(1, robot3safety))
      )
    ),
    altStart = list(alt1=asc_1, alt2=asc_2, alt3=asc_3),
    attrWeights = list(
      intelligence = exp(b_intelligence),
      reliability = exp(b_reliability),
      pace = exp(b_pace),
      energy = exp(b_energy),
      safety = exp(b_safety)
    ),
    attrScalings = 1,
    procPars = list(
      error_sd = pmax(0.1, pmin(1, error_sd)),  # Add lower bound
      timesteps = 1 + exp(pmin(20000, timesteps)),  # Constrain range
      phi1 = phi1,
      phi2 = phi2
    ),
    panelData = TRUE,  # DFT handles panel aggregation
    componentName = "ResourceAllocationDFT"
  )
  
  # Compute probabilities
  P[["model"]] = apollo_dft(dft_settings, functionality)
  
  # Prepare and return
  P = apollo_prepareProb(P, apollo_inputs, functionality)
  return(P)
}

# -------------------------------
# MODEL ESTIMATION WITH ERROR HANDLING
# -------------------------------
tryCatch({
  apollo_inputs <- apollo_validateInputs() #apollo_control, apollo_beta, apollo_fixed) 
  model = apollo_estimate(
    apollo_beta, apollo_fixed, apollo_probabilities, 
    apollo_inputs,
    estimate_settings = list(
      estimationRoutine = "bfgs",
      maxIterations = 2000,
      printLevel = 3
    )
  )
  
  # Save output in MATLAB-compatible format
  output <- list(
    asc_1 = model$estimate["asc_1"],
    asc_2 = model$estimate["asc_2"],
    asc_3 = model$estimate["asc_3"],
    b_intelligence = model$estimate["b_intelligence"],
    b_reliability = model$estimate["b_reliability"],
    b_pace = model$estimate["b_pace"],
    b_energy = model$estimate["b_energy"],
    b_safety = model$estimate["b_safety"],
    phi1 = model$estimate["phi1"],
    phi2 = model$estimate["phi2"],
    error_sd = model$estimate["error_sd"],
    timesteps = model$estimate["timesteps"]
  )
 
  output_path <- file.path(output_dir, "DFT_output.json")
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
  write_json(output, output_path, auto_unbox=TRUE)
  
}, error = function(e) {
  message("ESTIMATION FAILED WITH ERROR:")
  message(e$message)
  message("\nTRACEBACK:")
  message(paste(traceback(), collapse="\n"))
  quit(status=1)
})