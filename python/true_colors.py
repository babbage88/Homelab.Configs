#!/usr/bin/env python3
import random

def rgb_to_hex(r, g, b):
    """Convert RGB values to Hex."""
    return f"#{r:02x}{g:02x}{b:02x}"

def print_color_range(start_rgb, count=300):
    """Print a range of colors starting from a specific RGB value."""
    r_start, g_start, b_start = start_rgb
    for i in range(count):
        # Vary red, green, and blue values slightly within a range
        red = (r_start + random.randint(0, 50)) % 256
        green = (g_start + random.randint(0, 50)) % 256
        blue = (b_start + random.randint(0, 50)) % 256

        # Convert to hex
        hex_color = rgb_to_hex(red, green, blue)

        # Print colored block with hex code
        print(f"\x1b[48;2;{red};{green};{blue}m  {hex_color}  \x1b[0m", end="  ")

        if (i + 1) % 10 == 0:  # Print 10 colors per line
            print()
    print()  # Extra line after each range

def print_random_color_ranges():
    """Print 3 random ranges of 300 colors each."""
    for _ in range(3):
        # Randomly choose starting RGB values for each range
        start_rgb = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
        print(f"Range starting from RGB: {start_rgb}")
        print_color_range(start_rgb, 300)

if __name__ == "__main__":
    print_random_color_ranges()
