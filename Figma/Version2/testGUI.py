import tkinter as tk
from math import pi
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

# Data for Robot States and Task Roles
data = {
    "robot_states": {"Energy": 0.8, "Pace": 0.6, "Safety": 0.9, "Reliability": 0.7, "Intelligence": 0.8},
    "task_roles": {
        "Delivery": {"Energy": 0.6, "Pace": 0.8, "Safety": 0.5, "Reliability": 0.7, "Intelligence": 0.6},
        "Inspection": {"Energy": 0.4, "Pace": 0.5, "Safety": 0.9, "Reliability": 0.6, "Intelligence": 0.8},
        "Assembling": {"Energy": 0.7, "Pace": 0.6, "Safety": 0.6, "Reliability": 0.8, "Intelligence": 0.9}
    }
}

# Function to Plot the Radar Chart
def plot_radar_chart():
    robot_states = list(data["robot_states"].values())
    roles = data["task_roles"]
    labels = list(data["robot_states"].keys())

    # Radar chart setup
    angles = [n / float(len(labels)) * 2 * pi for n in range(len(labels))]
    angles += angles[:1]  # Close the circle

    fig, ax = plt.subplots(figsize=(6, 6), subplot_kw=dict(polar=True))

    # Plot robot states (fixed)
    ax.plot(angles, robot_states + [robot_states[0]], linewidth=2, label="Robot States")
    ax.fill(angles, robot_states + [robot_states[0]], alpha=0.25)

    # Overlay task roles
    for role, scores in roles.items():
        role_states = list(scores.values())
        ax.plot(angles, role_states + [role_states[0]], linewidth=1.5, linestyle="--", label=f"{role}")
        ax.fill(angles, role_states + [role_states[0]], alpha=0.15)

    # Add labels
    ax.set_yticks([])
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(labels)
    ax.legend(loc="upper right", bbox_to_anchor=(1.2, 1.2))
    return fig

# Update Chart in GUI
def update_chart():
    fig = plot_radar_chart()

    # Clear previous chart
    for widget in chart_frame.winfo_children():
        widget.destroy()

    # Embed the matplotlib figure in Tkinter
    canvas = FigureCanvasTkAgg(fig, master=chart_frame)
    canvas.draw()
    canvas.get_tk_widget().pack()

# Create GUI Window
root = tk.Tk()
root.title("Radar Chart: All Task Roles")

# Frame for Chart Display
chart_frame = tk.Frame(root)
chart_frame.pack(padx=10, pady=10)

# Display Initial Chart
update_chart()

# Run the GUI
root.mainloop()