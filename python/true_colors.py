#!/usr/bin/env python3
import os
import random
import argparse
from enum import Enum

class ColorFormat(Enum):
    BACKGROUND = "background"
    FOREGROUND = "foreground"
    BRIGHT = "bright"


def rgb_to_hex(r, g, b):
    #Convert RGB values to Hex.
    return f"#{r:02x}{g:02x}{b:02x}"

def print_color_range(start_rgb, count=300):
    #Print a range of colors starting from a specific RGB value.
    r_start, g_start, b_start = start_rgb
    for i in range(count):
        # Vary red, green, and blue values slightly within a range
        red = (r_start + random.randint(0, 50)) % 256
        green = (g_start + random.randint(0, 50)) % 256
        blue = (b_start + random.randint(0, 50)) % 256

        # Convert to hex
        hex_color = rgb_to_hex(red, green, blue)

        # Print colored block with hex code
        print(f"\x1b[48;2;{red};{green};{blue}m  {hex_color}  \x1b[0m", end=" ")

        if (i + 1) % 10 == 0:  # Print 10 colors per line
            print()
    print()  # Extra line after each range

def print_random_color_ranges():
    #Print 3 random ranges of 300 colors each.
    for _ in range(3):
        # Randomly choose starting RGB values for each range
        start_rgb = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
        print(f"Range starting from RGB: {start_rgb}")
        print_color_range(start_rgb, 300)

def print_gradient_24bit(name, color_channel):
    #Print a smooth gradient of colors for a specific channel (R, G, or B).
    print(f"Gradient of {name} channel:")
    for value in range(256):
        # Only vary the specified channel, other channels stay at 0
        if color_channel == 'R':
            red, green, blue = value, 0, 0
        elif color_channel == 'G':
            red, green, blue = 0, value, 0
        else:
            red, green, blue = 0, 0, value

        hex_color = rgb_to_hex(red, green, blue)
        print(f"\x1b[48;2;{red};{green};{blue}m  {hex_color}  \x1b[0m", end="")

        if (value + 1) % 16 == 0:
            print()
    print()

def check_environment():
    #Check and print TERM and COLORTERM variables to diagnose color support.
    term = os.getenv('TERM', 'Not Set')
    colorterm = os.getenv('COLORTERM', 'Not Set')
    print(f"\nTerminal environment variables:")
    print(f"  TERM: {term}")
    print(f"  COLORTERM: {colorterm}\n")

def print_256_colors_bg():
    #Print all available 256 colors.
    print("Available 256 colors:")
    for i in range(256):
        print(f"\x1b[48;5;{i}m  {i:3}  \x1b[0m", end=" ")
        # Print 16 colors per line
        if (i + 1) % 16 == 0:
            print()
    print()

def print_256_colors_fg():
    #Prints all available 256 foreground colors.
    print("Available 256 foreground colors:")
    for i in range(256):
        print(f"\x1b[38;5;{i}m  {i:3}  \x1b[0m", end=" ")

        # Print 16 colors per line
        if (i + 1) % 16 == 0:
            print()
    print()

def print_256(format_type):
    #Print available colors in 256 color mode based on the specified format type.
    print(f"Available 256 {format_type.value} colors:")

    for i in range(256):
        if format_type == ColorFormat.BACKGROUND:
            print(f"\x1b[48;5;{i}m  {i:3}  \x1b[0m", end=" ")
        elif format_type == ColorFormat.FOREGROUND:
            print(f"\x1b[38;5;{i}m  {i:3}  \x1b[0m", end=" ")
        elif format_type == ColorFormat.BRIGHT:
            print(f"\x1b[1;38;5;{i}m  {i:3}  \x1b[0m", end=" ")

        # Print 16 colors per line
        if (i + 1) % 16 == 0:
            print()
    print()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Truecolor Verification Script')

    # Define arguments for different functions
    parser.add_argument('--print256bg', action='store_true', help='Print all available 256 Background  colors')
    parser.add_argument('--print256fg', action='store_true', help='Print all available 256 Forreground colors')
    parser.add_argument('--check-env', action='store_true', help='Check environment variables for color support')
    parser.add_argument('--gradient-24bit', action='store_true', help='Print RGB gradients for Red, Green, and Blue channels')
    parser.add_argument('--random-24bit', action='store_true', help='Print 3 random ranges of colors')

    args = parser.parse_args()

    print("\nTruecolor Verification Script:")
    print("If your terminal supports Truecolor (24-bit color), you should see smooth gradients and exact colors (no color banding).")

    # Check environment variables if specified
    if args.check_env:
        check_environment()

    # Show some known reference colors
    print("Reference Colors:")
    print(f"\x1b[48;2;255;0;0m  #FF0000  (Red)  \x1b[0m")
    print(f"\x1b[48;2;0;255;0m  #00FF00  (Green)  \x1b[0m")
    print(f"\x1b[48;2;0;0;255m  #0000FF  (Blue)  \x1b[0m")
    print(f"\x1b[48;2;255;255;255m  #FFFFFF  (White)  \x1b[0m")
    print(f"\x1b[48;2;0;0;0m  #000000  (Black)  \x1b[0m\n")

    # Call the respective functions based on arguments
    if args.gradient_24bit:
        print_gradient_24bit("Red", "R")
        print_gradient_24bit("Green", "G")
        print_gradient_24bit("Blue", "B")

    if args.print256bg:
        print_256(ColorFormat.BACKGROUND)

    if args.print256fg:
        print_256(ColorFormat.FOREGROUND)

    if args.printBright:
        print_256(ColorFormat.BRIGHT)
