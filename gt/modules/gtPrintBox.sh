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
# it will trim the text, making sure to handle:
#   multi-line text
#   trimming too-ling text
#   preserving the escape codes if the line is trimmed
# usage: printBoxLine "this is text"
printBoxLine() {
  local width=66   # 70 wide but -4 for margin and vertical bars
  local trimWidth=$(($width - 3))
  local inputStr=$1
  if [[ ${#inputStr} -lt 1 ]]; then inputStr=" "; fi
  local escFreeStr=$(echo "${inputStr}" | sed 's/\x1b\[[0-9;]*m//g')
  local trailingEscCodes=""
  local origLine=""
  local escFreeLine=""
  local newLine=""
  local excess=0
  local padCount=0
  local padChar=' '
  local padding=""
  local i=0

  # create a copy of the original string with no escape codes
  # using one sed command to speed things up.
  # the input string may be made up of several lines so we split it
  # and see if each unescaped line is too long. If so, we need
  # to trim the line without trimming the escape codes at the end.
  # To do this:
  #   save any escape codes at the end of the original line
  #   trim the original line
  #   add "..."
  #   add back the escape codes

  # the text might be multi-line, split into individual lines
  local origInputAsList=("${(f)inputStr}")
  local escFreeStrAsList=("${(f)escFreeStr}")
  local lineCount=${#escFreeStrAsList}

  for ((i=1; i<=$lineCount; i++)); do
    origLine=${origInputAsList[$i]}
    escFreeLine=${escFreeStrAsList[$i]}

    if [[ ${#escFreeLine} -gt ${width} ]]; then   # trim and add ...
      # print "too long" ${#escFreeLine} ${#origLine} ${trimWidth}
      local trailingEscCodes="${(e)origLine##*${escFreeLine}}"
      # print "trailing esc code length:" ${#trailingEscCodes}

      excess=$(( -1 * (${#escFreeLine} - ${width} + ${#trailingEscCodes} + 4) ))
      # print "excess:" ${excess}

      newLine="${origLine[1,${excess}]}...${trailingEscCodes}"
      printf "%b %s %b\n" ${V_LINE} ${newLine} ${V_LINE}
    else
      padCount=$(($width - ${#escFreeLine}))
      if [[ ${padCount} -gt 0 ]]; then
        padding=${(pl:${padCount}::$padChar:)}
      fi
      printf "%b %s%s %b\n" ${V_LINE} ${origLine} ${padding} ${V_LINE}
    fi
  done
}


# prints a box around the text
# usage: printBox "this is text"
printBox() {
  printBoxTop
  printBoxLine ${1}
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
  printBox "${@}"
  printf ${CLR_COLOR}

#  for item in "${@}"; do
#    if ${first}; then
#      printBoxLine "${ERROR_SYMBOL}  ${item}"
#      first=false
#    else
#      printBoxLine "   ${item}"
#    fi
#  done
#
#  printBoxBottom
#  printf ${CLR_COLOR}
}
