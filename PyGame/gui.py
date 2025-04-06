import tkinter as tk
from tkinter import messagebox

class HRISApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Human-Robot Interaction Study")
        self.root.geometry("800x600")
        self.show_home_page()

    def clear_frame(self):
        for widget in self.root.winfo_children():
            widget.destroy()

    def show_home_page(self):
        self.clear_frame()
        tk.Label(self.root, text="Human - Robot Interaction Study", font=("Arial", 24)).pack(pady=20)
        tk.Label(self.root, text="Welcome!", font=("Arial", 18)).pack(pady=10)
        tk.Label(self.root, text="Select difficulty to get started", font=("Arial", 14)).pack(pady=10)

        tk.Button(self.root, text="Easy Task", font=("Arial", 14), command=self.show_easy_mode).pack(pady=10)
        tk.Button(self.root, text="Medium Task", font=("Arial", 14), command=self.show_medium_mode).pack(pady=10)
        tk.Button(self.root, text="Hard Task", font=("Arial", 14), command=self.show_hard_mode).pack(pady=10)

        tk.Button(self.root, text="Background", font=("Arial", 14), command=self.show_background_page).pack(pady=10)
        tk.Button(self.root, text="About Us", font=("Arial", 14), command=self.show_about_us).pack(pady=10)

    def show_background_page(self):
        self.clear_frame()
        tk.Label(self.root, text="Background", font=("Arial", 24)).pack(pady=20)
        tk.Label(self.root, text="Welcome!", font=("Arial", 18)).pack(pady=10)
        tk.Label(self.root, text="Your choices shape the way human-robot teams collaborate. By participating, you contribute to a deeper understanding of how judgment evolves in shared tasks, helping design better, more human-centric automation systems. Choose wisely—your ideal robotic partner could be the key to maximizing both efficiency and rewards.", font=("Arial", 12), wraplength=700).pack(pady=10)
        tk.Label(self.root, text="Good luck!", font=("Arial", 14)).pack(pady=10)
        tk.Button(self.root, text="Back to Home", font=("Arial", 14), command=self.show_home_page).pack(pady=10)

    def show_easy_mode(self):
        self.show_task_mode("Easy Mode")

    def show_medium_mode(self):
        self.show_task_mode("Medium Mode")

    def show_hard_mode(self):
        self.show_task_mode("Hard Mode")

    def show_task_mode(self, mode):
        self.clear_frame()
        tk.Label(self.root, text=mode, font=("Arial", 24)).pack(pady=20)
        tk.Label(self.root, text="Which of the following robot do you prefer to work with?", font=("Arial", 14)).pack(pady=10)

        self.robot_var = tk.StringVar(value="None")
        tk.Radiobutton(self.root, text="Robot 1", variable=self.robot_var, value="Robot 1", font=("Arial", 12)).pack(pady=5)
        tk.Radiobutton(self.root, text="Robot 2", variable=self.robot_var, value="Robot 2", font=("Arial", 12)).pack(pady=5)
        tk.Radiobutton(self.root, text="Robot 3", variable=self.robot_var, value="Robot 3", font=("Arial", 12)).pack(pady=5)

        tk.Button(self.root, text="Switch", font=("Arial", 14), command=self.switch_robot).pack(pady=10)
        tk.Button(self.root, text="Next", font=("Arial", 14), command=self.show_end_page).pack(pady=10)
        tk.Button(self.root, text="Quit", font=("Arial", 14), command=self.root.quit).pack(pady=10)

    def switch_robot(self):
        messagebox.showinfo("Switch", "Switching robot selection")

    def show_end_page(self):
        self.clear_frame()
        tk.Label(self.root, text="Thank You!", font=("Arial", 24)).pack(pady=20)
        tk.Label(self.root, text="Thank you for participating! Your decisions help improve human-robot collaboration for the future. We appreciate your time and effort!", font=("Arial", 12), wraplength=700).pack(pady=10)
        tk.Label(self.root, text="Human - Robot Interaction Study", font=("Arial", 18)).pack(pady=10)
        tk.Label(self.root, text="Not Human-Centric", font=("Arial", 14)).pack(pady=5)
        tk.Label(self.root, text="Marginally satisfied, almost Human-Centric", font=("Arial", 14)).pack(pady=5)
        tk.Label(self.root, text="Satisfied, the model is human-centric", font=("Arial", 14)).pack(pady=5)
        tk.Button(self.root, text="Back to Home", font=("Arial", 14), command=self.show_home_page).pack(pady=10)

    def show_about_us(self):
        self.clear_frame()
        tk.Label(self.root, text="About Us", font=("Arial", 24)).pack(pady=20)
        tk.Label(self.root, text="Information about the team and the study.", font=("Arial", 14)).pack(pady=10)
        tk.Button(self.root, text="Back to Home", font=("Arial", 14), command=self.show_home_page).pack(pady=10)

if __name__ == "__main__":
    root = tk.Tk()
    app = HRISApp(root)
    root.mainloop()