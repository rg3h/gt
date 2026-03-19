#!/usr/bin/zsh
# @fileoverview gtCharCodes.sh holds TTY escape codes and unicode characters
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

ESC=$'\e'

# TTY text effects
CLR_LINE="${ESC}[2K"
CLR_SCREEN="${ESC}[2J"
CLR_TEXT="${ESC}[0m"

BOLD="${ESC}[1m"
BOLD_OFF="${ESC}[24m"
BOLD_OFF="${ESC}[22m"
BLINK="${ESC}[5m"
BLINK_OFF="${ESC}[25m"

CLR_FG_COLOR="${ESC}[39m"
CLR_BG_COLOR="${ESC}[49m"
CLR_COLOR="$CLR_FG_COLOR$CLR_BG_COLOR"

# TTY colors
# TODO: get color level supported

# ESC[38;2;{r};{g};{b}m 	Set foreground color as RGB.
# ESC[48;2;{r};{g};{b}m 	Set background color as RGB.

# grayscale: 24 steps from 232 (near black) to 255 (near white)
#GREY_0="${ESC}[38;5;232m"        # (  0/255 * 23) + 232 = 232
GREY_50="${ESC}[38;236;m"         # ( 50/255 * 23) + 232 = 236
GREY_100="${ESC}[38;5;241m"       # (100/255 * 23) + 232 = 241
GREY_150="${ESC}[38;5;246m"       # (150/255 * 23) + 232 = 246
GREY_200="${ESC}[38;5;250m"       # (200/255 * 23) + 232 = 250
GREY_220="${ESC}[38;5;252m"       # (220/255 * 23) + 232 = 252
#GREY_255="${ESC}[38;5;255m"      # (255/255 * 23) + 232 = 255

RED="${ESC}[91m"
BRIGHT_RED="${ESC}[1;31m"
DARK_RED="${ESC}[31m"

LIGHT_GREY="${ESC}[37m"
DARK_GREY="${ESC}[90m"
WHITE="${ESC}[37m"
BRIGHT_WHITE="${ESC}[97m"
YELLOW="${ESC}[38;5;226m"

GREEN="${ESC}[32m"
BRIGHT_GREEN="${ESC}[92m"

BRIGHT_CYAN="${ESC}[96m"

BRIGHT_MAGENTA="${ESC}[95m"

# BG colors
WHITE_BG="${ESC}[47m"
BLUE_BG="${ESC}[48;5;26m"
DARK_GREY_BG="${ESC}[100m"
GREEN_BG="${ESC}[42m"
BRIGHT_GREEN_BG="${ESC}[102m"

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
