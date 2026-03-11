#!/usr/bin/zsh
#
# @fileoverview gtGetOwner.sh returns the current owner name
#   usage:
#     source ${FULL_PATH_NAME}/gtGetOwner.sh
#     local owner=$(gtGetOwner)
#     printf "github owner is %s\n" ${owner}
#

gtGetOwner() {
  local owner=$(gh api user -q .login)
  print -r -- ${owner}
}
