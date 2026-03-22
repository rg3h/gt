#!/usr/bin/zsh
# @fileoverview runAllTests.sh runs all gt tests
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#
clear
shScriptList=(*.sh)
for shScript in "${shScriptList[@]}"; do
  # print -r -- "${shScript}"
  if [[ ${shScript} != "runAllTests.sh" ]]; then
    print "Running" "${shScript}"
    zsh "${shScript}"
    print "\n==================================================\n"
  fi
done
