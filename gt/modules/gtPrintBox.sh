#!/usr/bin/zsh
# @fileoverview gtPrintBox.sh uses unicode chars to print boxes around messages
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

# prints a horizontal line
printHLine() {
  local width=70
  if [[ $1 == <-> ]]; then width=$1; fi
  repeat ${width} printf "%b" ${H_LINE}
}


# prints a horizontal line with |- and -| at the ends
printCrossBar() {
  local width=$((70 - 2))

  if [[ $1 == <-> ]]; then width=$(($1 - 2)); fi
  printf "%b" ${T_LEFT}
  printHLine ${width}
  printf "%b\n" ${T_RIGHT}
}


# printBoxTop -- total width includes the two corner characters
printBoxTop() {
  local width=$((70 - 2))

  if [[ $1 == <-> ]]; then width=$(($1 - 2)); fi
  printf "%b" ${TL_CORNER} ; printHLine ${width} ; printf "%b\n" ${TR_CORNER}
}


# printBoxBottom -- total width includes the two corner characters
printBoxBottom() {
  local width=$((70 - 2))

  if [[ $1 == <-> ]]; then width=$(($1 - 2)); else width=68; fi
  printf "%b" ${BL_CORNER} ; printHLine ${width} ; printf "%b\n" ${BR_CORNER}
}


# printBoxLeft "this is text" adds a vbar and space to the front of the text
printBoxLeft() {
  printf "%b " ${V_LINE}
  printf $1
  if [[ $2 == <-> ]]; then repeat $2 printf " "; fi
}


# printBoxRight "this is text" 10 adds a space and vbar after 10 spaces
printBoxRight() {
  if [[ $2 == <-> ]]; then repeat $2 printf " "; fi
  printf $1
  printf " %b\n" ${V_LINE}
}


# prints a line for a box with vertical bars on either end.
# It will handle:
#   multi-line text
#   trimming too-long text
#   handling trailing escape codes if the line is trimmed
# usage: printBoxLine "${GREEN}this is text${CLR_COLOR}\n" "some" "more text"
printBoxLine() {
  setopt local_options extended_glob

  local width=66        # 70 wide but -4 for margin and vertical bars
  local inputStr="$@"   # all params collected together

  local inputAsList=("${(@s:\n:)inputStr}") # splits str on \n into an array
  # local inputAsList=("${(f)inputStr}")

  inputAsList=("${(@s:\n:)inputStr}") # splits str on \n into an array

  local line=""         # store a line of the inputStr during processing
  local escFreeLine=""  # line after color escape codes have been removed

  local excess=0        # how much longer the string is than the allowed width
  local truncateCount=0 # how many characters to remove from the line to fit
  local padding=""      # holds the spaces to pad out the line to the width

  # print "linecount:" ${#inputAsList}
  for line in "${inputAsList[@]}"; do
    padding=""
    escFreeLine=${line//$ESC\[[0-9;]##m/}

    # we need to count "\u26A0" as one character not 5
    # escFreeLine=${escFreeLine//u[0-9a-fA-F]#####/A}
    escFreeLine=${escFreeLine//u26A0/}

    # if the excess > 0 then truncate, else pad the line out to the width
    excess=$((${#escFreeLine} - ${width}))

    if [[ ${excess} -gt 0 ]]; then
      local trailingEscCodes="${(e)line##*${escFreeLine}}"
      excess=$(( -1 * (${#escFreeLine} - ${width} + ${#trailingEscCodes} + 4) ))
      line="${line[1,${excess}]}...${trailingEscCodes}${CLR_TEXT}"
    else
      padding=${(pl:$((-1 * ${excess})):: :)}
    fi
    print ${V_LINE} ${line}${padding} ${V_LINE}
  done
}


# prints a box around the text
# usage: printBox "this is text"
printBox() {
  printBoxTop
  printBoxLine ${@}
  printBoxBottom
}


# prints a box around the text. First param above the bar, rest below
# usage: printBoxWithHeader "${header}" "${text}"
gtPrintBoxWithHeader() {
  if [[ "$#" -lt 1 ]]; then
    return
  elif [[ "$#" -eq 1 ]]; then
    printBox $1
  else
    remainingArgs="${@[2,-1]}"
    printBoxTop
    printBoxLine "${1}"
    printCrossBar
    printBoxLine "${remainingArgs}"
    printBoxBottom
  fi
}

# print a red box with an error symbol in it
gtPrintErrorBox() {
  local first=true

  printf ${BRIGHT_RED}
  printBox "${ERROR_SYMBOL} "  "${@}"
  printf ${CLR_COLOR}
}
