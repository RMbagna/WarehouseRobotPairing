import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import requests
from io import BytesIO

# Scenario data
scenarios = [
    {"image": "banner-composite-duo.jpg", "description": "Energy conservation in a critical situation"},
    {"image": "banner-composite-duo.jpg", "description": "Maintaining pace during a time-sensitive operation"},
    {"image": "banner-composite-duo.jpg", "description": "Ensuring safety in a hazardous environment"},
    {"image": "banner-composite-duo.jpg", "description": "Guaranteeing reliability of performance under pressure"},
    {"image": "banner-composite-duo.jpg", "description": "Demonstrating intelligent decision-making in complex scenarios"}
]

class ScenarioGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Scenario Viewer")
        self.root.geometry("800x900")
        self.root.configure(bg="#D9D9D9")
        
        self.current_scenario_index = 0
        
        # Frame for content
        self.frame = tk.Frame(root, width=659, height=870, bg="#D9D9D9")
        self.frame.place(x=100, y=50)
        
        # Image label
        self.image_label = tk.Label(self.frame)
        self.image_label.place(x=0, y=0, width=659, height=600)
        
        # Slider
        self.slider = tk.Scale(self.frame, from_=-5, to=5, orient="horizontal", length=500)
        self.slider.place(x=79, y=650)
        
        # Slider labels
        self.label_self = tk.Label(self.frame, text="Self", bg="#D9D9D9", fg="#333333")
        self.label_self.place(x=79, y=700)
        
        self.label_robot = tk.Label(self.frame, text="Robot", bg="#D9D9D9", fg="#333333")
        self.label_robot.place(x=550, y=700)
        
        # Button to switch scenarios
        self.next_button = ttk.Button(self.frame, text="Next Scenario", command=self.next_scenario)
        self.next_button.place(x=250, y=750)
        
        # Load initial scenario
        self.update_scenario()
    
    def update_scenario(self):
        scenario = scenarios[self.current_scenario_index]
        response = requests.get(scenario["image"])
        image_data = Image.open(BytesIO(response.content))
        image_resized = image_data.resize((659, 600), Image.ANTIALIAS)
        self.tk_image = ImageTk.PhotoImage(image_resized)
        self.image_label.config(image=self.tk_image)
    
    def next_scenario(self):
        self.current_scenario_index = (self.current_scenario_index + 1) % len(scenarios)
        self.update_scenario()

# Run the GUI
root = tk.Tk()
app = ScenarioGUI(root)
root.mainloop()
