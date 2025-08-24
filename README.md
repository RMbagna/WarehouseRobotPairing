# Warehouse Multi-Robot Decision Study

This repository hosts the **Warehouse Multi-Robot GUI Experiment**, a research platform designed to study human decision-making in human–robot collaboration contexts. The system collects human responses during multi-robot task allocation scenarios, and applies **Decision Field Theory (DFT)** through the **Apollo.R** framework to estimate cognitive parameters and project choice evolution.

---

## Project Overview

* **Goal:**
  Given the production demands and time constraints, this study examines how human operators perceive different roles—delivering, inspection and assembling—when robotic assistance is introduced. This study explores bias in operator task preferences when working alone vs. alongside a robot in a manufacturing warehouse setting. The goal is to identify where robots can enhance productivity, while understanding the conditions under which workers prefer or reject automation in collaborative tasks.
  
* **Key Features:**
 
  * Human-in-the-loop decision-making experiment design
  * Implementation of **Decision Field Theory (DFT)** for modeling preferences
  * Experimental conditions: Baseline, Robot Bias, and Robot Neutral
  * A **graphical user interface (GUI)** for participants to make robot allocation choices.
  * **Data collection** of human decisions across varying task contexts.
  * Integration with **Apollo.R** to estimate DFT-related parameters from human choice data.
  * **MATLAB parsing** of estimated parameters to simulate preference dynamics and project decision evolution over time.
 
## Setup Requirements

* MATLAB (for Apollo-DFT integration)
* R Software Program (for Apollo-DFT integration)
* Required R package:
  
  install.packages("apollo")

---

## Workflow

1. **Experiment Execution**

   * Participants interact with the GUI and make choices among available robot options.
   * Choices are logged along with experimental conditions.
   * The study includes three main conditions:
     * **Pre-selection:** The goal is to determine whether more is expected from robot or self. We observe inherent biases towards working alone and expectation for the robot assistant.
     * **Task Selection:** The goal is to understand the combination of attributes that best fits your performance in each roles ( Delivering, Inspection, Assembling). Each role offer different base pay, contributing to your total earnings. We observe task preference based on attributes (efficiency, speed, safety, durability, skill), contributing to performance bonus added to your total earnings.
     * **Robot Pairing:** The goal is to undertand how the robot assistant can compliment your performance. In this instance, you choose a robot relative to your performance in each role. We observe your preferences as each robot differ in battery charge (energy), work rate (pace), safe of use (safety), chance of breaking down (reliability), CPU/GPU capacity (computational load). 

2. **Parameter Estimation (Apollo.R)**

   * Human response data is processed with Apollo.R to estimate **DFT parameters**.
   * Outputs include individual-level parameter sets (e.g., attention weights, sensitivity, error variance).

3. **Preference Dynamics Simulation (MATLAB)**

   * Estimated parameters are parsed into MATLAB scripts.
   * The system projects **choice evolution** over time, modeling the dynamic decision process based on DFT.

---

## Repository Structure

```
├── GUI/                  # Experiment interface for human–robot decision study
├── Data/                 # Collected participant response data (Not included, but recommended)
├── ApolloR/              # Scripts for DFT parameter estimation using Apollo.R
├── Matlab/               # MATLAB scripts for simulating preference dynamics
├── Docs/                 # Supporting documents and references
└── README.md             # Project description and usage guide
```

---

## Getting Started

1. **Clone the Repository**

   ```bash
   git clone https://github.com/<your-username>/warehouse-multi-robot.git
   cd warehouse-multi-robot
   ```

2. **Run the GUI**

   * Navigate to `GUI/` and launch the experiment interface.

3. **Estimate Parameters with Apollo.R**

   * Follow the scripts in `ApolloR/` to estimate participant-level DFT parameters.

4. **Simulate Preference Dynamics in MATLAB**

   * Use the provided scripts in `Matlab/` to visualize choice evolution.

---

## Research Context

This project is part of ongoing research in **human–robot collaboration** and **cognitive modeling**.
It leverages **Decision Field Theory (DFT)** to provide a process-level understanding of human preferences under uncertainty and task complexity.

---

## References

* Busemeyer, J. R., & Townsend, J. T. (1993). Decision field theory: A dynamic-cognitive approach to decision making in an uncertain environment. Psychological Review, 100(3), 432–459.
* Hess, S., Palma, D., & Daly, A. (2018). Apollo: A flexible, powerful and customisable freeware package for choice model estimation and application. Journal of Choice Modelling, 28, 100170. https://doi.org/10.1016/j.jocm.2018.100170
* Hancock, T. O., Choudhury, C. F., Hess, S., & Stathopoulos, A. (2021). An accumulation of preference: Two alternative dynamic models for understanding transport choices. Transportation Research Part B: Methodological, 149, 250–282. https://doi.org/10.1016/j.trb.2021.04.001

---

## Citation

If you use this project in your research, please cite:

```bibtex
@misc{warehouse-multi-robot,
  author       = {Ryan Mbagna Nanko},
  title        = {Warehouse Multi-Robot Pairing},
  year         = {2025},
  howpublished = {\url{https://github.com/RMbagna/WarehouseRobotPairing}}
}

@misc{nanko2025thesis,
  author       = {Ryan Mbagna Nanko},
  title        = {Decision Field Theory for Human-Multi-robot Collaboration: Human-centric Decision-making for Multi-robot Systems},
  year         = {2025},
  howpublished = {\url{https://open.clemson.edu/cgi/viewcontent.cgi?article=5648&context=all_theses}},
  note         = {Master's thesis, Clemson University}
}
````

---

## Author

**Ryan Mbagna Nanko**
*Clemson University – I²R Lab (Interdisciplinary & Intelligent Research)*

For questions or collaborations, reach out:
📧 \[[ryanmbagna@gmail.com](mailto:ryanmbagna@gmail.com)] | \[[rmbagna@clemson.edu](mailto:rmbagna@clemson.edu)]






