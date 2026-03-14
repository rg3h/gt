#!/usr/bin/zsh
# @fileoverview gtDebug.sh toggles on and off debug and debugPrint
#
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

GT_DEBUG=0

# if DEBUG=1 prints the input args in grey
gtDebugPrint() {
  if [[ ${GT_DEBUG} -eq 1 ]]; then print "${GREY_200}DEBUG:" "${*}" ${RESET}; fi
}

gtDebugOn() {
  GT_DEBUG=1
  gtDebugPrint "${BRIGHT_WHITE}ON${RESET}"
}

gtDebugOff() {
  GT_DEBUG=0
  print "${GREY_200}DEBUG: ${BRIGHT_WHITE}OFF${RESET}"
}

gtDebugIsOn() {
  print -r -- ${GT_DEBUG}
}
