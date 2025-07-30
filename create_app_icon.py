#!/usr/bin/env python3
"""
Script to create a high-quality app icon for Haki Yangu
Creates a balance/scales of justice icon with the app's green theme
"""

from PIL import Image, ImageDraw, ImageFont
import math

def create_app_icon():
    # Icon size (1024x1024 for high quality)
    size = 1024
    
    # Colors
    green = (27, 94, 32)  # #1B5E20
    white = (255, 255, 255)
    
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw background circle (green)
    margin = 0
    draw.ellipse([margin, margin, size-margin, size-margin], fill=green)
    
    # Draw inner white circle
    inner_margin = 100
    draw.ellipse([inner_margin, inner_margin, size-inner_margin, size-inner_margin], fill=white)
    
    # Center coordinates
    cx, cy = size // 2, size // 2
    
    # Scale factor for the balance icon
    scale = 0.6
    
    # Draw the balance/scales
    # Central post
    post_width = int(20 * scale)
    post_height = int(400 * scale)
    post_x = cx - post_width // 2
    post_y = cy - post_height // 2
    draw.rectangle([post_x, post_y, post_x + post_width, post_y + post_height], fill=green)
    
    # Base
    base_width = int(200 * scale)
    base_height = int(30 * scale)
    base_x = cx - base_width // 2
    base_y = cy + int(120 * scale)
    draw.rectangle([base_x, base_y, base_x + base_width, base_y + base_height], fill=green)
    
    # Top circle
    top_radius = int(15 * scale)
    top_y = cy - int(180 * scale)
    draw.ellipse([cx - top_radius, top_y - top_radius, cx + top_radius, top_y + top_radius], fill=green)
    
    # Scale arms
    arm_width = int(150 * scale)
    arm_height = int(12 * scale)
    arm_y = top_y - arm_height // 2
    
    # Left arm
    left_arm_x = cx - arm_width
    draw.rectangle([left_arm_x, arm_y, cx, arm_y + arm_height], fill=green)
    
    # Right arm
    right_arm_x = cx
    draw.rectangle([right_arm_x, arm_y, cx + arm_width, arm_y + arm_height], fill=green)
    
    # Scale pans
    pan_width = int(80 * scale)
    pan_height = int(20 * scale)
    chain_length = int(80 * scale)
    
    # Left pan
    left_pan_x = cx - arm_width
    left_pan_y = top_y + chain_length
    
    # Left chain
    chain_width = int(4 * scale)
    chain_x = left_pan_x - chain_width // 2
    draw.rectangle([chain_x, top_y, chain_x + chain_width, left_pan_y], fill=green)
    
    # Left pan
    draw.ellipse([left_pan_x - pan_width//2, left_pan_y - pan_height//2, 
                  left_pan_x + pan_width//2, left_pan_y + pan_height//2], fill=green)
    
    # Right pan
    right_pan_x = cx + arm_width
    right_pan_y = top_y + chain_length
    
    # Right chain
    chain_x = right_pan_x - chain_width // 2
    draw.rectangle([chain_x, top_y, chain_x + chain_width, right_pan_y], fill=green)
    
    # Right pan
    draw.ellipse([right_pan_x - pan_width//2, right_pan_y - pan_height//2, 
                  right_pan_x + pan_width//2, right_pan_y + pan_height//2], fill=green)
    
    # Add some decorative stars
    star_size = int(20 * scale)
    
    # Function to draw a simple star
    def draw_star(x, y, size, fill):
        points = []
        for i in range(10):
            angle = i * math.pi / 5
            if i % 2 == 0:
                radius = size
            else:
                radius = size // 2
            px = x + radius * math.cos(angle - math.pi/2)
            py = y + radius * math.sin(angle - math.pi/2)
            points.append((px, py))
        draw.polygon(points, fill=fill)
    
    # Add stars around the scales
    star_color = (*green, 100)  # Semi-transparent green
    draw_star(cx - 200, cy - 100, star_size//2, star_color)
    draw_star(cx + 200, cy - 100, star_size//2, star_color)
    draw_star(cx - 180, cy + 80, star_size//3, star_color)
    draw_star(cx + 180, cy + 80, star_size//3, star_color)
    
    return img

def create_icon_sizes():
    """Create app icon in multiple sizes"""
    base_icon = create_app_icon()
    
    # Common icon sizes
    sizes = [16, 32, 48, 64, 128, 256, 512, 1024]
    
    for size in sizes:
        resized = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(f'assets/images/app_icon_{size}.png')
        print(f"Created app_icon_{size}.png")
    
    # Save the main icon
    base_icon.save('assets/images/app_icon.png')
    print("Created app_icon.png")

if __name__ == "__main__":
    create_icon_sizes()
    print("App icons created successfully!")
