#!/usr/bin/zsh
# @fileoverview gtGetOwner.sh returns the current owner name
#   usage:
#     source ${FULL_PATH_NAME}/gtGetOwner.sh
#     local owner=$(gtGetOwner)
#     printf "github owner is %s\n" ${owner}
#                     _
#  _      _      __ _| |_
#  \\___()''o   / _` | __|
#  (     \_v   | (_| | |_    gt: tools to simplify git and github
#   \_)\_)_)    \__, |\__|
#               |___/
#

gtGetOwner() {
  local owner=$(gh api user -q .login)
  print -r -- ${owner}
}
