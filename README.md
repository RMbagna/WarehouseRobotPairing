# Warehouse Multi-Robot Decision Study

This repository hosts the **Warehouse Multi-Robot GUI Experiment**, a research platform designed to study human decision-making in human–robot collaboration contexts. The system collects human responses during multi-robot task allocation scenarios, and applies **Decision Field Theory (DFT)** through the **Apollo.R** framework to estimate cognitive parameters and project choice evolution.

---

## 📌 Project Overview

* **Goal:**
  To investigate how humans form and evolve preferences when interacting with multiple robots in a warehouse task environment.

* **Key Features:**

  * A **graphical user interface (GUI)** for participants to make robot allocation choices.
  * **Data collection** of human decisions across varying task contexts.
  * Integration with **Apollo.R** to estimate DFT-related parameters from human choice data.
  * **MATLAB parsing** of estimated parameters to simulate preference dynamics and project decision evolution over time.

---

## ⚙️ Workflow

1. **Experiment Execution**

   * Participants interact with the GUI and make choices among available robot options.
   * Choices are logged along with experimental conditions.

2. **Parameter Estimation (Apollo.R)**

   * Human response data is processed with Apollo.R to estimate **DFT parameters**.
   * Outputs include individual-level parameter sets (e.g., attention weights, sensitivity, error variance).

3. **Preference Dynamics Simulation (MATLAB)**

   * Estimated parameters are parsed into MATLAB scripts.
   * The system projects **choice evolution** over time, modeling the dynamic decision process based on DFT.

---

## 📂 Repository Structure

```
├── GUI/                  # Experiment interface for human–robot decision study
├── Data/                 # Collected participant response data
├── ApolloR/              # Scripts for DFT parameter estimation using Apollo.R
├── Matlab/               # MATLAB scripts for simulating preference dynamics
├── Docs/                 # Supporting documents and references
└── README.md             # Project description and usage guide
```

---

## 🚀 Getting Started

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

## 🧠 Research Context

This project is part of ongoing research in **human–robot collaboration** and **cognitive modeling**.
It leverages **Decision Field Theory (DFT)** to provide a process-level understanding of human preferences under uncertainty and task complexity.

---

## 📖 References

* Busemeyer, J. R., & Townsend, J. T. (1993). *Decision field theory: A dynamic-cognitive approach to decision making in an uncertain environment.* Psychological Review, 100(3), 432–459.
* Hess, S., Palma, D., & Daly, A. (2018). *Apollo: A flexible, powerful and customisable freeware package for choice model estimation and application.* Journal of Choice Modelling, 28, 100170.

---

## 👨‍💻 Author

**Ryan Mbagna Nanko**
Clemson University – I²R Lab (Interdisciplinary & Intelligent Research)

---

Do you want me to also add a **"How to Cite"** section (BibTeX style) for when other researchers use your repo in publications?
