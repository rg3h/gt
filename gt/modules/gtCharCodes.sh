#!/usr/bin/zsh
# @fileoverview gtCharCodes.sh holds TTY escape codes and unicode characters
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

# TTY text effects
CLR="\e[2J"
BOLD="\e[1m"
BOLD_OFF="\e[24m"
BOLD_OFF="\e[22m"
BLINK="\e[5m"
BLINK_OFF="\e[25m"
RESET="\e[0m"
RESET_FG_COLOR="\e[39m"
RESET_BG_COLOR="\e[49m"
RESET_COLOR="\e[39m\e[49m"

# TTY colors
# TODO: get color level supported

# ESC[38;2;{r};{g};{b}m 	Set foreground color as RGB.
# ESC[48;2;{r};{g};{b}m 	Set background color as RGB.

# grayscale: 24 steps from 232 (near black) to 255 (near white)
#GREY_0="\e[38;5;232m"        # (  0/255 * 23) + 232 = 232
GREY_50="\e[38;236;m"         # ( 50/255 * 23) + 232 = 236
GREY_100="\e[38;5;241m"       # (100/255 * 23) + 232 = 241
GREY_150="\e[38;5;246m"       # (150/255 * 23) + 232 = 246
GREY_200="\e[38;5;250m"       # (200/255 * 23) + 232 = 250
GREY_220="\e[38;5;252m"       # (220/255 * 23) + 232 = 252
#GREY_255="\e[38;5;255m"      # (255/255 * 23) + 232 = 255

RED="\e[91m"
BRIGHT_RED="\e[1;31m"
DARK_RED="\e[31m"

LIGHT_GREY="\e[37m"
DARK_GREY="\e[90m"
WHITE="\e[37m"
BRIGHT_WHITE="\e97m"
BRIGHT_WHITE="\e[97m"
YELLOW="\e[38;5;226m"

GREEN="\e[32m"
BRIGHT_GREEN="\e[92m"

BRIGHT_CYAN="\e[96m"

BRIGHT_MAGENTA="\e[95m"

# BG colors
WHITE_BG="\e[47m"
BLUE_BG="\e[48;5;26m"
DARK_GREY_BG="\e[100m"
GREEN_BG="\x1b[42m"
BRIGHT_GREEN_BG="\x1b[102m"

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
