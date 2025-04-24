import tkinter as tk
from tkinter import ttk, messagebox
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import json
import os
from datetime import datetime

class RobotAdjustmentApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Robot Attribute Adjustment System")
        self.root.geometry("1000x700")
        
        # Initialize data storage
        self.participant_data = {
            "participant_id": np.random.randint(1000, 9999),
            "trials": [],
            "current_trial": 0
        }
        
        # Robot roles and attributes
        self.roles = ["Delivery", "Inspection", "Assembling"]
        self.attributes = ["Energy", "Pace", "Safety", "Reliability", "Intelligence"]
        
        # Create GUI components
        self.create_widgets()
        
        # Start first trial
        self.new_trial()
    
    def create_widgets(self):
        # Main frame
        self.main_frame = ttk.Frame(self.root, padding="10")
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Role selection
        self.role_frame = ttk.LabelFrame(self.main_frame, text="Robot Role", padding="10")
        self.role_frame.pack(fill=tk.X, pady=5)
        
        self.role_var = tk.StringVar()
        for role in self.roles:
            ttk.Radiobutton(self.role_frame, text=role, variable=self.role_var, 
                          value=role, command=self.update_role).pack(side=tk.LEFT, padx=10)
        
        # Prediction display
        self.prediction_frame = ttk.LabelFrame(self.main_frame, text="Model Prediction", padding="10")
        self.prediction_frame.pack(fill=tk.X, pady=5)
        
        self.prediction_labels = {}
        for attr in self.attributes:
            frame = ttk.Frame(self.prediction_frame)
            frame.pack(fill=tk.X, pady=2)
            
            ttk.Label(frame, text=f"{attr}:", width=10).pack(side=tk.LEFT)
            self.prediction_labels[attr] = ttk.Label(frame, text="0.00", width=6)
            self.prediction_labels[attr].pack(side=tk.LEFT)
            
            ttk.Progressbar(frame, orient=tk.HORIZONTAL, length=200, 
                          mode='determinate', variable=tk.DoubleVar(value=0)).pack(side=tk.LEFT, padx=5)
        
        # Adjustment sliders
        self.adjustment_frame = ttk.LabelFrame(self.main_frame, text="Adjust Attributes", padding="10")
        self.adjustment_frame.pack(fill=tk.X, pady=5)
        
        self.sliders = {}
        self.slider_vars = {}
        
        for attr in self.attributes:
            frame = ttk.Frame(self.adjustment_frame)
            frame.pack(fill=tk.X, pady=2)
            
            ttk.Label(frame, text=f"{attr}:", width=10).pack(side=tk.LEFT)
            
            self.slider_vars[attr] = tk.DoubleVar(value=0.5)
            self.sliders[attr] = ttk.Scale(frame, from_=0, to=1, orient=tk.HORIZONTAL, 
                                         length=200, variable=self.slider_vars[attr],
                                         command=lambda v, a=attr: self.update_slider_value(a))
            self.sliders[attr].pack(side=tk.LEFT, padx=5)
            
            self.slider_vars[attr].trace_add("write", lambda *args, a=attr: self.update_chart(a))
            
            val_frame = ttk.Frame(frame)
            val_frame.pack(side=tk.LEFT, padx=5)
            
            ttk.Label(val_frame, textvariable=self.slider_vars[attr], width=5).pack()
        
        # Satisfaction rating
        self.rating_frame = ttk.LabelFrame(self.main_frame, text="Satisfaction Rating", padding="10")
        self.rating_frame.pack(fill=tk.X, pady=5)
        
        self.rating_var = tk.IntVar(value=3)
        for i in range(1, 6):
            ttk.Radiobutton(self.rating_frame, text=str(i), variable=self.rating_var, 
                           value=i).pack(side=tk.LEFT, padx=5)
            ttk.Label(self.rating_frame, text="★", foreground="gold" if i <= 3 else "gray").pack(side=tk.LEFT)
        
        # Visualization
        self.viz_frame = ttk.LabelFrame(self.main_frame, text="Attribute Comparison", padding="10")
        self.viz_frame.pack(fill=tk.BOTH, expand=True, pady=5)
        
        self.fig, self.ax = plt.subplots(figsize=(6, 4))
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.viz_frame)
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        
        # Control buttons
        self.control_frame = ttk.Frame(self.main_frame)
        self.control_frame.pack(fill=tk.X, pady=10)
        
        ttk.Button(self.control_frame, text="Save Configuration", 
                  command=self.save_configuration).pack(side=tk.LEFT, padx=5)
        ttk.Button(self.control_frame, text="Next Trial", 
                  command=self.new_trial).pack(side=tk.LEFT, padx=5)
        ttk.Button(self.control_frame, text="View Analysis", 
                  command=self.show_analysis).pack(side=tk.RIGHT, padx=5)
    
    def update_role(self):
        """Update interface when role changes"""
        self.generate_prediction()
        self.update_chart()
    
    def generate_prediction(self):
        """Generate a mock prediction (replace with your actual model)"""
        role = self.role_var.get()
        
        # Mock prediction - in practice, replace with your MATLAB/Python model
        np.random.seed(hash(role) % 1000)  # For consistent "predictions" per role
        self.current_prediction = {
            attr: np.clip(np.random.normal(loc=0.5, scale=0.2), 0, 1)
            for attr in self.attributes
        }
        
        # Update prediction display
        for attr, value in self.current_prediction.items():
            self.prediction_labels[attr].config(text=f"{value:.2f}")
            self.slider_vars[attr].set(round(value, 2))
    
    def update_slider_value(self, attr):
        """Update displayed slider value"""
        value = self.slider_vars[attr].get()
        self.slider_vars[attr].set(round(value, 2))
    
    def update_chart(self, *args):
        """Update the radar chart visualization"""
        self.ax.clear()
        
        # Prepare data
        pred_values = list(self.current_prediction.values())
        user_values = [self.slider_vars[attr].get() for attr in self.attributes]
        
        # Radar chart
        angles = np.linspace(0, 2 * np.pi, len(self.attributes), endpoint=False)
        angles = np.concatenate((angles, [angles[0]]))
        
        pred_values = np.concatenate((pred_values, [pred_values[0]]))
        user_values = np.concatenate((user_values, [user_values[0]]))
        
        self.ax.plot(angles, pred_values, 'o-', linewidth=2, label='Prediction')
        self.ax.fill(angles, pred_values, alpha=0.25)
        
        self.ax.plot(angles, user_values, 'o-', linewidth=2, label='Your Adjustment')
        self.ax.fill(angles, user_values, alpha=0.25)
        
        self.ax.set_xticks(angles[:-1])
        self.ax.set_xticklabels(self.attributes)
        self.ax.set_yticks([0, 0.5, 1])
        self.ax.set_title(f"Attribute Comparison - {self.role_var.get()}")
        self.ax.legend(loc='upper right')
        
        self.canvas.draw()
    
    def save_configuration(self):
        """Save the current adjustment and rating"""
        if not self.role_var.get():
            messagebox.showerror("Error", "Please select a robot role")
            return
        
        adjusted_values = {attr: self.slider_vars[attr].get() for attr in self.attributes}
        
        trial_data = {
            "trial_number": self.participant_data["current_trial"] + 1,
            "role": self.role_var.get(),
            "timestamp": datetime.now().isoformat(),
            "prediction": self.current_prediction,
            "adjusted": adjusted_values,
            "satisfaction": self.rating_var.get(),
            "differences": {
                attr: adjusted_values[attr] - self.current_prediction[attr]
                for attr in self.attributes
            }
        }
        
        self.participant_data["trials"].append(trial_data)
        self.participant_data["current_trial"] += 1
        
        # Save to file
        os.makedirs("participant_data", exist_ok=True)
        filename = f"participant_data/participant_{self.participant_data['participant_id']}.json"
        with open(filename, 'w') as f:
            json.dump(self.participant_data, f, indent=2)
        
        messagebox.showinfo("Saved", "Configuration saved successfully!")
    
    def new_trial(self):
        """Start a new trial"""
        if len(self.participant_data["trials"]) > 0:
            if not messagebox.askyesno("New Trial", "Start a new trial? Current data will be saved."):
                return
        
        # Reset for new trial
        self.role_var.set("")
        self.rating_var.set(3)
        self.generate_prediction()
    
    def show_analysis(self):
        """Show analysis of collected data"""
        if not self.participant_data["trials"]:
            messagebox.showerror("Error", "No trial data to analyze")
            return
        
        # Create analysis window
        analysis_win = tk.Toplevel(self.root)
        analysis_win.title("Analysis Results")
        analysis_win.geometry("800x600")
        
        # Calculate metrics
        trials = self.participant_data["trials"]
        mae = {
            attr: np.mean([abs(t["differences"][attr]) for t in trials])
            for attr in self.attributes
        }
        
        satisfaction = [t["satisfaction"] for t in trials]
        avg_accuracy = [
            1 - np.mean(list(t["differences"].values()))
            for t in trials
        ]
        
        # Create tabs
        notebook = ttk.Notebook(analysis_win)
        
        # MAE Tab
        mae_frame = ttk.Frame(notebook)
        notebook.add(mae_frame, text="Attribute Errors")
        
        fig1, ax1 = plt.subplots(figsize=(6, 4))
        ax1.bar(mae.keys(), mae.values())
        ax1.set_title("Mean Absolute Error by Attribute")
        ax1.set_ylabel("MAE")
        ax1.set_ylim(0, 1)
        
        canvas1 = FigureCanvasTkAgg(fig1, master=mae_frame)
        canvas1.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        
        # Satisfaction vs Accuracy Tab
        sat_frame = ttk.Frame(notebook)
        notebook.add(sat_frame, text="Satisfaction Analysis")
        
        fig2, ax2 = plt.subplots(figsize=(6, 4))
        ax2.scatter(avg_accuracy, satisfaction)
        ax2.set_title("Satisfaction vs Prediction Accuracy")
        ax2.set_xlabel("Accuracy (1 - MAE)")
        ax2.set_ylabel("Satisfaction Rating")
        ax2.set_xlim(0, 1)
        ax2.set_ylim(0.5, 5.5)
        
        # Calculate correlation
        r = np.corrcoef(avg_accuracy, satisfaction)[0, 1]
        ax2.text(0.05, 0.95, f"r = {r:.2f}", transform=ax2.transAxes, 
                verticalalignment='top', bbox=dict(facecolor='white', alpha=0.8))
        
        canvas2 = FigureCanvasTkAgg(fig2, master=sat_frame)
        canvas2.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        
        notebook.pack(fill=tk.BOTH, expand=True)

if __name__ == "__main__":
    root = tk.Tk()
    app = RobotAdjustmentApp(root)
    root.mainloop()