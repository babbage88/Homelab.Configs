#!/usr/bin/env python3
import os
import sys
import random
import argparse
from enum import Enum

class ColorFormat(Enum):
    BACKGROUND = 1
    FOREGROUND = 2
    BRIGHT = 3
    EIGHTCOLOR = 8
    SIXTEENCOLOR = 16


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

def print_256(color_mode):
    #Print available colors in 256 color mode based on the specified format type.
    print(f"Available 256 {color_mode.value} colors:")

    for i in range(256):
        if color_mode == ColorFormat.BACKGROUND:
            print(f"\x1b[48;5;{i}m  {i:3}  \x1b[0m", end=" ")
        elif color_mode == ColorFormat.FOREGROUND:
            print(f"\x1b[38;5;{i}m  {i:3}  \x1b[0m", end=" ")
        elif color_mode == ColorFormat.BRIGHT:
            print(f"\x1b[1;38;5;{i}m  {i:3}  \x1b[0m", end=" ")

        # Print 16 colors per line
        if (i + 1) % 16 == 0:
            print()
    print()

def print_basic_colors_fg(color_mode):
    # Print basic 8 or 16 color mode colors with only BLACK having a white background.
    print("Basic {} ANSI Colors\n".format(color_mode.value))
    print(f"\x1b[47m\x1b[30m BLACK \x1b[0m\x1b[31m RED \x1b[32m GREEN \x1b[33m YELLOW \x1b[0m")
    print(f"\x1b[47m\x1b[34m BLUE \x1b[0m\x1b[35m MAGENTA \x1b[36m CYAN \x1b[37m WHITE \x1b[0m\n")

    if color_mode.value == ColorFormat.SIXTEENCOLOR.value:
        print(f"\x1b[47m\x1b[30;1m BRIGHT BLACK \x1b[0m\x1b[31;1m BRIGHT RED \x1b[32;1m BRIGHT GREEN \x1b[33;1m BRIGHT YELLOW \x1b[0m")
        print(f"\x1b[47m\x1b[34;1m BRIGHT BLUE \x1b[0m\x1b[\x1b[35;1m BRIGHT MAGENTA \x1b[36;1m BRIGHT CYAN \x1b[37;1m  BRIGHT WHITE \x1b[0m\n")

def print_ref_colors():
    # Show some known reference colors
    print("Reference Colors:\n")
    print(f"\x1b[48;2;255;0;0m  #FF0000  (Red)  \x1b[0m")
    print(f"\x1b[48;2;0;255;0m  #00FF00  (Green)  \x1b[0m")
    print(f"\x1b[48;2;0;0;255m  #0000FF  (Blue)  \x1b[0m")
    print(f"\x1b[48;2;255;255;255m  #FFFFFF  (White)  \x1b[0m")
    print(f"\x1b[48;2;0;0;0m  #000000  (Black)  \x1b[0m\n")



def test_print_256_stdout():
    for i in range(0, 16):
        for j in range(0, 16):
            code = str(i * 16 + j)
            sys.stdout.write(u"\x1b[38;5;" + code + "m " + code.ljust(4))
        print(f"\x1b[0m")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Truecolor Verification Script')

    # Define arguments for different functions
    parser.add_argument('--print8', action='store_true', help='Print Basic 8  colors')
    parser.add_argument('--print16', action='store_true', help='Print all available 16 Background  colors')
    parser.add_argument('--print256bg', action='store_true', help='Print all available 256 Background  colors')
    parser.add_argument('--print256fg', action='store_true', help='Print all available 256 Forreground colors')
    parser.add_argument('--print256bright', action='store_true', help='Print all available 256 Bright colors')
    parser.add_argument('--check-env', action='store_true', help='Check environment variables for color support')
    parser.add_argument('--gradient-24bit', action='store_true', help='Print RGB gradients for Red, Green, and Blue channels')
    parser.add_argument('--random-24bit', action='store_true', help='Print 3 random ranges of colors')
    parser.add_argument('--print-reference', action='store_true', help='Print reference colors')

    args = parser.parse_args()

    print("\nTruecolor Verification Script:")
    print("If your terminal supports Truecolor (24-bit color), you should see smooth gradients and exact colors (no color banding).\n")

    if args.print_reference:
        print_ref_colors()

    # Check environment variables if specified
    if args.check_env:
        check_environment()

    # Call the respective functions based on arguments
    if args.gradient_24bit:
        print_gradient_24bit("Red", "R")
        print_gradient_24bit("Green", "G")
        print_gradient_24bit("Blue", "B")

    if args.print8:
        print_basic_colors_fg(ColorFormat.EIGHTCOLOR)

    if args.print16:
        print_basic_colors_fg(ColorFormat.SIXTEENCOLOR)

    if args.print256bg:
        print_256(ColorFormat.BACKGROUND)

    if args.print256fg:
        print_256(ColorFormat.FOREGROUND)

    if args.print256bright:
        print_256(ColorFormat.BRIGHT)
