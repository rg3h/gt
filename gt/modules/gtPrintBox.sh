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


# printBoxTop 70  -- total width includes the two corner characters
printBoxTop() {
  local width=$((70 - 2))

  if [[ $1 == <-> ]]; then width=$(($1 - 2)); fi
  printf "%b" ${TL_CORNER} ; printHLine ${width} ; printf "%b\n" ${TR_CORNER}
}


# printBoxBottom 70  -- total width includes the two corner characters
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


# usage: printBox "this is text"
printBox() {
  local width=66   # 70 - 4 for margin and vertical bars
  local escFreeLine=""
  local lineSuffix=""
  local padding=0

  # if the text is multi-line, split into individual lines
  local linesList=("${(f)1}")
  for line in "${linesList[@]}"; do
    # escFreeLine="${(Q)line}"
    # escFreeLine=$(echo "$line" | sed -E $'s/\x1b\\[[0-9;]*m//g')
    escFreeLine=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')

    # trim a long string and add ... but be careful of trailing esc chars
    if [[ ${#escFreeLine} -gt ${width} ]]; then
      lineSuffix="${line: -12}"
      # print "line and line suffix" ${escFreeLine} ${line} ${lineSuffix}

      if [[ $lineSuffix == *'\x1B'* ]]; then   # has trailing escape chars
        line="${line[1,(($width-15))]}..."${lineSuffix}
      else
        line="${line[1,(($width-3))]}...";
      fi
    fi

    # print a vertical bar, the line, any needed padding, and a vertical bar
    printf "%b " ${V_LINE}
    if [[ ${#line} -gt 0 ]]; then printf ${line}; fi

    padding=$(($width - ${#escFreeLine}))
    if [[ ${padding} -gt 0 ]]; then
      repeat ${padding} printf " "
    fi
    printf " %b\n" ${V_LINE}
  done
}


# usage: printBoxWithHeader "${header}" "${text}"
gtPrintBoxWithHeader() {
  # if [[ $# -lt 2 ]]; then noheader; fi
  printBoxTop
  printBox "${1}"
  printCrossBar
  printBox "${2}"
  printBoxBottom
}


# print a red box with an error symbol in it
gtPrintErrorBox() {
  local first=true

  printf ${BRIGHT_RED}
  printBoxTop

  for item in "${@}"; do
    if ${first}; then
      printBox "${ERROR_SYMBOL}  ${item}" 75
      first=false
    else
      printBox "   ${item}"
    fi
  done

  printBoxBottom
  printf ${RESET}
}
