#!/usr/bin/zsh
# @fileoverview gtCharCodes.sh holds TTY escape codes and unicode characters
#

# TTY escape codes
CLR="\e[2J"
BOLD="\e[1m"
BOLD_OFF="\e[24m"
BOLD_OFF="\e[22m"
BLINK="\e[5m"
BLINK_OFF="\e[25m"
RESET="\e[0m"

RED="\e[31m"
BRIGHT_RED="\e[91m"
BOLD_RED="\e[1;31m"
LIGHT_GREY="\e[37m"
DARK_GREY="\e[90m"
GREY_244="\e[38;5;244m"

# grayscale: 24 steps from 232 (near black) to 255 (near white)
# 0   is   (0/255) * 23 = 0      + 232 = 232
# 128 is (128/255) * 23 = 11.54  + 232 = 244
# 255 is (255/255) * 23 = 23     + 232 = 255

GREY_50="\e[38;236;m"         # ( 50/255 * 23) + 232
GREY_100="\e[38;5;241m"       # (100/255 * 23) + 232
GREY_150="\e[38;5;246m"       # (150/255 * 23) + 232
GREY_200="\e[38;5;250m"       # (200/255 * 23) + 232
GREY_220="\e[38;5;252m"       # (220/255 * 23) + 232

# ESC[38;2;{r};{g};{b}m 	Set foreground color as RGB.
# ESC[48;2;{r};{g};{b}m 	Set background color as RGB.

WHITE="\e[37m"
BRIGHT_WHITE="\e[97m"

WHITE_BG="\e[47m"
DARK_GREY_BG="\e[100m"

BLUE_BG="\e[48;5;26m"
YELLOW="\e[38;5;226m"

# unicode box shapes
TL_CORNER="\u250c"
TR_CORNER="\u2510"
BL_CORNER="\u2514"
BR_CORNER="\u2518"
CROSS="\u253c"
T_LEFT="\u251c"
T_RIGHT="\u2524"
T_BOTTOM="\u2534"
T_TOP="\u252c"
V_LINE="\u2502"
H_LINE="\u2500"

# emoji unicode
SNOWMAN_SYMBOL="\u2603"
ERROR_SYMBOL="\u26A0"
