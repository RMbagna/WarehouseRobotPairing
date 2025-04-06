import pygame
import random
import math
import matplotlib.pyplot as plt
import numpy as np
from io import BytesIO

# Initialize Pygame
pygame.init()

# Screen dimensions
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Human-Robot Collaboration Game")

# Colors
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
BLUE = (0, 0, 255)
RED = (255, 0, 0)

# Fonts
font = pygame.font.Font(None, 36)

# Game Variables
time_limit = 5  # Time pressure mode (5s timer)
alpha_values = {"baseline": 1, "uncertainty": 0.5, "time_pressure": 0.1}
mode = "baseline"  # Default mode
human_payoff = 5 * alpha_values[mode]
robots = [
    {"id": 1, "charge": random.uniform(0.5, 1.0), "production": random.uniform(0.5, 1.0)},
    {"id": 2, "charge": random.uniform(0.5, 1.0), "production": random.uniform(0.5, 1.0)},
    {"id": 3, "charge": random.uniform(0.5, 1.0), "production": random.uniform(0.5, 1.0)}
]
selected_robot = None

def generate_radar_chart(robot):
    labels = np.array(["Charge", "Production"])
    stats = np.array([robot['charge'], robot['production']])
    
    angles = np.linspace(0, 2 * np.pi, len(labels), endpoint=False).tolist()
    stats = np.concatenate((stats, [stats[0]]))
    angles += angles[:1]
    
    fig, ax = plt.subplots(figsize=(3, 3), subplot_kw=dict(polar=True))
    ax.fill(angles, stats, color='blue', alpha=0.25)
    ax.plot(angles, stats, color='blue', linewidth=2)
    ax.set_yticklabels([])
    ax.set_xticks(angles[:-1])
    ax.set_xticklabels(labels)
    
    buf = BytesIO()
    plt.savefig(buf, format="PNG", bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return pygame.image.load(buf)

# Game Loop
running = True
while running:
    screen.fill(WHITE)
    
    # Event Handling
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_1:
                selected_robot = robots[0]
            elif event.key == pygame.K_2:
                selected_robot = robots[1]
            elif event.key == pygame.K_3:
                selected_robot = robots[2]
    
    # Display Payoff Matrix
    y_offset = 100
    for robot in robots:
        text = font.render(f"Robot {robot['id']}: Press {robot['id']} to select", True, BLACK)
        screen.blit(text, (50, y_offset))
        y_offset += 40
    
    # Display Selected Robot's Radar Chart
    if selected_robot:
        radar_chart = generate_radar_chart(selected_robot)
        screen.blit(radar_chart, (400, 200))
        text = font.render(f"Selected Robot: {selected_robot['id']}", True, RED)
        screen.blit(text, (50, 300))
    
    pygame.display.flip()

pygame.quit()
