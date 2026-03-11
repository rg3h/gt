#!/usr/bin/zsh
# @fileoverview gtPrintBox.sh uses unicode chars to print boxes around messages
# source gtCharCodes.sh
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


# printBox "this is text" 70 -- total width includes text, 2 spaces, side bars
printBox() {
  local text=""
  local width=$((70 - 4))

  if [[ $1 == <-> ]]; then    # <-> means matches a number
    text=""
    width=$(($1 - 4))
  else
    if [[ ${#1} -gt 0 ]]; then
      text=$1
      if [[ $2 == <-> ]]; then
        width=$(($2 - 4))
      fi
    fi
  fi

  # if the text is multi-line, split into individual lines
  local linesList=("${(f)text}")
  if [[ ${#linesList[@]} -gt 1 ]]; then
    printCrossBar
  fi

  # if the individual line is too long, truncate and append "..."
  for line in "${linesList[@]}"; do
    # trim a long string
    if [[ ${#line} -gt ${width} ]]; then line="${line[1,(($width-3))]}..."; fi
    local lineWidth=$(($width - ${#line}))
    if [[ lineWidth -lt 0 ]]; then lineWidth=0; fi
    printf "%b " ${V_LINE}
    printf ${line}
    repeat ${lineWidth} printf " "
    printf " %b\n" ${V_LINE}
  done
}


# usage: printBoxWithHeader "${header}" "${text}"
gtPrintBoxWithHeader() {
  # if [[ $# -lt 2 ]]; then noheader; fi
  printBoxTop
  printBox "${1}"
  printBox "${2}"
  printBoxBottom
}


# print a red box with an error symbol in it
gtPrintErrorBox() {
  local first=true

  printf ${BOLD_RED}
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
